import { Hono } from "hono";

interface PolicyContext {
  Bindings: {
    DB: D1Database;
  };
  Variables: {
    userId?: string;
  };
}

const policies = new Hono<PolicyContext>();

// POST /api/policies - Create new policy
policies.post("/", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const { name, blocked_apps, start_time, end_time, days_of_week, friction_level } =
    await c.req.json();
  const DB = c.env.DB;

  // Validation
  if (!name) {
    return c.json({ error: "Policy name required" }, 400);
  }

  if (!Array.isArray(blocked_apps) || blocked_apps.length === 0) {
    return c.json({ error: "At least one app must be blocked" }, 400);
  }

  if (!start_time || !end_time) {
    return c.json({ error: "Start and end times required" }, 400);
  }

  if (!Array.isArray(days_of_week) || days_of_week.length === 0) {
    return c.json({ error: "At least one day must be selected" }, 400);
  }

  const policyId = `policy_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

  await DB.prepare(
    `INSERT INTO policies (id, user_id, name, blocked_apps, start_time, end_time, days_of_week, friction_level)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`
  )
    .bind(
      policyId,
      userId,
      name,
      JSON.stringify(blocked_apps),
      start_time,
      end_time,
      JSON.stringify(days_of_week),
      friction_level || 3
    )
    .run();

  return c.json(
    {
      id: policyId,
      user_id: userId,
      name,
      blocked_apps,
      start_time,
      end_time,
      days_of_week,
      friction_level: friction_level || 3,
      created_at: new Date().toISOString(),
    },
    201
  );
});

// GET /api/policies - List user's policies
policies.get("/", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const DB = c.env.DB;
  const result = await DB.prepare("SELECT * FROM policies WHERE user_id = ? ORDER BY created_at DESC")
    .bind(userId)
    .all();

  const policiesList = (result.results as any[]).map((p) => ({
    id: p.id,
    user_id: p.user_id,
    name: p.name,
    blocked_apps: JSON.parse(p.blocked_apps || "[]"),
    start_time: p.start_time,
    end_time: p.end_time,
    days_of_week: JSON.parse(p.days_of_week || "[]"),
    friction_level: p.friction_level,
    created_at: p.created_at,
    updated_at: p.updated_at,
  }));

  return c.json({ policies: policiesList });
});

// PUT /api/policies/:id - Update policy
policies.put("/:id", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const policyId = c.req.param("id");
  const DB = c.env.DB;

  // Check ownership
  const policy = await DB.prepare("SELECT user_id FROM policies WHERE id = ?")
    .bind(policyId)
    .first();

  if (!policy) {
    return c.json({ error: "Policy not found" }, 404);
  }

  if (policy.user_id !== userId) {
    return c.json({ error: "Not authorized to update this policy" }, 403);
  }

  const { name, blocked_apps, start_time, end_time, days_of_week, friction_level } =
    await c.req.json();

  const updates: string[] = [];
  const values: any[] = [];

  if (name) {
    updates.push("name = ?");
    values.push(name);
  }
  if (blocked_apps) {
    updates.push("blocked_apps = ?");
    values.push(JSON.stringify(blocked_apps));
  }
  if (start_time) {
    updates.push("start_time = ?");
    values.push(start_time);
  }
  if (end_time) {
    updates.push("end_time = ?");
    values.push(end_time);
  }
  if (days_of_week) {
    updates.push("days_of_week = ?");
    values.push(JSON.stringify(days_of_week));
  }
  if (friction_level !== undefined) {
    updates.push("friction_level = ?");
    values.push(friction_level);
  }

  if (updates.length === 0) {
    return c.json({ error: "No fields to update" }, 400);
  }

  updates.push("updated_at = CURRENT_TIMESTAMP");
  values.push(policyId);

  const query = `UPDATE policies SET ${updates.join(", ")} WHERE id = ?`;
  await DB.prepare(query).bind(...values).run();

  return c.json({ success: true });
});

// DELETE /api/policies/:id - Delete policy
policies.delete("/:id", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const policyId = c.req.param("id");
  const DB = c.env.DB;

  // Check ownership
  const policy = await DB.prepare("SELECT user_id FROM policies WHERE id = ?")
    .bind(policyId)
    .first();

  if (!policy) {
    return c.json({ error: "Policy not found" }, 404);
  }

  if (policy.user_id !== userId) {
    return c.json({ error: "Not authorized to delete this policy" }, 403);
  }

  await DB.prepare("DELETE FROM policies WHERE id = ?").bind(policyId).run();

  return c.json({ success: true });
});

export default policies;
