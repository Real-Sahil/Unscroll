import { Hono } from "hono";

interface UserContext {
  Bindings: {
    DB: D1Database;
  };
  Variables: {
    userId?: string;
  };
}

const user = new Hono<UserContext>();

// GET /api/user/profile - Get user details
user.get("/profile", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const DB = c.env.DB;
  const result = await DB.prepare("SELECT id, email, name, created_at, is_active FROM users WHERE id = ?")
    .bind(userId)
    .first();

  if (!result) {
    return c.json({ error: "User not found" }, 404);
  }

  return c.json({
    id: result.id,
    email: result.email,
    name: result.name,
    created_at: result.created_at,
    is_active: result.is_active,
  });
});

// PUT /api/user/profile - Update profile
user.put("/profile", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const { name } = await c.req.json();
  const DB = c.env.DB;

  if (!name) {
    return c.json({ error: "Name required" }, 400);
  }

  await DB.prepare("UPDATE users SET name = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?")
    .bind(name, userId)
    .run();

  return c.json({ success: true });
});

// POST /api/user/stats - Get user statistics
user.post("/stats", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const DB = c.env.DB;

  // Get total blocked attempts
  const blockedResult = await DB.prepare(
    "SELECT COUNT(*) as count FROM blocked_attempts WHERE user_id = ? AND blocked = true"
  )
    .bind(userId)
    .first();

  const totalBlocked = (blockedResult as any)?.count || 0;

  // Get total allowed attempts
  const allowedResult = await DB.prepare(
    "SELECT COUNT(*) as count FROM blocked_attempts WHERE user_id = ? AND blocked = false"
  )
    .bind(userId)
    .first();

  const totalAllowed = (allowedResult as any)?.count || 0;

  // Get panic button activations this week
  const weekAgoDate = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();
  const panicResult = await DB.prepare(
    "SELECT COUNT(*) as count FROM panic_button_events WHERE user_id = ? AND activated_at > ?"
  )
    .bind(userId, weekAgoDate)
    .first();

  const panicWeekly = (panicResult as any)?.count || 0;

  // Get total panic activations
  const panicTotalResult = await DB.prepare(
    "SELECT COUNT(*) as count FROM panic_button_events WHERE user_id = ?"
  )
    .bind(userId)
    .first();

  const panicTotal = (panicTotalResult as any)?.count || 0;

  // Calculate streak (days since last allowed attempt)
  const lastAllowedResult = await DB.prepare(
    "SELECT MAX(timestamp) as last_timestamp FROM blocked_attempts WHERE user_id = ? AND blocked = false"
  )
    .bind(userId)
    .first();

  let streak = 0;
  if (lastAllowedResult && lastAllowedResult.last_timestamp) {
    const lastAllowed = new Date(lastAllowedResult.last_timestamp as string);
    const nowDate = new Date();
    streak = Math.floor((nowDate.getTime() - lastAllowed.getTime()) / (24 * 60 * 60 * 1000));
  }

  return c.json({
    relapse_stats: {
      total_blocked_attempts: totalBlocked,
      total_allowed_attempts: totalAllowed,
      current_streak_days: streak,
    },
    panic_stats: {
      total_activations: panicTotal,
      weekly_activations: panicWeekly,
    },
  });
});

export default user;
