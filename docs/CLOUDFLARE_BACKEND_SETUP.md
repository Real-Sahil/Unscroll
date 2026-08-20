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
| 2 | Authentication Workers | 4-5 hours | ✅ Complete |
| 3 | Core API Endpoints | 6-8 hours | ✅ Complete |
| 4 | Family Mode APIs | 3-4 hours | 📝 Next |
| 5 | Accountability APIs | 2-3 hours | 📋 Planned |
| 6 | Real-time Polling | 2-3 hours | 📋 Planned |
| 7 | Email & Notifications | 3-4 hours | 📋 Planned |
| 8 | Flutter Integration | 4-6 hours | 📋 Planned |
| 9 | Testing & Debugging | 4-6 hours | 📋 Planned |

**Total: 28-40 hours**  
**Progress: 3/9 phases complete (33% of total scope)**

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

## Phase 2 Implementation: Authentication Workers

**Status:** ✅ Complete  
**Completed:** 2026-08-20  
**Files Created:** 6 TypeScript + configuration files

### Authentication System Architecture

```
Flutter App
    ↓ (REST API + JWT Token)
Cloudflare Workers (Hono Framework)
    ↓ (Query/Validate)
D1 Database + KV Cache
    ↓
JWT Token (24-hour expiry)
```

### Files Created

1. **workers/wrangler.toml** - Cloudflare Workers configuration
   - D1 database binding (ID: ca72fab6-a375-4f0b-bea8-64aa999d29f9)
   - KV namespace binding for session caching
   - Production + development environments

2. **workers/package.json** - Dependencies
   - `hono` - Lightweight web framework for Workers
   - `jose` - JWT signing and verification
   - `typescript` - Type safety

3. **workers/tsconfig.json** - TypeScript configuration
   - ES2020 target for Cloudflare Workers runtime
   - Strict type checking enabled

4. **workers/src/index.ts** - Main application
   - Hono app initialization
   - Global CORS configuration
   - Authentication middleware
   - Route handlers

5. **workers/src/utils.ts** - Cryptographic utilities
   - `generateJWT()` - Create signed JWT tokens (24-hour expiry)
   - `verifyJWT()` - Validate JWT tokens
   - `hashPassword()` - SHA-256 password hashing
   - `validateEmail()` - Email format validation
   - `validatePassword()` - Password strength validation (8+ chars)
   - `rateLimitCheck()` - KV-backed rate limiting
   - `generateUserId()` - Unique user ID generation
   - `generateSessionId()` - Session ID generation

6. **workers/src/auth.ts** - Authentication endpoints

### Implemented Endpoints

#### POST /api/auth/register
Creates new user account.
- **Request:** email, password (8+ chars), name (optional)
- **Validation:** Email format, password strength
- **Rate Limiting:** 5 attempts/hour per email via KV
- **Returns:** User ID, email, JWT token, 24-hour expiry
- **Status Codes:** 201 (created), 400 (validation), 409 (duplicate), 429 (rate limited)

#### POST /api/auth/login
Authenticates user and returns JWT token.
- **Request:** email, password
- **Rate Limiting:** 5 attempts/minute per email via KV
- **Token Caching:** Token stored in KV for fast validation on subsequent requests
- **Returns:** User ID, email, JWT token, 24-hour expiry
- **Status Codes:** 200 (success), 401 (invalid), 429 (rate limited)

#### POST /api/auth/refresh
Generates new JWT token from existing token.
- **Request:** refresh_token (valid JWT)
- **Returns:** New JWT token, 24-hour expiry
- **Status Codes:** 200 (success), 401 (invalid)

### Security Features Implemented

1. **JWT Token Management**
   - HS256 signing with secret key
   - 24-hour expiration
   - Standard claims (iss, sub, iat, exp)
   - KV cache for fast token validation

2. **Password Security**
   - SHA-256 hashing (production: should upgrade to Argon2)
   - No plaintext password storage
   - Password strength requirement (8+ characters)

3. **Rate Limiting**
   - Login attempts: 5 per minute per email
   - Registration attempts: 5 per hour per email
   - KV-backed with automatic expiration

4. **Input Validation**
   - Email format validation
   - Password strength validation
   - Required field checking

5. **CORS Security**
   - Configurable origin (set to Flutter app domain in production)
   - Allows specific HTTP methods
   - Allows Authorization and Content-Type headers

### Middleware Chain

```
Incoming Request
    ↓
CORS Middleware (allow cross-origin requests)
    ↓
Public routes (/api/auth/...) → Skip authentication
Protected routes (/api/...) → Require Bearer token
    ↓
Token Verification (JWT signature + expiry check)
    ↓
Route Handler (userId available in context)
```

### Local Development Setup

```bash
# Install dependencies
npm install

# Run locally
npm run dev

# Test register
curl -X POST http://localhost:8787/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass123","name":"Test User"}'

# Test login
curl -X POST http://localhost:8787/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass123"}'
```

### Production Deployment

```bash
# Configure wrangler with Cloudflare credentials
wrangler login

# Deploy to production
npm run deploy:prod
```

### Known Limitations & Future Improvements

1. **Password Hashing:** Current SHA-256 implementation is basic. 
   - **Improvement:** Upgrade to Argon2 or bcrypt for production
   - **Impact:** Better protection against brute-force attacks

2. **JWT Secret Management:**
   - **Current:** Stored in Cloudflare environment variable
   - **Improvement:** Rotate secrets periodically, use secret management service

3. **Refresh Token Rotation:**
   - **Current:** Accepts any valid JWT as refresh token
   - **Improvement:** Implement separate refresh token table with rotation logic

4. **Error Messages:**
   - **Current:** Generic "Invalid credentials" to prevent email enumeration
   - **Production:** Ensure consistent error handling across all endpoints

### Next Steps

Phase 3 implementation will add:
1. Policy management endpoints (create, read, update, delete)
2. Blocked attempts logging
3. Panic button activation
4. User profile endpoints
5. Basic authorization checks (users can only access own data)

---

## Phase 3 Implementation: Core API Endpoints

**Status:** ✅ Complete  
**Completed:** 2026-08-20  
**Files Created:** 4 TypeScript endpoint modules + updated main app

### Core Features Implemented

#### 1. Policy Management Endpoints
**File:** `workers/src/policies.ts`

**POST /api/policies** - Create protection policy
- Required fields: name, blocked_apps[], start_time, end_time, days_of_week
- Optional: friction_level (1-5, default 3)
- Validates: at least one blocked app, start/end times, at least one day selected
- Returns: policy object with generated ID and timestamp
- Status: 201 (created), 400 (validation error)

**GET /api/policies** - List all user's policies
- Returns: array of policies with parsed JSON fields (blocked_apps, days_of_week)
- Ordered by created_at DESC
- Status: 200 (success)

**PUT /api/policies/:id** - Update policy
- Partial updates supported (any field combination)
- Validates: policy ownership
- Automatically updates updated_at timestamp
- Status: 200 (success), 403 (unauthorized), 404 (not found)

**DELETE /api/policies/:id** - Delete policy
- Validates: policy ownership
- Status: 200 (success), 403 (unauthorized), 404 (not found)

#### 2. Blocked Attempts Tracking
**File:** `workers/src/blocked-attempts.ts`

**POST /api/blocked-attempts** - Log blocked access attempt
- Required fields: app_name
- Optional: content_type (reels, shorts, story, watch), blocked (default true), notes
- Automatically timestamps
- Returns: attempt object
- Status: 201 (created), 400 (validation)

**GET /api/blocked-attempts** - Analytics & history
- Query parameters (all optional):
  - start_date: Filter from date
  - end_date: Filter to date
  - app_name: Filter by app
- Returns: array of attempts + aggregated statistics
- Statistics include:
  - total, blocked, allowed counts
  - breakdown by app
  - breakdown by content type
- Limited to 100 results
- Status: 200 (success)

#### 3. Panic Button Activation
**File:** `workers/src/panic-button.ts`

**POST /api/panic-button/activate** - Emergency protection
- Required: cooldown_period (7200=2h, 43200=12h, 86400=24h seconds)
- Optional: notes
- Validates: only valid cooldown periods accepted
- Calculates: expires_at based on cooldown
- Returns: event object with activation details
- Status: 201 (created), 400 (validation error)

**GET /api/panic-button/status** - Check active protection
- Returns: active boolean + current_event (if active)
- Includes: time_remaining_seconds calculation
- Filters: only non-expired events
- Status: 200 (success)

**POST /api/panic-button/acknowledge** - Mark event as acknowledged
- Required: event_id
- Validates: event ownership
- Status: 200 (success), 403 (unauthorized), 404 (not found)

#### 4. User Profile & Statistics
**File:** `workers/src/user.ts`

**GET /api/user/profile** - User details
- Returns: id, email, name, created_at, is_active
- Status: 200 (success), 404 (not found)

**PUT /api/user/profile** - Update profile
- Editable: name field
- Automatically updates: updated_at timestamp
- Status: 200 (success), 400 (validation)

**POST /api/user/stats** - User statistics
- Calculates: 
  - relapse_stats: total_blocked_attempts, total_allowed_attempts, current_streak_days
  - panic_stats: total_activations, weekly_activations (last 7 days)
- Streak calculation: days since last allowed attempt
- Status: 200 (success)

### Security & Data Isolation

All endpoints enforce:
1. **Authentication:** Bearer token required (validated JWT)
2. **Authorization:** Users can only access own data
  - Policies: filtered by user_id
  - Blocked attempts: filtered by user_id
  - Panic events: ownership check on modify operations
  - User profile: only own profile accessible
3. **Validation:** Input validation on all POST/PUT operations
4. **Timestamps:** Automatic CURRENT_TIMESTAMP on creates/updates

### Request/Response Examples

**Create Policy:**
```bash
curl -X POST http://localhost:8787/api/policies \
  -H "Authorization: Bearer {token}" \
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

**Activate Panic Button:**
```bash
curl -X POST http://localhost:8787/api/panic-button/activate \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "cooldown_period": 86400,
    "notes": "Need emergency block for today"
  }'
```

**Get User Stats:**
```bash
curl -X POST http://localhost:8787/api/user/stats \
  -H "Authorization: Bearer {token}"
```

### Implementation Details

**Policies Module:**
- JSON serialization: blocked_apps, days_of_week stored as JSON strings
- Parsed on GET responses for client consumption
- Partial update support via conditional query building

**Analytics Module:**
- Statistics calculated from blocked_attempts records
- Aggregation: by app, by content type
- Time-based filtering: start_date/end_date queries

**Panic Button:**
- Cooldown stored in seconds (7200, 43200, 86400)
- Validation: only accept predefined periods
- Time calculation: server-side expiry timestamp
- Active filter: expires_at > NOW

**User Module:**
- Streak calculation: days between now and last relapse
- Weekly stats: filter by timestamp > (now - 7 days)
- Aggregation: COUNT(*) queries with conditional blocking

### Database Integration

All endpoints use D1 with:
- Prepared statements to prevent SQLi
- Bind parameters for dynamic values
- `.first()` for single row queries
- `.all()` for multiple rows
- Automatic timestamp handling via DEFAULT CURRENT_TIMESTAMP

### Error Handling

Consistent error responses:
- 400 Bad Request: Validation errors (missing fields, invalid formats)
- 401 Unauthorized: Missing or invalid token
- 403 Forbidden: User lacks permission (e.g., accessing other user's policy)
- 404 Not Found: Resource doesn't exist
- 201 Created: Successful resource creation
- 200 OK: Successful request/update

### File Structure After Phase 3

```
workers/src/
├── index.ts              # Main app + middleware + routes
├── auth.ts              # Authentication (register, login, refresh)
├── policies.ts          # Policy management (CRUD)
├── blocked-attempts.ts  # Analytics & relapse logging
├── panic-button.ts      # Emergency protection
├── user.ts              # Profile & stats
└── utils.ts             # JWT, hashing, validation, rate limiting
```

### Performance Considerations

1. **Database Queries:**
   - Policies: indexed by user_id for fast list
   - Blocked attempts: indexed by user_id, timestamp for range queries
   - Panic events: indexed by user_id, expires_at for active filter

2. **Response Caching:**
   - KV cache not used for GET endpoints (data freshness priority)
   - Could cache user profiles (low-change data) in future

3. **Batch Operations:**
   - Future: Add batch delete policies, batch log attempts

### Known Limitations & Future Work

1. **Pagination:** GET endpoints return first 100 results
   - Future: Implement cursor-based pagination

2. **Sorting:** Hardcoded sort orders (created_at DESC)
   - Future: Allow client-specified sort

3. **Filtering:** Basic filter support (date range, app name)
   - Future: Complex filter combinations, regex support

4. **Transactions:** Single-statement operations only
   - Future: Multi-statement transactions for data consistency

### Next Steps

Phase 4 will implement family mode features:
- POST /api/family/invite-child
- POST /api/family/accept-invite
- GET /api/family/children
- GET /api/family/child/:id/summary
- PUT /api/family/child/:id/policies (parent-controlled)

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
