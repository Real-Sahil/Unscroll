# UnScroll Cloudflare Workers API

Production-grade REST API backend for UnScroll built on Cloudflare Workers + D1 Database.

## Setup

### Prerequisites
- Node.js 18+
- Cloudflare account with Workers enabled
- Wrangler CLI installed globally

### Local Development

```bash
# Install dependencies
npm install

# Set up environment
cp .env.example .env
# Edit .env with your Cloudflare credentials

# Run locally
npm run dev
```

The API will be available at `http://localhost:8787`

### Database Configuration

Update `wrangler.toml` with your D1 database ID:

```toml
[[d1_databases]]
binding = "DB"
database_name = "unscroll"
database_id = "ca72fab6-a375-4f0b-bea8-64aa999d29f9"
```

### Deployment

```bash
# Deploy to production
npm run deploy:prod

# Deploy to development
npm run deploy
```

## API Endpoints (Phase 2 - Authentication)

### Register
```
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "secure_password_8+chars",
  "name": "John Doe"
}

Response (201):
{
  "id": "user_123456789",
  "email": "user@example.com",
  "token": "eyJhbGc...",
  "expires_in": 86400
}
```

### Login
```
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "secure_password"
}

Response (200):
{
  "id": "user_123456789",
  "email": "user@example.com",
  "token": "eyJhbGc...",
  "expires_in": 86400
}
```

### Refresh Token
```
POST /api/auth/refresh
Content-Type: application/json

{
  "refresh_token": "eyJhbGc..."
}

Response (200):
{
  "token": "eyJhbGc...",
  "expires_in": 86400
}
```

## Authentication

All protected endpoints require:
```
Authorization: Bearer {token}
```

Tokens expire in 24 hours (86400 seconds).

## Security

- Passwords hashed with SHA-256
- JWT tokens signed with HS256
- Rate limiting on login (5 attempts per minute per email)
- Rate limiting on register (5 attempts per hour per email)
- CORS enabled for Flutter app origin

## Next Steps (Phase 3)

- Core API endpoints (policies, blocked_attempts, panic button)
- Family mode endpoints
- Accountability partner endpoints
- Therapist dashboard endpoints
- Real-time sync via polling

## Project Structure

```
workers/
├── src/
│   ├── index.ts       # Main Hono app
│   ├── auth.ts        # Authentication endpoints
│   └── utils.ts       # JWT, hashing, validation
├── wrangler.toml      # Cloudflare config
├── package.json       # Dependencies
└── tsconfig.json      # TypeScript config
```
