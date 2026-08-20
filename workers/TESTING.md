# UnScroll Cloudflare Workers - Testing Guide

## Setup for Testing

### Prerequisites
```bash
npm install
```

### Local Development
```bash
npm run dev
```

API will be available at `http://localhost:8787`

---

## API Testing Scripts

### 1. Authentication Flow

**Register User**
```bash
curl -X POST http://localhost:8787/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "testpass123",
    "name": "Test User"
  }'

# Response:
{
  "id": "user_1724160000000_abc123def",
  "email": "user@example.com",
  "token": "eyJhbGc...",
  "expires_in": 86400
}
```

**Login**
```bash
curl -X POST http://localhost:8787/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "testpass123"
  }'
```

**Refresh Token**
```bash
curl -X POST http://localhost:8787/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "eyJhbGc..."
  }'
```

### 2. Policy Management

**Create Policy**
```bash
TOKEN="your_jwt_token_here"

curl -X POST http://localhost:8787/api/policies \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Evening Block",
    "blocked_apps": ["instagram", "youtube", "tiktok"],
    "start_time": "22:00",
    "end_time": "07:00",
    "days_of_week": [0,1,2,3,4,5,6],
    "friction_level": 4
  }'
```

**List Policies**
```bash
curl -X GET http://localhost:8787/api/policies \
  -H "Authorization: Bearer $TOKEN"
```

**Update Policy**
```bash
POLICY_ID="policy_1724160000000_abc123def"

curl -X PUT http://localhost:8787/api/policies/$POLICY_ID \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "friction_level": 5
  }'
```

**Delete Policy**
```bash
curl -X DELETE http://localhost:8787/api/policies/$POLICY_ID \
  -H "Authorization: Bearer $TOKEN"
```

### 3. Blocked Attempts

**Log Attempt**
```bash
curl -X POST http://localhost:8787/api/blocked-attempts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "app_name": "instagram",
    "content_type": "reels",
    "blocked": true,
    "notes": "Urge hit during evening"
  }'
```

**Get Analytics**
```bash
curl -X GET "http://localhost:8787/api/blocked-attempts?app_name=instagram" \
  -H "Authorization: Bearer $TOKEN"
```

### 4. Panic Button

**Activate**
```bash
curl -X POST http://localhost:8787/api/panic-button/activate \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "cooldown_period": 86400,
    "notes": "Emergency activation"
  }'
```

**Check Status**
```bash
curl -X GET http://localhost:8787/api/panic-button/status \
  -H "Authorization: Bearer $TOKEN"
```

**Acknowledge**
```bash
EVENT_ID="panic_1724160000000_abc123def"

curl -X POST http://localhost:8787/api/panic-button/acknowledge \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "event_id": "'$EVENT_ID'"
  }'
```

### 5. User Profile

**Get Profile**
```bash
curl -X GET http://localhost:8787/api/user/profile \
  -H "Authorization: Bearer $TOKEN"
```

**Update Profile**
```bash
curl -X PUT http://localhost:8787/api/user/profile \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Name"
  }'
```

**Get Stats**
```bash
curl -X POST http://localhost:8787/api/user/stats \
  -H "Authorization: Bearer $TOKEN"
```

### 6. Family Mode

**Invite Child**
```bash
curl -X POST http://localhost:8787/api/family/invite-child \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "child_email": "child@example.com"
  }'

# Response includes invite_code for child to accept
```

**Accept Invite (as child)**
```bash
CHILD_TOKEN="child_jwt_token"
INVITE_CODE="base64_encoded_invite"

curl -X POST http://localhost:8787/api/family/accept-invite \
  -H "Authorization: Bearer $CHILD_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "invite_code": "'$INVITE_CODE'"
  }'
```

**List Children (as parent)**
```bash
curl -X GET http://localhost:8787/api/family/children \
  -H "Authorization: Bearer $TOKEN"
```

**Get Child Summary**
```bash
CHILD_ID="user_1724160000000_child123"

curl -X GET http://localhost:8787/api/family/child/$CHILD_ID/summary \
  -H "Authorization: Bearer $TOKEN"
```

**Update Child Policy (as parent)**
```bash
POLICY_ID="policy_1724160000000_abc123def"

curl -X PUT http://localhost:8787/api/family/child/$CHILD_ID/policies \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "policy_id": "'$POLICY_ID'",
    "friction_level": 5
  }'
```

### 7. Accountability

**Invite Partner**
```bash
curl -X POST http://localhost:8787/api/accountability/invite-partner \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "partner_email": "partner@example.com"
  }'
```

**List Partners**
```bash
curl -X GET http://localhost:8787/api/accountability/partners \
  -H "Authorization: Bearer $TOKEN"
```

### 8. Sync & Polling

**Get Updated Policies**
```bash
curl -X GET "http://localhost:8787/api/sync/policies/last-sync?last_sync=2024-08-20T00:00:00.000Z" \
  -H "Authorization: Bearer $TOKEN"
```

**Check Panic Status**
```bash
curl -X GET http://localhost:8787/api/sync/panic-status \
  -H "Authorization: Bearer $TOKEN"
```

---

## Error Testing

### Invalid Token
```bash
curl -X GET http://localhost:8787/api/policies \
  -H "Authorization: Bearer invalid_token"
# Expect: 401 Unauthorized
```

### Missing Authorization
```bash
curl -X GET http://localhost:8787/api/policies
# Expect: 401 Missing or invalid Authorization header
```

### Invalid Email on Register
```bash
curl -X POST http://localhost:8787/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "not-an-email",
    "password": "testpass123"
  }'
# Expect: 400 Invalid email
```

### Weak Password
```bash
curl -X POST http://localhost:8787/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "short"
  }'
# Expect: 400 Password must be at least 8 characters
```

### Rate Limiting
```bash
# Try login 5+ times quickly with same email
for i in {1..6}; do
  curl -X POST http://localhost:8787/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{
      "email": "user@example.com",
      "password": "testpass123"
    }'
  sleep 0.5
done
# 5th+ attempts: 429 Too many login attempts
```

---

## Integration Testing Checklist

- [ ] Auth register with valid data
- [ ] Auth register with duplicate email (409 error)
- [ ] Auth login success
- [ ] Auth login invalid credentials (401)
- [ ] Auth refresh token
- [ ] Token expiration handling
- [ ] Create policy with all fields
- [ ] Create policy with minimal fields
- [ ] List policies (empty, single, multiple)
- [ ] Update policy (partial, full)
- [ ] Update non-owned policy (403 forbidden)
- [ ] Delete policy
- [ ] Log blocked attempt
- [ ] Get analytics with filters
- [ ] Activate panic button (2h, 12h, 24h)
- [ ] Check panic status (active, inactive)
- [ ] Acknowledge panic event
- [ ] Get user profile
- [ ] Update user name
- [ ] Get user statistics
- [ ] Family: invite child
- [ ] Family: accept invite
- [ ] Family: list children
- [ ] Family: get child summary
- [ ] Family: update child policy
- [ ] Accountability: invite partner
- [ ] Accountability: list partners
- [ ] Sync: get updated policies
- [ ] Sync: check panic status
- [ ] Rate limiting on login
- [ ] Rate limiting on register
- [ ] CORS headers present
- [ ] 404 on non-existent endpoint
- [ ] 401 without token on protected route

---

## Performance Testing

### Load Testing with `ab` (ApacheBench)

```bash
# Get 100 requests, 10 concurrent
ab -n 100 -c 10 \
  -H "Authorization: Bearer $TOKEN" \
  http://localhost:8787/api/policies
```

### Stress Testing
```bash
# Test with large payloads
curl -X POST http://localhost:8787/api/notifications/log-event \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "policy_created",
    "event_data": {
      "large_field": "'"$(printf 'x%.0s' {1..10000})"'"
    }
  }'
```

---

## Deployment Testing

### Deploy to Development
```bash
npm run deploy
```

### Deploy to Production
```bash
npm run deploy:prod
```

### Test Production Endpoints
```bash
curl -X GET https://unscroll-api-prod.yourdomain.workers.dev/
```

---

## Debugging

### Enable verbose logging
```bash
wrangler dev --log-level debug
```

### Check D1 database directly
```bash
wrangler d1 execute unscroll --remote --command "SELECT COUNT(*) FROM users;"
```

### View KV data
```bash
wrangler kv:key list --binding=KV
```

---

## Common Issues

### Token validation fails
- Check token not expired: `expires_in` is 24 hours from login
- Check Bearer prefix: `Authorization: Bearer {token}`
- Check JWT_SECRET env var is set

### Database queries fail
- Verify D1 database ID in wrangler.toml
- Check database migrations ran (all 9 tables exist)
- Check parameterized queries use `bind()` correctly

### CORS errors
- Ensure Flutter app domain added to CORS origin
- Check headers allowed: Content-Type, Authorization

### Rate limiting too strict
- Modify limits in workers/src/utils.ts
- KV keys expire automatically per `expirationTtl`
