import { Hono } from "hono";

interface PanicButtonContext {
  Bindings: {
    DB: D1Database;
  };
  Variables: {
    userId?: string;
  };
}

const panicButton = new Hono<PanicButtonContext>();

// POST /api/panic-button/activate - Activate emergency protection
panicButton.post("/activate", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const { cooldown_period, notes } = await c.req.json();
  const DB = c.env.DB;

  // Validate cooldown period (in seconds: 7200=2h, 43200=12h, 86400=24h)
  const validPeriods = [7200, 43200, 86400];
  if (!validPeriods.includes(cooldown_period)) {
    return c.json(
      { error: "Invalid cooldown period. Must be 7200 (2h), 43200 (12h), or 86400 (24h)." },
      400
    );
  }

  const eventId = `panic_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  const now = new Date();
  const expiresAt = new Date(now.getTime() + cooldown_period * 1000);

  await DB.prepare(
    `INSERT INTO panic_button_events (id, user_id, cooldown_period, expires_at, notes)
     VALUES (?, ?, ?, ?, ?)`
  )
    .bind(eventId, userId, cooldown_period, expiresAt.toISOString(), notes || null)
    .run();

  return c.json(
    {
      id: eventId,
      user_id: userId,
      activated_at: now.toISOString(),
      cooldown_period,
      expires_at: expiresAt.toISOString(),
      acknowledged: false,
    },
    201
  );
});

// GET /api/panic-button/status - Check if panic protection is active
panicButton.get("/status", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const DB = c.env.DB;
  const now = new Date().toISOString();

  const result = await DB.prepare(
    `SELECT * FROM panic_button_events 
     WHERE user_id = ? AND expires_at > ?
     ORDER BY activated_at DESC LIMIT 1`
  )
    .bind(userId, now)
    .first();

  if (!result) {
    return c.json({
      active: false,
      current_event: null,
    });
  }

  const expiresAt = new Date(result.expires_at as string);
  const nowDate = new Date();
  const timeRemaining = Math.max(0, Math.floor((expiresAt.getTime() - nowDate.getTime()) / 1000));

  return c.json({
    active: true,
    current_event: {
      id: result.id,
      activated_at: result.activated_at,
      cooldown_period: result.cooldown_period,
      expires_at: result.expires_at,
      time_remaining_seconds: timeRemaining,
      acknowledged: result.acknowledged,
    },
  });
});

// POST /api/panic-button/acknowledge - Acknowledge panic activation
panicButton.post("/acknowledge", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const { event_id } = await c.req.json();
  const DB = c.env.DB;

  if (!event_id) {
    return c.json({ error: "Event ID required" }, 400);
  }

  // Check ownership
  const event = await DB.prepare("SELECT user_id FROM panic_button_events WHERE id = ?")
    .bind(event_id)
    .first();

  if (!event) {
    return c.json({ error: "Event not found" }, 404);
  }

  if (event.user_id !== userId) {
    return c.json({ error: "Not authorized" }, 403);
  }

  await DB.prepare("UPDATE panic_button_events SET acknowledged = 1 WHERE id = ?")
    .bind(event_id)
    .run();

  return c.json({ success: true });
});

export default panicButton;
