import {
  generateJWT,
  hashPassword,
  validateEmail,
  validatePassword,
  generateUserId,
  generateSessionId,
  rateLimitCheck,
} from "./utils";
import { Hono } from "hono";

interface AuthContext {
  Bindings: {
    DB: D1Database;
    KV: KVNamespace;
  };
}

const auth = new Hono<AuthContext>();

// POST /api/auth/register
auth.post("/register", async (c) => {
  const { email, password, name } = await c.req.json();
  const DB = c.env.DB;
  const KV = c.env.KV;

  // Validation
  if (!email || !validateEmail(email)) {
    return c.json({ error: "Invalid email" }, 400);
  }

  if (!password || !validatePassword(password)) {
    return c.json(
      { error: "Password must be at least 8 characters" },
      400
    );
  }

  // Rate limiting
  const rateLimited = !(await rateLimitCheck(KV, `register:${email}`, 5, 3600));
  if (rateLimited) {
    return c.json({ error: "Too many registration attempts" }, 429);
  }

  // Check if user exists
  const existing = await DB.prepare(
    "SELECT id FROM users WHERE email = ?"
  ).bind(email).first();

  if (existing) {
    return c.json({ error: "Email already registered" }, 409);
  }

  // Create user
  const userId = generateUserId();
  const passwordHash = await hashPassword(password);

  await DB.prepare(
    "INSERT INTO users (id, email, password_hash, name) VALUES (?, ?, ?, ?)"
  )
    .bind(userId, email, passwordHash, name || null)
    .run();

  // Generate token
  const token = await generateJWT(userId);
  const expiresIn = 86400;

  return c.json(
    {
      id: userId,
      email,
      token,
      expires_in: expiresIn,
    },
    201
  );
});

// POST /api/auth/login
auth.post("/login", async (c) => {
  const { email, password } = await c.req.json();
  const DB = c.env.DB;
  const KV = c.env.KV;

  if (!email || !password) {
    return c.json({ error: "Email and password required" }, 400);
  }

  // Rate limiting
  const rateLimited = !(await rateLimitCheck(
    KV,
    `login:${email}`,
    5,
    60
  ));
  if (rateLimited) {
    return c.json(
      { error: "Too many login attempts. Try again in 1 minute." },
      429
    );
  }

  // Find user
  const user = await DB.prepare(
    "SELECT id, email, password_hash, name FROM users WHERE email = ?"
  )
    .bind(email)
    .first();

  if (!user) {
    return c.json({ error: "Invalid credentials" }, 401);
  }

  // Verify password
  const passwordHash = await hashPassword(password);
  if (passwordHash !== user.password_hash) {
    return c.json({ error: "Invalid credentials" }, 401);
  }

  // Generate token
  const token = await generateJWT(user.id as string);
  const expiresIn = 86400;

  // Cache token in KV for fast validation
  await KV.put(`token:${token}`, user.id as string, {
    expirationTtl: expiresIn,
  });

  return c.json({
    id: user.id,
    email: user.email,
    token,
    expires_in: expiresIn,
  });
});

// POST /api/auth/refresh
auth.post("/refresh", async (c) => {
  const { refresh_token } = await c.req.json();
  const DB = c.env.DB;
  const KV = c.env.KV;

  if (!refresh_token) {
    return c.json({ error: "Refresh token required" }, 400);
  }

  // In production, validate refresh token from DB
  // For now, accept any valid JWT as refresh token
  const userId = await verifyJWTUtil(refresh_token);
  if (!userId) {
    return c.json({ error: "Invalid refresh token" }, 401);
  }

  const newToken = await generateJWT(userId);
  const expiresIn = 86400;

  // Cache new token
  await KV.put(`token:${newToken}`, userId, {
    expirationTtl: expiresIn,
  });

  return c.json({
    token: newToken,
    expires_in: expiresIn,
  });
});

// Helper to import verifyJWT
import { verifyJWT as verifyJWTUtil } from "./utils";

export default auth;
