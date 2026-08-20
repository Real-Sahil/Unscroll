import { Hono } from "hono";

interface BlockedAttemptsContext {
  Bindings: {
    DB: D1Database;
  };
  Variables: {
    userId?: string;
  };
}

const blockedAttempts = new Hono<BlockedAttemptsContext>();

// POST /api/blocked-attempts - Log blocked access attempt
blockedAttempts.post("/", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const { app_name, content_type, blocked, notes } = await c.req.json();
  const DB = c.env.DB;

  if (!app_name) {
    return c.json({ error: "App name required" }, 400);
  }

  const attemptId = `attempt_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

  await DB.prepare(
    `INSERT INTO blocked_attempts (id, user_id, app_name, content_type, blocked, notes)
     VALUES (?, ?, ?, ?, ?, ?)`
  )
    .bind(attemptId, userId, app_name, content_type || null, blocked !== false, notes || null)
    .run();

  return c.json(
    {
      id: attemptId,
      user_id: userId,
      app_name,
      content_type,
      blocked: blocked !== false,
      timestamp: new Date().toISOString(),
    },
    201
  );
});

// GET /api/blocked-attempts - Get user's blocked attempts (analytics)
blockedAttempts.get("/", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const DB = c.env.DB;
  const startDate = c.req.query("start_date");
  const endDate = c.req.query("end_date");
  const appName = c.req.query("app_name");

  let query = "SELECT * FROM blocked_attempts WHERE user_id = ?";
  const params: any[] = [userId];

  if (startDate) {
    query += " AND timestamp >= ?";
    params.push(startDate);
  }

  if (endDate) {
    query += " AND timestamp <= ?";
    params.push(endDate);
  }

  if (appName) {
    query += " AND app_name = ?";
    params.push(appName);
  }

  query += " ORDER BY timestamp DESC LIMIT 100";

  const result = await DB.prepare(query).bind(...params).all();

  const attempts = (result.results as any[]).map((a) => ({
    id: a.id,
    user_id: a.user_id,
    app_name: a.app_name,
    content_type: a.content_type,
    timestamp: a.timestamp,
    blocked: a.blocked,
    notes: a.notes,
  }));

  // Calculate statistics
  const total = attempts.length;
  const blocked = attempts.filter((a) => a.blocked).length;
  const allowed = total - blocked;

  const byApp = attempts.reduce((acc: Record<string, number>, a) => {
    acc[a.app_name] = (acc[a.app_name] || 0) + 1;
    return acc;
  }, {});

  const byContentType = attempts.reduce((acc: Record<string, number>, a) => {
    if (a.content_type) {
      acc[a.content_type] = (acc[a.content_type] || 0) + 1;
    }
    return acc;
  }, {});

  return c.json({
    attempts,
    statistics: {
      total,
      blocked,
      allowed,
      by_app: byApp,
      by_content_type: byContentType,
    },
  });
});

export default blockedAttempts;
