# Cloudflare Workers Production Deployment Checklist

This guide walks through the complete production deployment of the UnScroll API backend on Cloudflare Workers.

## Prerequisites

- [ ] Cloudflare account with Workers enabled (paid plan recommended)
- [ ] Cloudflare API token with appropriate permissions (or authenticate via `wrangler login`)
- [ ] Account ID from Cloudflare dashboard
- [ ] D1 Database ID (already configured: `ca72fab6-a375-4f0b-bea8-64aa999d29f9`)
- [ ] SendGrid API key (for email notifications)
- [ ] JWT_SECRET (generate a strong secret, 32+ characters)

## Step 1: Authenticate with Cloudflare

```bash
# Option A: Browser-based login (recommended)
npx wrangler login

# Option B: Use API token (if in CI/CD)
export CLOUDFLARE_API_TOKEN="your-api-token"
export CLOUDFLARE_ACCOUNT_ID="your-account-id"
```

## Step 2: Create KV Namespaces

KV namespaces are used for rate limiting. Create both development and production namespaces:

```bash
# Development namespace
npx wrangler kv:namespace create "unscroll_rate_limit_kv"

# Production namespace
npx wrangler kv:namespace create "unscroll_rate_limit_kv_prod"

# Preview namespace (optional, for local testing)
npx wrangler kv:namespace create "unscroll_rate_limit_kv" --preview
```

You'll receive namespace IDs. Update `wrangler.toml`:

```toml
[[kv_namespaces]]
binding = "KV"
id = "your-development-namespace-id"
preview_id = "your-preview-namespace-id"

[env.production.kv_namespaces]
binding = "KV"
id = "your-production-namespace-id"
preview_id = "your-preview-namespace-id"
```

## Step 3: Configure Account ID

Update `wrangler.toml` with your Cloudflare account ID:

```toml
account_id = "your-account-id"  # Get from https://dash.cloudflare.com/
```

## Step 4: Set Environment Variables

Create a `.env.production` file (do NOT commit this):

```bash
# .env.production
JWT_SECRET="your-secret-key-32-characters-minimum"
SENDGRID_API_KEY="SG.your-sendgrid-api-key"
```

**To generate a secure JWT_SECRET:**

```bash
# macOS/Linux
openssl rand -base64 32

# Or use Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

## Step 5: Deploy to Production

Build and deploy:

```bash
# Build TypeScript
npm run build

# Deploy to production environment
npx wrangler deploy --env production

# Verify deployment
npx wrangler tail --env production
```

## Step 6: Test Production Endpoints

Test the live API endpoints:

```bash
# Set your production URL
export API_URL="https://unscroll-api-prod.your-domain.workers.dev"

# Test health check
curl $API_URL

# Test authentication (rate limited to 5 requests/min)
curl -X POST $API_URL/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePass123!"
  }'

# Test with invalid token (should return 401)
curl -H "Authorization: Bearer invalid-token" \
  $API_URL/api/user/profile
```

See `workers/TESTING.md` for comprehensive test scenarios.

## Step 7: Configure Flutter App

Update `lib/.env` in the Flutter project:

```env
# .env (Flutter)
SUPABASE_URL=https://unscroll-api-prod.your-domain.workers.dev
SUPABASE_ANON_KEY=not-used-with-workers
API_TIMEOUT_SECONDS=30
```

Restart the Flutter app and verify it connects to the production backend.

## Step 8: Monitor Production

Monitor logs and errors in real-time:

```bash
# Stream logs
npx wrangler tail --env production

# Check recent errors
npx wrangler tail --env production --status error
```

### Set Up Error Tracking

Install Sentry integration (optional but recommended):

```bash
npm install @sentry/node

# Configure in src/index.ts before deploying
```

### Monitor Database Performance

Via Cloudflare Dashboard:
1. Navigate to Workers → D1 → unscroll
2. Check query logs and performance metrics
3. Set up alerts for query timeouts (>10s)

## Step 9: Database Backup

Enable automatic backups:

```bash
# Manual backup (export data)
npx wrangler d1 backup create unscroll

# List backups
npx wrangler d1 backup list unscroll
```

## Step 10: Rollback Plan

If production fails:

```bash
# Rollback to previous deployment
npx wrangler rollback --env production

# Or redeploy from git
git checkout main
npm run build
npx wrangler deploy --env production
```

## Deployment Checklist

### Pre-Deployment
- [ ] TypeScript compiles without errors (`npm run build`)
- [ ] All tests pass (`npm test`)
- [ ] Environment variables set (.env.production)
- [ ] KV namespaces created and configured
- [ ] Database migrations applied
- [ ] Rate limiting tested locally

### Deployment
- [ ] Authenticated with Cloudflare (`npx wrangler login`)
- [ ] Account ID set in wrangler.toml
- [ ] Deploy to production (`npx wrangler deploy --env production`)
- [ ] Verify deployment via `npx wrangler tail`

### Post-Deployment
- [ ] Test health check endpoint
- [ ] Test authentication (register, login, refresh)
- [ ] Test protected endpoints (user profile, policies)
- [ ] Verify error handling (401, 403, 500)
- [ ] Monitor logs for errors
- [ ] Update Flutter app with production URL
- [ ] Test full end-to-end flow (Flutter ↔ Backend)

## Production Best Practices

### Security
- [ ] JWT_SECRET is unique and strong (32+ characters)
- [ ] SendGrid API key is secret (not in code)
- [ ] CORS is properly configured (allow only mobile/web domains)
- [ ] Rate limiting is enabled (5/min for login)
- [ ] Inputs are validated before database queries
- [ ] Errors don't expose sensitive data

### Performance
- [ ] Database queries are indexed (user_id, timestamp)
- [ ] KV is used for rate limiting (not database)
- [ ] Response times monitored (<500ms target)
- [ ] Database connection pooling configured

### Monitoring
- [ ] Logs streamed to external service (Sentry, LogFlare)
- [ ] Alerts set for:
  - Error rate >1%
  - Response time >2s
  - Database query failures
- [ ] Dashboard for real-time monitoring
- [ ] Backup strategy in place

### Disaster Recovery
- [ ] Database backups automated daily
- [ ] Rollback procedure documented
- [ ] Failover plan if database fails
- [ ] Data export for GDPR compliance

## Troubleshooting

### Authentication Fails After Deployment

**Problem:** `wrangler login` not working or credentials expired

**Solution:**
```bash
# Re-authenticate
npx wrangler logout
npx wrangler login

# Or use API token
export CLOUDFLARE_API_TOKEN="your-token"
npx wrangler deploy --env production
```

### KV Namespace Not Found

**Problem:** "KV namespace not found" error during deployment

**Solution:**
```bash
# List existing namespaces
npx wrangler kv:namespace list

# Create missing namespace
npx wrangler kv:namespace create "unscroll_rate_limit_kv_prod"

# Update wrangler.toml with correct ID
```

### Database Connection Errors

**Problem:** "Database not found" or connection timeout

**Solution:**
- Verify database ID in wrangler.toml matches Cloudflare dashboard
- Check D1 is enabled in your Cloudflare plan
- Run migrations: `npx wrangler d1 execute unscroll --file=supabase/migrations/001_init_schema.sql`

### Rate Limiting Not Working

**Problem:** Requests aren't being rate limited

**Solution:**
- Check KV namespace binding name matches "KV" in code
- Verify KV is populated: `npx wrangler kv:key list --namespace-id=your-id`
- Test with multiple rapid requests

## Support & Next Steps

- Deployment docs: https://developers.cloudflare.com/workers/
- D1 documentation: https://developers.cloudflare.com/d1/
- KV documentation: https://developers.cloudflare.com/workers/runtime-apis/kv/
- Issue tracking: https://github.com/Real-Sahil/Unscroll/issues

---

**Status:** Ready for production deployment  
**Last Updated:** August 20, 2026
