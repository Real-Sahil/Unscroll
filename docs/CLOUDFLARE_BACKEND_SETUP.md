# UnScroll Cloudflare Backend Implementation Guide

**Status:** Planning Phase  
**Backend:** Cloudflare Workers + D1 Database  
**Estimated Time:** 24-36 hours of custom development  
**Date:** August 20, 2026

---

## Architecture Overview

```
Flutter App (iOS/Android)
    ↓ (REST API calls)
Cloudflare Workers (API Layer)
    ↓
D1 Database (SQLite)
    ↓
KV Storage (Sessions, Cache)
    ↓
External Services (Email, Claude API)
```

---

## Phase 1: Database Setup (MCP Automation)

### D1 Database Schema

**Tables to Create:**

#### 1. `users`
```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT true
);
```

#### 2. `policies`
```sql
CREATE TABLE policies (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  name TEXT NOT NULL,
  blocked_apps TEXT, -- JSON: ["instagram", "youtube", "tiktok"]
  start_time TEXT, -- HH:MM format
  end_time TEXT, -- HH:MM format
  days_of_week TEXT, -- JSON: [0,1,2,3,4,5,6]
  friction_level INTEGER DEFAULT 3, -- 1-5
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

#### 3. `blocked_attempts`
```sql
CREATE TABLE blocked_attempts (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  app_name TEXT NOT NULL,
  content_type TEXT, -- "reels", "shorts", "story", "watch"
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  blocked BOOLEAN DEFAULT true,
  notes TEXT
);
```

#### 4. `panic_button_events`
```sql
CREATE TABLE panic_button_events (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  activated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  cooldown_period INTEGER, -- seconds: 7200 (2h), 43200 (12h), 86400 (24h)
  expires_at DATETIME NOT NULL,
  acknowledged BOOLEAN DEFAULT false,
  notes TEXT
);
```

#### 5. `family_relationships`
```sql
CREATE TABLE family_relationships (
  id TEXT PRIMARY KEY,
  parent_id TEXT NOT NULL REFERENCES users(id),
  child_id TEXT NOT NULL REFERENCES users(id),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  status TEXT DEFAULT 'active' -- 'active', 'invited', 'rejected'
);
```

#### 6. `accountability_partners`
```sql
CREATE TABLE accountability_partners (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  partner_email TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  status TEXT DEFAULT 'invited' -- 'invited', 'accepted', 'declined'
);
```

#### 7. `therapist_clients`
```sql
CREATE TABLE therapist_clients (
  id TEXT PRIMARY KEY,
  therapist_id TEXT NOT NULL REFERENCES users(id),
  client_id TEXT NOT NULL REFERENCES users(id),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  notes TEXT
);
```

#### 8. `analytics_events`
```sql
CREATE TABLE analytics_events (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  event_type TEXT NOT NULL, -- "policy_created", "policy_disabled", "panic_activated"
  event_data TEXT, -- JSON payload
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

#### 9. `sessions`
```sql
CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  token TEXT NOT NULL UNIQUE,
  expires_at DATETIME NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

---

## Phase 2: Authentication System (Custom Workers Code)

### Auth Endpoints

**POST /api/auth/register**
```json
Request:
{
  "email": "user@example.com",
  "password": "secure_password",
  "name": "John Doe"
}

Response:
{
  "id": "user_123",
  "email": "user@example.com",
  "token": "jwt_token_here",
  "expires_in": 86400
}
```

**POST /api/auth/login**
```json
Request:
{
  "email": "user@example.com",
  "password": "secure_password"
}

Response:
{
  "id": "user_123",
  "email": "user@example.com",
  "token": "jwt_token_here",
  "expires_in": 86400
}
```

**POST /api/auth/refresh**
```json
Request:
{
  "refresh_token": "refresh_token_here"
}

Response:
{
  "token": "new_jwt_token",
  "expires_in": 86400
}
```

### Authentication Flow

1. User registers/logs in via Flutter app
2. Workers generate JWT token
3. Token stored in KV cache for fast validation
4. All subsequent requests include `Authorization: Bearer {token}` header
5. Middleware validates JWT and adds user context

---

## Phase 3: Core API Endpoints

### Policy Management

**POST /api/policies**
- Create new protection policy
- Auth: Required
- Body: name, blocked_apps[], start_time, end_time, days_of_week, friction_level

**GET /api/policies**
- List user's policies
- Auth: Required

**PUT /api/policies/:id**
- Update policy
- Auth: Required

**DELETE /api/policies/:id**
- Delete policy
- Auth: Required

### Blocked Attempts

**POST /api/blocked-attempts**
- Log blocked access attempt
- Auth: Required
- Body: app_name, content_type, blocked, notes

**GET /api/blocked-attempts**
- Get user's blocked attempts (analytics)
- Auth: Required
- Query: start_date, end_date, app_name

### Panic Button

**POST /api/panic-button/activate**
- Activate emergency protection
- Auth: Required
- Body: cooldown_period (2h/12h/24h), notes

**GET /api/panic-button/status**
- Check if panic protection is active
- Auth: Required

**POST /api/panic-button/acknowledge**
- Acknowledge panic activation
- Auth: Required

### User Profile

**GET /api/user/profile**
- Get user details
- Auth: Required

**PUT /api/user/profile**
- Update profile
- Auth: Required

**POST /api/user/stats**
- Get user statistics (relapse count, streak, etc.)
- Auth: Required

---

## Phase 4: Family Mode APIs

**POST /api/family/invite-child**
- Send invite to child's email
- Auth: Required (parent)
- Body: child_email

**POST /api/family/accept-invite**
- Accept family invitation
- Auth: Required (child)
- Body: invitation_token

**GET /api/family/children**
- List parent's children
- Auth: Required (parent)

**GET /api/family/child/:id/summary**
- Get child's summary (compliance, stats)
- Auth: Required (parent)
- Permissions: Only child's parent can view

**PUT /api/family/child/:id/policies**
- Update child's policies (parent-controlled)
- Auth: Required (parent)
- Permissions: Only child's parent can modify

---

## Phase 5: Accountability & Therapist APIs

**POST /api/accountability/invite-partner**
- Invite accountability partner
- Auth: Required
- Body: partner_email

**POST /api/accountability/weekly-summary**
- Send weekly summary email to partner
- Auth: Internal (scheduled via cron)
- Body: user_id

**GET /api/therapist/clients**
- List therapist's clients
- Auth: Required (therapist)

**GET /api/therapist/client/:id/analytics**
- Get client analytics (protected)
- Auth: Required (therapist)
- Permissions: Only assigned therapist can view

---

## Phase 6: Real-time & Sync

### Option A: Polling (Simpler)
- Flutter app polls `/api/policies/last-sync` every 30 seconds
- Returns updated policies since last sync
- Server-side: Track last_modified_at on each policy

### Option B: WebSocket (More Complex)
- Establish WebSocket connection to Workers
- Server pushes policy updates
- Requires persistent connection management
- Better battery/network efficiency

**Recommendation: Start with Polling (Phase 1), upgrade to WebSocket (Phase 2)**

---

## Phase 7: Email & Notifications

### Weekly Summary Email (via Cron)
```typescript
// Send to accountability partner every Sunday
POST /api/accountability/send-weekly-summaries
- Query all users with active partners
- Calculate stats (blocked attempts, relapse count, streak)
- Send email via Resend or SendGrid
```

### Policy Generation from Prompts
```typescript
// Generate policy recommendations using Claude API
POST /api/policies/generate-from-prompt
Body: {
  prompt: "I struggle with Instagram Reels late at night",
  goals: ["sleep", "focus"]
}
Response: {
  suggested_policy: {
    blocked_apps: ["instagram"],
    start_time: "22:00",
    end_time: "07:00",
    friction_level: 4
  }
}
```

---

## Flutter App Integration

### Environment Configuration

Create `.env` file in Flutter project:
```
BACKEND_URL=https://unscroll.yourdomain.workers.dev
API_VERSION=v1
```

### API Client Setup

```dart
// lib/services/api_service.dart
class ApiService {
  final String baseUrl = dotenv.env['BACKEND_URL'] ?? '';
  late String? authToken;

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      // Token expired, refresh
      await refreshToken();
    }

    return jsonDecode(response.body);
  }
}
```

### Authentication Flow

```dart
// 1. Register
final result = await apiService.post('/auth/register', {
  'email': email,
  'password': password,
  'name': name,
});

apiService.authToken = result['token'];
await storage.write('auth_token', result['token']);

// 2. On app restart, restore token
final token = await storage.read('auth_token');
if (token != null) {
  apiService.authToken = token;
}
```

---

## Implementation Timeline

| Phase | Task | Estimated Time | Status |
|-------|------|-----------------|--------|
| 1 | D1 Database Setup (MCP) | 30 mins | ✅ Complete |
| 2 | Authentication Workers | 4-5 hours | 📝 Next |
| 3 | Core API Endpoints | 6-8 hours | 📋 Planned |
| 4 | Family Mode APIs | 3-4 hours | 📋 Planned |
| 5 | Accountability APIs | 2-3 hours | 📋 Planned |
| 6 | Real-time Polling | 2-3 hours | 📋 Planned |
| 7 | Email & Notifications | 3-4 hours | 📋 Planned |
| 8 | Flutter Integration | 4-6 hours | 📋 Planned |
| 9 | Testing & Debugging | 4-6 hours | 📋 Planned |

**Total: 28-40 hours**

---

## Phase 1 Completion Details

**Database ID:** `ca72fab6-a375-4f0b-bea8-64aa999d29f9`  
**Region:** WNAM (Western North America)  
**Completed:** 2026-08-20  
**Status:** All 9 tables created and ready for API implementation

### Tables Created:
- ✅ users (authentication & profiles)
- ✅ policies (protection policies)
- ✅ blocked_attempts (usage analytics)
- ✅ panic_button_events (emergency protection)
- ✅ family_relationships (parent-child links)
- ✅ accountability_partners (accountability system)
- ✅ therapist_clients (therapist dashboard)
- ✅ analytics_events (event tracking)
- ✅ sessions (authentication tokens)

### Next: Phase 2 - Authentication Workers

The foundation is ready. Next step is building the Workers API layer with JWT authentication, register/login/refresh endpoints, and secure token management via KV storage.

---

## Tools & Dependencies

**Cloudflare Workers:**
- `wrangler` CLI for local development
- `typescript` for type safety
- `jose` for JWT handling
- `hono` framework (recommended for routing)

**D1 Database:**
- Native SQLite support in Workers
- No external dependencies needed

**Flutter App:**
- `http` package for API calls
- `flutter_secure_storage` for token storage
- `dotenv` for environment variables

**Optional:**
- Resend or SendGrid for emails
- Claude API for policy generation

---

## Security Considerations

1. **JWT Tokens**
   - Sign with secret key stored in Workers environment
   - Set expiry to 24 hours
   - Use refresh tokens for longer sessions

2. **Password Hashing**
   - Use bcrypt or Argon2 for password hashing
   - Never store plain passwords
   - Implement rate limiting on login attempts

3. **CORS**
   - Configure CORS headers in Workers
   - Allow requests from your Flutter app domain

4. **RLS (Access Control)**
   - Implement middleware to verify user permissions
   - Prevent parents from accessing other parents' children
   - Therapists can only view their own clients

5. **Rate Limiting**
   - Limit login attempts: 5 per minute per email
   - Limit API calls: 100 per minute per user
   - Use Cloudflare's built-in rate limiting

---

## Next Steps

1. ✅ **Phase 1:** Create D1 database (via MCP)
2. 📝 **Phase 2:** Build authentication Workers
3. 📝 **Phase 3:** Implement core API endpoints
4. 📝 **Phase 4+:** Continue with remaining phases
5. 🧪 **Testing:** Test each API before moving to next phase

---

**Ready to start? Let's begin with Phase 1: Database Setup!**
