# Cloudflare Dashboard Configuration Checklist

After deploying the Worker via the Cloudflare Pages dashboard, you need to complete the following setup steps to ensure all bindings and resources are properly configured.

## ✅ Production Worker Configuration

**Worker Name:** `unscroll-api-prod`  
**Status:** Deployed to `unscroll-api-prod.sahilxleo916.workers.dev`

### 1. Connect D1 Database Binding

**Location:** Workers > unscroll-api-prod > Settings > Bindings

1. Click **"Add binding"** under "Bindings"
2. **Variable name:** `DB`
3. **Resource type:** `D1 Database`
4. **Database:** Select `unscroll` (ID: ca72fab6-a375-4f0b-bea8-64aa999d29f9)
5. Click **"Save and deploy"**

**Verification:** The database binding allows the Worker to execute SQL queries for user data, policies, blocked attempts, etc.

### 2. Create & Connect KV Namespace (Rate Limiting)

**Location:** Workers > KV > Namespaces

1. **Create namespace:**
   - Click **"Create namespace"**
   - Name: `unscroll_rate_limit_kv_prod`
   - Click **"Add namespace"**

2. **Connect to Worker:**
   - Go to Workers > unscroll-api-prod > Settings > Bindings
   - Click **"Add binding"**
   - **Variable name:** `KV`
   - **Resource type:** `KV Namespace`
   - **KV namespace:** Select `unscroll_rate_limit_kv_prod`
   - Click **"Save and deploy"**

**Verification:** The KV namespace enables rate limiting on the `/api/auth/login` endpoint (5 requests per minute).

### 3. Verify Environment Variables

**Location:** Workers > unscroll-api-prod > Settings > Variables

1. Ensure these environment variables are set:
   - `ENVIRONMENT` = `production`
   - `JWT_SECRET` = (32+ character hex string, e.g., from user's input)
   - `RATE_LIMIT_ENABLED` = `true` (optional, defaults to enabled)

2. If JWT_SECRET is not set:
   - Click **"Add variable"**
   - **Variable name:** `JWT_SECRET`
   - **Value:** (Your 32+ character secret - **MUST match Flutter `.env` if using token refresh**)
   - Click **"Encrypt"** for production security
   - Click **"Save and deploy"**

**⚠️ Important:** The JWT_SECRET must be at least 32 characters (hex format preferred). Example: `a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b`

### 4. Configure Custom Domain (Optional but Recommended)

**Location:** Workers > unscroll-api-prod > Triggers > Custom Domains

1. Click **"Add custom domain"**
2. Enter your domain (e.g., `api.unscroll.app` if you own one)
3. Point DNS CNAME to `unscroll-api-prod.workers.dev`
4. Click **"Activate domain"**

For now, using the default `.workers.dev` domain is fine for testing.

---

## ✅ API Endpoint Verification

After bindings are configured, test these endpoints to confirm functionality:

### Health Check (No Auth Required)
```bash
curl https://unscroll-api-prod.sahilxleo916.workers.dev/
# Expected: {"status":"ok","version":"1.0.0"}
```

### User Registration (Creates DB entry)
```bash
curl -X POST https://unscroll-api-prod.sahilxleo916.workers.dev/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"TestPass123!"}'
# Expected: 201 with token
```

### Get Protected Resource (Tests DB + Auth)
```bash
curl -X GET https://unscroll-api-prod.sahilxleo916.workers.dev/api/user/profile \
  -H "Authorization: Bearer YOUR_TOKEN"
# Expected: 200 with user profile data
```

### Rate Limiting Test (Tests KV)
```bash
# Run this 6 times rapidly to trigger rate limit on 6th request
for i in {1..6}; do
  curl -X POST https://unscroll-api-prod.sahilxleo916.workers.dev/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"test@example.com","password":"wrong"}'
  echo "Request $i done"
done
# Expected: 5 requests return 200/401, 6th returns 429 Too Many Requests
```

---

## 🔍 Troubleshooting

### Binding Not Found Error
**Symptom:** `ReferenceError: DB is not defined` or `ReferenceError: KV is not defined`

**Solution:**
1. Verify the binding is added in Workers > Settings > Bindings
2. Confirm the variable names match (case-sensitive): `DB` and `KV`
3. Verify the correct resource is selected (D1 database for `DB`, KV namespace for `KV`)
4. Click **"Save and deploy"** - bindings take 30-60 seconds to propagate

### Database Queries Failing
**Symptom:** 500 errors on `/api/auth/register`, `/api/user/profile`

**Solution:**
1. Verify D1 database binding is connected to the Worker
2. Check if database schema is initialized (tables exist)
3. In Cloudflare dashboard, go to D1 Databases > unscroll > Console and run:
   ```sql
   SELECT name FROM sqlite_master WHERE type='table';
   ```
   Should show: `users`, `policies`, `blocked_attempts`, `panic_button`, `accountability_partners`, `family_children`, `notifications`, `synced_events`, `refresh_tokens`

### Rate Limiting Not Working
**Symptom:** 6th login request doesn't return 429

**Solution:**
1. Verify KV namespace binding is connected
2. Verify `RATE_LIMIT_ENABLED` is set to `true` (or not set, defaults to true)
3. Check KV namespace has keys being created: In KV > Namespace > unscroll_rate_limit_kv_prod, you should see keys like `rate_limit:test@example.com`

### CORS Errors from Flutter App
**Symptom:** Flutter app gets CORS error when calling API

**Solution:**
1. Verify CORS middleware is in place in `workers/src/index.ts`
2. Ensure allowed origins, methods, and headers are correct:
   - Origin: `*` (allows all)
   - Methods: GET, POST, PUT, DELETE, OPTIONS
   - Headers: Content-Type, Authorization
3. No additional CORS configuration needed in Cloudflare dashboard

---

## ✅ Monitoring & Logs

**Location:** Workers > unscroll-api-prod > Tail (Real-time logs)

1. Click **"Tail"** to view live logs
2. Make API requests and watch logs appear in real-time
3. Look for:
   - `[AUTH] register: success` - successful registration
   - `[RATE_LIMIT] blocked` - rate limiting in action
   - `[ERROR]` - any errors with full stack trace

**Advanced:** Use GraphQL Analytics Engine (optional, for production monitoring):
- Location: Workers > unscroll-api-prod > Analytics
- Tracks request counts, response times, error rates

---

## 📋 Final Setup Checklist

- [ ] **D1 Database binding** connected (variable: `DB`)
- [ ] **KV Namespace binding** created and connected (variable: `KV`)
- [ ] **Environment variables** set (`ENVIRONMENT=production`, `JWT_SECRET` configured)
- [ ] **Health check** returns `{"status":"ok","version":"1.0.0"}`
- [ ] **User registration** works and creates database entry
- [ ] **Protected endpoints** work with valid token
- [ ] **Rate limiting** triggers 429 on 6th login request
- [ ] **Custom domain** added (optional for now)
- [ ] **Logs visible** in Worker Tail

---

## Next Steps

Once all bindings are verified and working:

1. **Run full API testing suite** using the curl commands in `docs/API_TESTING_MANUAL.md`
2. **Flutter integration testing** against production backend
3. **Platform-specific testing** (iOS Screen Time, Android AccessibilityService)
4. **Browser extension testing** (Chrome content script)
5. **Beta testing** with 50-100 users

---

**Last Updated:** 2026-08-20  
**Status:** Configuration guide for production deployment
