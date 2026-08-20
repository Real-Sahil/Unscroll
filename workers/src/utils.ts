import { SignJWT, jwtVerify } from "jose";

declare global {
  const JWT_SECRET: string | undefined;
}

const JWT_SECRET_VALUE = new TextEncoder().encode(
  (globalThis as any).JWT_SECRET || "fallback-secret-change-in-production"
);

export async function generateJWT(userId: string, expiresIn: number = 86400) {
  const now = Math.floor(Date.now() / 1000);
  const token = await new SignJWT({ sub: userId })
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt(now)
    .setExpirationTime(now + expiresIn)
    .sign(JWT_SECRET_VALUE);
  return token;
}

export async function verifyJWT(token: string) {
  try {
    const verified = await jwtVerify(token, JWT_SECRET_VALUE);
    return verified.payload.sub as string;
  } catch {
    return null;
  }
}

export async function hashPassword(password: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(password);
  const hashBuffer = await crypto.subtle.digest("SHA-256", data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
}

export function validateEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

export function validatePassword(password: string): boolean {
  return password.length >= 8;
}

export function generateUserId(): string {
  return "user_" + Date.now() + "_" + Math.random().toString(36).substr(2, 9);
}

export function generateSessionId(): string {
  return "session_" + Date.now() + "_" + Math.random().toString(36).substr(2, 9);
}

export async function rateLimitCheck(
  kv: KVNamespace,
  key: string,
  limit: number,
  windowSeconds: number
): Promise<boolean> {
  const count = await kv.get(key);
  const currentCount = count ? parseInt(count, 10) : 0;

  if (currentCount >= limit) {
    return false;
  }

  await kv.put(key, String(currentCount + 1), {
    expirationTtl: windowSeconds,
  });

  return true;
}
