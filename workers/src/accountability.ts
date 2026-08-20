import { Hono } from "hono";

interface AccountabilityContext {
  Bindings: {
    DB: D1Database;
  };
  Variables: {
    userId?: string;
  };
}

const accountability = new Hono<AccountabilityContext>();

// POST /api/accountability/invite-partner - Invite accountability partner
accountability.post("/invite-partner", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const { partner_email } = await c.req.json();
  const DB = c.env.DB;

  if (!partner_email || !partner_email.includes("@")) {
    return c.json({ error: "Valid partner email required" }, 400);
  }

  const partnerId = `partner_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

  await DB.prepare(
    `INSERT INTO accountability_partners (id, user_id, partner_email, status)
     VALUES (?, ?, ?, 'invited')`
  )
    .bind(partnerId, userId, partner_email)
    .run();

  return c.json(
    {
      id: partnerId,
      user_id: userId,
      partner_email,
      status: "invited",
      message: "Accountability partner invitation sent",
    },
    201
  );
});

// GET /api/accountability/partners - List user's accountability partners
accountability.get("/partners", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const DB = c.env.DB;

  const result = await DB.prepare(
    "SELECT * FROM accountability_partners WHERE user_id = ? ORDER BY created_at DESC"
  )
    .bind(userId)
    .all();

  const partners = (result.results as any[]).map((p) => ({
    id: p.id,
    partner_email: p.partner_email,
    status: p.status,
    created_at: p.created_at,
  }));

  return c.json({ partners });
});

// DELETE /api/accountability/partners/:id - Remove accountability partner
accountability.delete("/partners/:id", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const partnerId = c.req.param("id");
  const DB = c.env.DB;

  // Verify ownership
  const partner = await DB.prepare("SELECT user_id FROM accountability_partners WHERE id = ?")
    .bind(partnerId)
    .first();

  if (!partner) {
    return c.json({ error: "Partner not found" }, 404);
  }

  if (partner.user_id !== userId) {
    return c.json({ error: "Not authorized" }, 403);
  }

  await DB.prepare("DELETE FROM accountability_partners WHERE id = ?").bind(partnerId).run();

  return c.json({ success: true });
});

// GET /api/therapist/clients - List therapist's clients
accountability.get("/therapist/clients", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const DB = c.env.DB;

  const result = await DB.prepare(
    `SELECT tc.*, u.email, u.name FROM therapist_clients tc
     JOIN users u ON tc.client_id = u.id
     WHERE tc.therapist_id = ?
     ORDER BY tc.created_at DESC`
  )
    .bind(userId)
    .all();

  const clients = (result.results as any[]).map((c) => ({
    relationship_id: c.id,
    client_id: c.client_id,
    client_email: c.email,
    client_name: c.name,
    notes: c.notes,
    created_at: c.created_at,
  }));

  return c.json({ clients });
});

// GET /api/therapist/client/:id/analytics - Get client analytics
accountability.get("/therapist/client/:clientId/analytics", async (c) => {
  const userId = c.get("userId");
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }

  const clientId = c.req.param("clientId");
  const DB = c.env.DB;

  // Verify therapist-client relationship
  const rel = await DB.prepare("SELECT * FROM therapist_clients WHERE therapist_id = ? AND client_id = ?")
    .bind(userId, clientId)
    .first();

  if (!rel) {
    return c.json({ error: "Not authorized to view this client" }, 403);
  }

  // Get stats (aggregated, no raw event data)
  const blockedResult = await DB.prepare(
    "SELECT COUNT(*) as count FROM blocked_attempts WHERE user_id = ? AND blocked = true"
  )
    .bind(clientId)
    .first();

  const allowedResult = await DB.prepare(
    "SELECT COUNT(*) as count FROM blocked_attempts WHERE user_id = ? AND blocked = false"
  )
    .bind(clientId)
    .first();

  const panicResult = await DB.prepare(
    "SELECT COUNT(*) as count FROM panic_button_events WHERE user_id = ?"
  )
    .bind(clientId)
    .first();

  // Weekly trend
  const weekAgoDate = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();
  const weeklyBlockedResult = await DB.prepare(
    "SELECT COUNT(*) as count FROM blocked_attempts WHERE user_id = ? AND blocked = true AND timestamp > ?"
  )
    .bind(clientId, weekAgoDate)
    .first();

  const blockedCount = Number((blockedResult as any)?.count || 0);
  const allowedCount = Number((allowedResult as any)?.count || 0);

  return c.json({
    client_id: clientId,
    analytics: {
      total_blocked_attempts: blockedCount,
      total_allowed_attempts: allowedCount,
      total_panic_activations: Number((panicResult as any)?.count || 0),
      weekly_blocked_attempts: Number((weeklyBlockedResult as any)?.count || 0),
      adherence_rate: blockedCount > 0
        ? Math.round((blockedCount / (blockedCount + allowedCount || 1)) * 100)
        : 0,
    },
  });
});

export default accountability;
