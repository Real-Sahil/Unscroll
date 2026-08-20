import { Hono } from "hono";

interface FamilyContext {
  Bindings: {
    DB: D1Database;
  };
  Variables: {
    userId?: string;
  };
}

const family = new Hono<FamilyContext>();

// POST /api/family/invite-child - Send invite to child's email
family.post("/invite-child", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const { child_email } = await c.req.json();
  const DB = c.env.DB;

  if (!child_email || !child_email.includes("@")) {
    return c.json({ error: "Valid child email required" }, 400);
  }

  // Create relationship (invite status)
  const relationshipId = `rel_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

  await DB.prepare(
    `INSERT INTO family_relationships (id, parent_id, child_id, status)
     VALUES (?, ?, ?, 'invited')`
  )
    .bind(relationshipId, userId, child_email)
    .run();

  // In production, send email invite here
  // For now, return invite code for manual acceptance
  const inviteCode = btoa(`${userId}:${child_email}:${relationshipId}`);

  return c.json(
    {
      id: relationshipId,
      parent_id: userId,
      child_email,
      status: "invited",
      invite_code: inviteCode,
      message: "Invite sent. Child should accept using invite code.",
    },
    201
  );
});

// POST /api/family/accept-invite - Accept family invitation
family.post("/accept-invite", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const { invite_code } = await c.req.json();
  const DB = c.env.DB;

  if (!invite_code) {
    return c.json({ error: "Invite code required" }, 400);
  }

  try {
    const decoded = atob(invite_code);
    const [parentId, childEmail, relationshipId] = decoded.split(":");

    // Verify relationship exists
    const rel = await DB.prepare(
      "SELECT * FROM family_relationships WHERE id = ? AND status = 'invited'"
    )
      .bind(relationshipId)
      .first();

    if (!rel) {
      return c.json({ error: "Invalid or expired invite" }, 400);
    }

    // Update relationship status
    await DB.prepare("UPDATE family_relationships SET status = 'active' WHERE id = ?")
      .bind(relationshipId)
      .run();

    // Also update child_id if it's currently email
    await DB.prepare(
      "UPDATE family_relationships SET child_id = ? WHERE id = ? AND child_id = ?"
    )
      .bind(userId, relationshipId, childEmail)
      .run();

    return c.json({
      success: true,
      relationship_id: relationshipId,
      parent_id: parentId,
      child_id: userId,
      status: "active",
    });
  } catch {
    return c.json({ error: "Invalid invite code" }, 400);
  }
});

// GET /api/family/children - List parent's children
family.get("/children", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const DB = c.env.DB;

  const result = await DB.prepare(
    `SELECT fr.*, u.email, u.name FROM family_relationships fr
     LEFT JOIN users u ON fr.child_id = u.id
     WHERE fr.parent_id = ? AND fr.status = 'active'
     ORDER BY fr.created_at DESC`
  )
    .bind(userId)
    .all();

  const children = (result.results as any[]).map((r) => ({
    relationship_id: r.id,
    child_id: r.child_id,
    child_email: r.email || r.child_id,
    child_name: r.name,
    created_at: r.created_at,
  }));

  return c.json({ children });
});

// GET /api/family/child/:id/summary - Get child's summary
family.get("/child/:childId/summary", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const childId = c.req.param("childId");
  const DB = c.env.DB;

  // Verify parent-child relationship
  const rel = await DB.prepare(
    "SELECT * FROM family_relationships WHERE parent_id = ? AND child_id = ? AND status = 'active'"
  )
    .bind(userId, childId)
    .first();

  if (!rel) {
    return c.json({ error: "Not authorized to view this child" }, 403);
  }

  // Get child's policies
  const policiesResult = await DB.prepare("SELECT COUNT(*) as count FROM policies WHERE user_id = ?")
    .bind(childId)
    .first();

  // Get compliance: blocked attempts
  const blockedResult = await DB.prepare(
    "SELECT COUNT(*) as count FROM blocked_attempts WHERE user_id = ? AND blocked = true"
  )
    .bind(childId)
    .first();

  // Get panic activations this week
  const weekAgoDate = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();
  const panicResult = await DB.prepare(
    "SELECT COUNT(*) as count FROM panic_button_events WHERE user_id = ? AND activated_at > ?"
  )
    .bind(childId, weekAgoDate)
    .first();

  // Recent activity (last 5 blocked attempts)
  const recentResult = await DB.prepare(
    `SELECT * FROM blocked_attempts WHERE user_id = ?
     ORDER BY timestamp DESC LIMIT 5`
  )
    .bind(childId)
    .all();

  return c.json({
    child_id: childId,
    compliance: {
      active_policies: (policiesResult as any)?.count || 0,
      blocked_attempts_week: (blockedResult as any)?.count || 0,
      panic_activations_week: (panicResult as any)?.count || 0,
    },
    recent_activity: (recentResult.results as any[]).map((r) => ({
      app_name: r.app_name,
      content_type: r.content_type,
      timestamp: r.timestamp,
      blocked: r.blocked,
    })),
  });
});

// PUT /api/family/child/:id/policies - Update child's policies (parent-controlled)
family.put("/child/:childId/policies", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const childId = c.req.param("childId");
  const DB = c.env.DB;

  // Verify parent-child relationship
  const rel = await DB.prepare(
    "SELECT * FROM family_relationships WHERE parent_id = ? AND child_id = ? AND status = 'active'"
  )
    .bind(userId, childId)
    .first();

  if (!rel) {
    return c.json({ error: "Not authorized to manage this child's policies" }, 403);
  }

  const { policy_id, name, blocked_apps, start_time, end_time, days_of_week, friction_level } =
    await c.req.json();

  if (!policy_id) {
    return c.json({ error: "Policy ID required" }, 400);
  }

  // Verify policy belongs to child
  const policy = await DB.prepare("SELECT * FROM policies WHERE id = ? AND user_id = ?")
    .bind(policy_id, childId)
    .first();

  if (!policy) {
    return c.json({ error: "Policy not found" }, 404);
  }

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
  values.push(policy_id);

  const query = `UPDATE policies SET ${updates.join(", ")} WHERE id = ?`;
  await DB.prepare(query).bind(...values).run();

  return c.json({ success: true, message: "Child policy updated by parent" });
});

export default family;
