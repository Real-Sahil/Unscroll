import { Hono } from "hono";

interface SyncContext {
  Bindings: {
    DB: D1Database;
  };
  Variables: {
    userId?: string;
  };
}

const sync = new Hono<SyncContext>();

// GET /api/sync/policies/last-sync - Get policies updated since last sync
sync.get("/policies/last-sync", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const DB = c.env.DB;
  const lastSyncTime = c.req.query("last_sync") || new Date(0).toISOString();

  const result = await DB.prepare(
    `SELECT * FROM policies 
     WHERE user_id = ? AND updated_at > ?
     ORDER BY updated_at DESC`
  )
    .bind(userId, lastSyncTime)
    .all();

  const policies = (result.results as any[]).map((p) => ({
    id: p.id,
    name: p.name,
    blocked_apps: JSON.parse(p.blocked_apps || "[]"),
    start_time: p.start_time,
    end_time: p.end_time,
    days_of_week: JSON.parse(p.days_of_week || "[]"),
    friction_level: p.friction_level,
    created_at: p.created_at,
    updated_at: p.updated_at,
  }));

  return c.json({
    last_sync: new Date().toISOString(),
    policies_changed: policies.length,
    policies,
  });
});

// GET /api/sync/panic-status - Get current panic protection status
sync.get("/panic-status", async (c) => {
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
      event: null,
    });
  }

  const expiresAt = new Date(result.expires_at as string);
  const nowDate = new Date();
  const timeRemaining = Math.max(0, Math.floor((expiresAt.getTime() - nowDate.getTime()) / 1000));

  return c.json({
    active: true,
    event: {
      id: result.id,
      activated_at: result.activated_at,
      cooldown_period: result.cooldown_period,
      expires_at: result.expires_at,
      time_remaining_seconds: timeRemaining,
    },
  });
});

// GET /api/sync/family-policies - Get parent-set policies for child (if in family mode)
sync.get("/family-policies", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const DB = c.env.DB;

  // Check if user is a child in any family relationship
  const rel = await DB.prepare(
    "SELECT parent_id FROM family_relationships WHERE child_id = ? AND status = 'active' LIMIT 1"
  )
    .bind(userId)
    .first();

  if (!rel) {
    return c.json({
      in_family_mode: false,
      parent_id: null,
      policies: [],
    });
  }

  // Get parent's policies for this child
  const parentId = rel.parent_id as string;
  const result = await DB.prepare(
    `SELECT * FROM policies 
     WHERE user_id = ?
     ORDER BY updated_at DESC`
  )
    .bind(parentId)
    .all();

  const policies = (result.results as any[]).map((p) => ({
    id: p.id,
    name: p.name,
    blocked_apps: JSON.parse(p.blocked_apps || "[]"),
    start_time: p.start_time,
    end_time: p.end_time,
    days_of_week: JSON.parse(p.days_of_week || "[]"),
    friction_level: p.friction_level,
    parent_controlled: true,
  }));

  return c.json({
    in_family_mode: true,
    parent_id: parentId,
    policies,
  });
});

export default sync;
