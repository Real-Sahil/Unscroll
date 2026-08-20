import { Hono } from "hono";
import { cors } from "hono/cors";
import auth from "./auth";
import policies from "./policies";
import blockedAttempts from "./blocked-attempts";
import panicButton from "./panic-button";
import user from "./user";
import { verifyJWT, rateLimitCheck } from "./utils";

interface Bindings {
  DB: D1Database;
  KV: KVNamespace;
  JWT_SECRET: string;
}

type HonoEnv = {
  Bindings: Bindings;
  Variables: {
    userId?: string;
  };
};

const app = new Hono<HonoEnv>();

// Global CORS
app.use(
  "*",
  cors({
    origin: "*",
    allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowHeaders: ["Content-Type", "Authorization"],
  })
);

// Middleware: Authentication
app.use("/api/auth/*", async (c, next) => {
  await next();
});

app.use("/api/*", async (c, next) => {
  const path = c.req.path;

  // Skip auth for public endpoints
  if (path.startsWith("/api/auth/")) {
    return await next();
  }

  const authHeader = c.req.header("Authorization");
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return c.json({ error: "Missing or invalid Authorization header" }, 401);
  }

  const token = authHeader.substring(7);
  const userId = await verifyJWT(token);

  if (!userId) {
    return c.json({ error: "Invalid or expired token" }, 401);
  }

  c.set("userId", userId);
  await next();
});

// Health check
app.get("/", (c) => {
  return c.json({ status: "ok", version: "1.0.0" });
});

// API routes
app.route("/api/auth", auth);
app.route("/api/policies", policies);
app.route("/api/blocked-attempts", blockedAttempts);
app.route("/api/panic-button", panicButton);
app.route("/api/user", user);

// Placeholder for remaining API routes (family, accountability, therapist)
app.all("/api/*", (c) => {
  return c.json(
    { error: "Endpoint not implemented", path: c.req.path },
    404
  );
});

// 404
app.all("*", (c) => {
  return c.json({ error: "Not found" }, 404);
});

export default app;
