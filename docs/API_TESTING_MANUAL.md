# UnScroll API Manual Testing Guide

Production API: `https://unscroll-api-prod.sahilxleo916.workers.dev`

## Quick Test in Browser

### 1. Health Check
Open this in your browser:
```
https://unscroll-api-prod.sahilxleo916.workers.dev/
```
Expected response:
```json
{"status":"ok","version":"1.0.0"}
```

### 2. Test with curl or Postman

#### Register User
```bash
curl -X POST https://unscroll-api-prod.sahilxleo916.workers.dev/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPass123!"
  }'
```

Expected response:
```json
{
  "id": "user_...",
  "email": "test@example.com",
  "token": "eyJ...",
  "expires_in": 86400
}
```

#### Login
```bash
curl -X POST https://unscroll-api-prod.sahilxleo916.workers.dev/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPass123!"
  }'
```

#### Get User Profile (requires token)
```bash
curl -X GET https://unscroll-api-prod.sahilxleo916.workers.dev/api/user/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

#### Create Policy
```bash
curl -X POST https://unscroll-api-prod.sahilxleo916.workers.dev/api/policies \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "name": "Evening Block",
    "description": "Block reels after 10pm",
    "target_apps": ["instagram", "tiktok"],
    "blocked_content": ["reels", "shorts"],
    "friction_level": "high",
    "risk_windows": [
      {
        "day": 1,
        "start_time": "22:00",
        "end_time": "06:00"
      }
    ],
    "enabled": true
  }'
```

#### Activate Panic Button
```bash
curl -X POST https://unscroll-api-prod.sahilxleo916.workers.dev/api/panic-button/activate \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "cooldown_duration": "24h"
  }'
```

#### Log Blocked Attempt
```bash
curl -X POST https://unscroll-api-prod.sahilxleo916.workers.dev/api/blocked-attempts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "app": "instagram",
    "content_type": "reels",
    "blocked": true,
    "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
  }'
```

#### Get Analytics
```bash
curl -X GET "https://unscroll-api-prod.sahilxleo916.workers.dev/api/blocked-attempts?app=instagram&days=7" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Error Cases to Test

### 1. Missing Authorization Header
```bash
curl -X GET https://unscroll-api-prod.sahilxleo916.workers.dev/api/user/profile
```
Expected: 401 Unauthorized

### 2. Invalid Token
```bash
curl -X GET https://unscroll-api-prod.sahilxleo916.workers.dev/api/user/profile \
  -H "Authorization: Bearer invalid_token"
```
Expected: 401 Unauthorized

### 3. Non-existent Endpoint
```bash
curl -X GET https://unscroll-api-prod.sahilxleo916.workers.dev/api/nonexistent \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```
Expected: 404 Not Found

## Testing Checklist

- [ ] ✅ Health check returns 200
- [ ] Register user returns 201 with token
- [ ] Login returns 200 with token
- [ ] Get profile returns 200 with user data
- [ ] Create policy returns 201
- [ ] List policies returns 200
- [ ] Activate panic button returns 200
- [ ] Get panic status returns 200
- [ ] Log blocked attempt returns 201
- [ ] Get analytics returns 200
- [ ] Missing auth header returns 401
- [ ] Invalid token returns 401
- [ ] Non-existent endpoint returns 404

## Rate Limiting Test

The API rate limits login to 5 requests per minute.

```bash
# Test rate limiting
for i in {1..6}; do
  echo "Request $i:"
  curl -X POST https://unscroll-api-prod.sahilxleo916.workers.dev/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{
      "email": "test@example.com",
      "password": "wrong"
    }'
  sleep 1
done
```

The 6th request should return 429 Too Many Requests.

## Next Steps

Once manual tests pass:
1. Update Flutter app to use the production API URL (already in lib/.env)
2. Run Flutter integration tests against production
3. Test on iOS/Android devices
4. Monitor logs in Cloudflare dashboard
