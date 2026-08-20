import { Hono } from "hono";

interface NotificationsContext {
  Bindings: {
    DB: D1Database;
  };
  Variables: {
    userId?: string;
  };
}

const notifications = new Hono<NotificationsContext>();

// POST /api/notifications/send-weekly-summaries (Cron-triggered, internal auth)
notifications.post("/send-weekly-summaries", async (c) => {
  // In production, verify X-Cron-Secret header or similar
  const DB = c.env.DB;

  // Get all users with active accountability partners
  const result = await DB.prepare(
    `SELECT DISTINCT u.id, u.email, u.name
     FROM users u
     JOIN accountability_partners ap ON u.id = ap.user_id
     WHERE ap.status = 'accepted'`
  )
    .all();

  const users = result.results as any[];
  const sentCount = users.length;

  // For each user, calculate stats and prepare email
  for (const user of users) {
    const userId = user.id;

    // Get stats for the week
    const weekAgoDate = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();
    const blockedResult = await DB.prepare(
      "SELECT COUNT(*) as count FROM blocked_attempts WHERE user_id = ? AND blocked = true AND timestamp > ?"
    )
      .bind(userId, weekAgoDate)
      .first();

    const allowedResult = await DB.prepare(
      "SELECT COUNT(*) as count FROM blocked_attempts WHERE user_id = ? AND blocked = false AND timestamp > ?"
    )
      .bind(userId, weekAgoDate)
      .first();

    const panicResult = await DB.prepare(
      "SELECT COUNT(*) as count FROM panic_button_events WHERE user_id = ? AND activated_at > ?"
    )
      .bind(userId, weekAgoDate)
      .first();

    const stats = {
      blocked_attempts: (blockedResult as any)?.count || 0,
      allowed_attempts: (allowedResult as any)?.count || 0,
      panic_activations: (panicResult as any)?.count || 0,
      adherence_rate: blockedResult && blockedResult.count
        ? Math.round((blockedResult.count / (blockedResult.count + (allowedResult as any)?.count || 1)) * 100)
        : 0,
    };

    // Get partners for email list
    const partnersResult = await DB.prepare(
      "SELECT partner_email FROM accountability_partners WHERE user_id = ? AND status = 'accepted'"
    )
      .bind(userId)
      .all();

    const partners = (partnersResult.results as any[]).map((p) => p.partner_email);

    // Prepare email (in production, send via SendGrid/Resend)
    const emailData = {
      to: partners,
      subject: `${user.name}'s Weekly Accountability Summary`,
      template: "weekly_summary",
      data: {
        user_name: user.name,
        stats,
        week: new Date().toLocaleDateString(),
      },
    };

    // TODO: Send via SendGrid/Resend
    // await sendEmail(emailData);
  }

  return c.json({
    success: true,
    summaries_sent: sentCount,
    timestamp: new Date().toISOString(),
  });
});

// POST /api/notifications/log-event - Log analytics event
notifications.post("/log-event", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const { event_type, event_data } = await c.req.json();
  const DB = c.env.DB;

  if (!event_type) {
    return c.json({ error: "Event type required" }, 400);
  }

  const eventId = `event_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

  await DB.prepare(
    `INSERT INTO analytics_events (id, user_id, event_type, event_data)
     VALUES (?, ?, ?, ?)`
  )
    .bind(eventId, userId, event_type, JSON.stringify(event_data || {}))
    .run();

  return c.json({ success: true, event_id: eventId }, 201);
});

// GET /api/notifications/events - Get user's analytics events
notifications.get("/events", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const DB = c.env.DB;
  const eventType = c.req.query("type");

  let query = "SELECT * FROM analytics_events WHERE user_id = ?";
  const params: any[] = [userId];

  if (eventType) {
    query += " AND event_type = ?";
    params.push(eventType);
  }

  query += " ORDER BY timestamp DESC LIMIT 100";

  const result = await DB.prepare(query).bind(...params).all();

  const events = (result.results as any[]).map((e) => ({
    id: e.id,
    event_type: e.event_type,
    event_data: JSON.parse(e.event_data || "{}"),
    timestamp: e.timestamp,
  }));

  return c.json({ events });
});

export default notifications;
