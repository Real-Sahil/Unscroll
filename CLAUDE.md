# UnScroll - Reclaim Your Time. Escape the Doomscroll.

## Project Overview

UnScroll is a production-grade Flutter mobile application designed to help users with compulsive short-form video consumption (Instagram Reels, YouTube Shorts, TikTok) regain control through relapse-resistant design, friction layers, panic buttons, and accountability partnerships.

**Target Users:**
- Adults losing 30-60+ minutes/day to Reels/Shorts
- Parents managing teens with heavy short-form use
- Users in digital addiction recovery
- Therapists/coaches supporting clients

**Core Value Proposition:**
- Block Reels & Shorts by default with relapse-resistant controls
- Keep Instagram/YouTube useful for DMs, work, and learning
- Designed explicitly for addiction recovery, not just "digital wellbeing"

---

## Technology Stack

### Frontend
- **Framework:** Flutter 3.0+ with Dart 3.0+
- **State Management:** Provider 6.4.0 + Riverpod 2.4.0
- **Architecture:** Clean architecture (domain/data/presentation layers)
- **Storage:** 
  - Secure storage via `flutter_secure_storage` (Keychain/Keystore)
  - Local caching via `hive_flutter` for policies
  - SharedPreferences for app settings
- **Authentication:** Supabase Auth + Local biometric (local_auth)
- **Animations:** Rive 0.11.0 for breathing effects, Flutter animations for transitions
- **Notifications:** flutter_local_notifications + Firebase Cloud Messaging

### Backend
- **Database:** Supabase (PostgreSQL) with Row-Level Security (RLS)
- **API:** Supabase Realtime for multi-device sync
- **Serverless Functions:** Deno-based Edge Functions for:
  - Family invite/accept flows
  - Policy generation from user prompts
  - Weekly accountability email summaries
  - Relapse pattern analysis
- **Auth:** Supabase Auth (email/OAuth)

### Platform-Specific
- **iOS:** Screen Time Integration, Safari Web Extension
- **Android:** AccessibilityService for app detection, Device Admin API

### Browser Extensions
- **Safari & Chrome:** Content blocking via DOM manipulation, route redirects

---

## Project Structure

```
unscroll/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── config/
│   │   ├── theme.dart              # Material 3 design system (calm & supportive)
│   │   ├── routes.dart             # Route definitions
│   │   └── constants.dart          # App-wide constants
│   ├── core/
│   │   ├── di/                     # Dependency injection setup
│   │   ├── errors/                 # Custom exceptions
│   │   ├── utils/                  # Utility functions
│   │   └── widgets/                # Shared UI components
│   ├── features/
│   │   ├── auth/                   # Authentication (login/signup)
│   │   ├── onboarding/             # First-time user flow (risk windows, goals)
│   │   ├── home/                   # Main dashboard (status, panic button)
│   │   ├── policies/               # Policy management UI
│   │   ├── friction_engine/        # PIN, urge-surf, confirmation flows
│   │   ├── panic_button/           # Panic button logic & UI
│   │   ├── relapse_log/            # Analytics, patterns, charts
│   │   ├── accountability/         # Partner view, email summaries
│   │   ├── family_mode/            # Parent/child management
│   │   └── settings/               # App settings, preferences
│   └── services/
│       ├── supabase_service.dart   # Supabase client & auth
│       ├── policy_engine.dart      # Local policy enforcement
│       ├── notification_service.dart
│       └── accessibility_service.dart
├── ios/                            # iOS-specific code (Screen Time, Safari)
├── android/                        # Android-specific code (AccessibilityService)
├── test/                           # Unit & integration tests
├── supabase/
│   ├── migrations/
│   │   └── 001_init_schema.sql    # Database schema + RLS policies
│   └── functions/                  # Edge Functions (Deno)
├── design/                         # Branding, logos (designer-provided)
├── pubspec.yaml                    # Dart dependencies
└── CLAUDE.md                       # This file
```

---

## Design System (Calm & Supportive)

### Color Palette
- **Primary:** Blues (#0066CC, #00A3FF, #0052A3) - Trust, calm
- **Secondary:** Greens (#00AA66, #00D686, #008052) - Recovery, growth
- **Accent:** Orange (#FF8C00) - Panic button only, urgency
- **Neutrals:** Whites (#F5F5F5), Grays (#666666), Blacks (#1A1A1A)

### Typography
- **Headings:** Poppins (Bold, 600/700 weight) - Clear hierarchy
- **Body:** Inter (Regular/Medium, 400/500 weight) - Readability

### Key Components
1. **FrictionDialog** - Full-screen modal with breathing animation, countdown, typed confirmation
2. **PanicButton** - Large, floating action button with haptic feedback
3. **RelapsChart** - Local-generated charts showing patterns by time-of-day
4. **PolicyCard** - Status indicator for active policies
5. **UrgeCoach** - Motivational overlay during crisis moments

### Animations
- Breathing animation (8-10s cycle) using Rive or SVG
- Smooth transitions between screens (Material Motion)
- Haptic feedback on critical interactions
- Dark mode support with calming darker palette

---

## Core Features

### MVP (Priority 1-2)
1. **Onboarding Flow**
   - Risk window identification (time picker + days)
   - Goal selection (Sleep, Work, Relationships, Mood)
   - Permission grants (biometric, notifications)
   - Default hard-block preview

2. **Home Screen**
   - Focus Mode status (ON/OFF + icon)
   - Prominent Panic Button
   - Daily summary (relapse count, time saved)
   - Quick settings access

3. **Friction Engine** (Core)
   - PIN/biometric authentication
   - 10-30s urge-surf screen with breathing animation + countdown
   - Typed confirmation phrase (e.g., "I accept I may lose 30+ minutes")
   - Consequence preview before allowing disable
   - 24-hour cooldown after disable

4. **Panic Button**
   - One-tap "End Session" to hard-block all short-form
   - Configurable cooldown (2h, 12h, 24h)
   - Relapse event logging

5. **Relapse Log** (Private)
   - Time series of disable/panic events
   - Pattern detection (most relapses after 11pm, etc.)
   - Simple bar/line charts

6. **Platform-Specific Blocking**
   - **iOS:** Safari Web Extension hiding Reels/Shorts, Screen Time integration
   - **Android:** AccessibilityService detecting short-form apps, overlay UI

### v1 Features (Priority 3-4)
- Family mode (parent sets policies for children)
- Accountability partnerships (weekly email summaries to trusted person)
- Commitment contracts (goal setting, streak tracking)
- Therapist/coach dashboard (aggregated analytics)
- Enhanced UX (dark mode, animations, haptic feedback)

---

## Security & Privacy (OWASP Aligned)

### Authentication & Access Control
- Biometric + PIN required for sensitive operations (policy changes, disable protection)
- Session timeouts after 15 minutes of inactivity
- Secure token storage via flutter_secure_storage
- Supabase RLS policies enforce user boundaries

### Data Encryption
- PIN stored as PBKDF2 hash with 32-byte salt
- Sensitive relapse data encrypted at rest (Supabase encryption)
- TLS 1.3 for all network communication
- Certificate pinning optional for Supabase

### Input Validation
- All policy JSON validated before storage
- Deeplink routing validated (scheme + host verification)
- SQL injection prevented by Supabase parameterized queries

### Privacy
- Policies are user-owned; parents can only access own child policies
- Partners see aggregated summaries only (no raw relapse data)
- No telemetry without explicit opt-in
- GDPR-compliant data export/deletion

### Risk Mitigations
- 24-hour uninstall cooldown (server-side, can't be circumvented)
- Friction layers prevent impulsive disabling
- Cooldowns enforce time-based recovery
- Optional email notifications for accountability

---

## Development Workflow

### Branch Strategy
- **Feature branch:** `feature/feature-name`
- **Bugfix branch:** `fix/bug-name`
- **Release branch:** `release/v1.x`
- Main development: `claude/dart-mobile-content-blocker-11wcm3`

### Testing Requirements
- Unit tests for policy engine (time-window logic, friction state)
- Integration tests for Supabase interactions
- E2E tests for onboarding + friction flows
- Manual testing on physical iOS + Android devices
- Accessibility testing (WCAG 2.1 AA)

### Code Quality
- Use clean architecture (domain/data/presentation layers)
- Dependency injection for testability
- Freeze / JSON serialization for data models
- No hardcoded values; use constants.dart
- Comprehensive error handling

### Deployment Pipeline
1. **Internal Testing:** TestFlight (iOS) + Google Play Internal (Android)
2. **Beta Testing:** 50-100 users (doomscroll communities, Reddit, ProductHunt)
3. **Production:** App Store + Play Store submission with recovery-focused description

---

## Environment Setup

### Prerequisites
- Flutter 3.0+ with Dart 3.0+
- Xcode 14+ (iOS development)
- Android Studio / SDK (Android development)
- Supabase account (free tier supported)

### Local Development
```bash
# Clone and setup
git clone https://github.com/Real-Sahil/Unscroll.git
cd Unscroll

# Copy environment
cp .env.example .env
# Edit .env with your Supabase credentials

# Install dependencies
flutter pub get

# Run on device
flutter run -d ios    # or -d android
```

### Supabase Setup
1. Create project at https://app.supabase.com
2. Run migrations: `supabase db push` (or copy SQL from migrations/ to dashboard)
3. Configure RLS policies (automated in migrations)
4. Generate TypeScript types (optional): `supabase gen types`

---

## Success Metrics

- **Onboarding:** >80% completion rate in first week
- **Relapse Rate:** <30% disable protection in high-risk windows
- **Recovery Time:** <1 hour for 70% of users to re-enable protection after disable
- **Panic Button:** Track adoption + timing patterns
- **Retention:** WAU/MAU for heavy users (60+ min/day doomscroling)

---

## Next Steps

1. **Week 1-2 (Foundation)**
   - [ ] Complete Flutter setup (iOS + Android)
   - [ ] Supabase schema deployment
   - [ ] Integrate design system from designer
   - [ ] Home screen scaffold

2. **Week 3-5 (Core MVP)**
   - [ ] Onboarding flow
   - [ ] Policy engine
   - [ ] Friction engine (PIN + urge-surf + confirmation)
   - [ ] Panic button
   - [ ] Platform-specific blocking

3. **Week 6-7 (Analytics)**
   - [ ] Relapse log + pattern detection
   - [ ] Realtime multi-device sync
   - [ ] Usage event collection

4. **Week 8-9 (Family Mode)**
   - [ ] Family invite flow
   - [ ] Parent dashboard
   - [ ] Child policy management

5. **Week 10-12 (Polish & Launch)**
   - [ ] Advanced features
   - [ ] Security audit
   - [ ] Beta testing
   - [ ] App Store submission

---

## Resources

- **Design System:** Figma (designer provides)
- **Supabase Docs:** https://supabase.com/docs
- **Flutter Docs:** https://flutter.dev/docs
- **Material 3 Guidelines:** https://m3.material.io
- **OWASP Top 10:** https://owasp.org/www-project-top-ten/

---

## Contributing

This is an active development project for an addiction-recovery app. All contributions must maintain:
- Non-judgmental, compassionate tone
- Security-first design decisions
- Accessibility standards (WCAG 2.1 AA)
- Privacy of sensitive relapse data

For questions or discussions, open an issue or contact the maintainers.

---

**Last Updated:** August 19, 2026
**Status:** Active Development (Week 1-2 Foundation Phase)
