# UnScroll Deployment Guide

Production deployment checklist for UnScroll backend and mobile apps.

---

## Phase 1: Backend Deployment (Cloudflare Workers)

### Prerequisites
- Cloudflare account
- Domain (optional but recommended)
- wrangler CLI installed

### Step 1: Set Environment Variables

Create `workers/.env.production`:
```
JWT_SECRET=your-random-32-char-secret-here
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
DATABASE_ID=ca72fab6-a375-4f0b-bea8-64aa999d29f9
KV_NAMESPACE_ID=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Step 2: Configure Cloudflare

1. **Create KV Namespace**
   ```bash
   wrangler kv:namespace create unscroll-kv
   wrangler kv:namespace create unscroll-kv --preview
   ```

2. **Update wrangler.toml**
   ```toml
   [env.production]
   route = "https://api.yourdomain.com/*"
   
   [[env.production.kv_namespaces]]
   binding = "KV"
   id = "YOUR_KV_ID"
   ```

3. **Set secrets**
   ```bash
   wrangler secret put JWT_SECRET --env production
   wrangler secret put SENDGRID_API_KEY --env production
   ```

### Step 3: Deploy

```bash
# Build
npm run build

# Test locally
npm run dev

# Deploy to production
npm run deploy:prod

# Verify
curl https://api.yourdomain.com/
# Should return: { "status": "ok", "version": "1.0.0" }
```

### Step 4: Configure CORS

Update backend to allow Flutter app origin:

```typescript
app.use(
  "*",
  cors({
    origin: "https://yourdomain.com", // Your app domain
    allowMethods: ["GET", "POST", "PUT", "DELETE"],
    allowHeaders: ["Content-Type", "Authorization"],
  })
);
```

### Step 5: Set Up Database Backups

```bash
# Enable D1 automatic backups
wrangler d1 backup enable unscroll
```

### Step 6: Monitoring

Set up error tracking:
```bash
# Install Sentry integration
npm install @sentry/cloudflare-workers
```

---

## Phase 2: Flutter App Deployment

### iOS Deployment (App Store)

#### 1. Update .env
```
BACKEND_URL=https://api.yourdomain.com
```

#### 2. Update iOS Build Settings
File: `ios/Runner/Info.plist`
```xml
<key>AppIdentifier</key>
<string>com.unscroll.app</string>
<key>MinimumOSVersion</key>
<string>14.0</string>
```

#### 3. Create Release Build
```bash
flutter build ios --release
```

#### 4. Create App Store Connect Entry
- Go to App Store Connect
- Create new app "UnScroll"
- Fill in required metadata:
  - Description: "Block Instagram Reels, YouTube Shorts, TikTok"
  - Keywords: doomscroll, addiction, recovery, focus, screen time
  - Category: Lifestyle
  - Rating: 4+
  - Price: Free

#### 5. Upload Screenshots (5-8 per language)
- Home screen
- Policy creation
- Panic button
- Analytics
- Family mode
- Accountability

#### 6. Add Privacy Policy
```
https://yourdomain.com/privacy
```

#### 7. Submit for Review
- Build upload via Xcode
- Test on TestFlight (internal testers)
- Submit for App Review

#### 8. Respond to Review Feedback
- Typically reviewed in 24-48 hours
- May request clarification on addiction recovery features

### Android Deployment (Play Store)

#### 1. Create Keystore
```bash
keytool -genkey -v -keystore ~/unscroll-key.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias unscroll-key
```

#### 2. Update android/key.properties
```
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=unscroll-key
storeFile=/path/to/unscroll-key.keystore
```

#### 3. Update pubspec.yaml
```yaml
version: 1.0.0+1
```

#### 4. Build Release APK
```bash
flutter build apk --release
```

#### 5. Create Google Play Console Entry
- Go to Google Play Console
- Create new app "UnScroll"
- Set category: Lifestyle
- Add app store listing:
  - Title: "UnScroll - Block Reels & Shorts"
  - Short description (80 chars)
  - Full description
  - Screenshots (4-8)
  - Feature graphic
  - App icon
  - Promo video (optional)

#### 6. Configure Release Management
- Go to Release > Production
- Upload signed APK/AAB
- Add release notes

#### 7. Add Privacy Policy
- Required for login + analytics
- Must include data handling practices

#### 8. Set Up Google Play Console Permissions
- Storage (for local logging)
- Internet (for API calls)
- Accessibility (Android blocker)

#### 9. Submit for Review
- Google Play typically reviews in 2-4 hours
- May request clarification on accessibility usage

### Cross-Platform Testing

#### 1. Beta Testing Setup

**iOS TestFlight:**
```bash
# Build for TestFlight
flutter build ios --build-number 1

# Upload via Xcode or Transporter app
```

**Android Google Play Internal Testing:**
```bash
flutter build appbundle --release

# Upload to Google Play Console > Testing > Internal Testing
```

#### 2. Recruit Beta Testers
- 50-100 power doomscrollers
- Addiction recovery communities
- Reddit: r/nosurf, r/nofap
- Twitter: #digitaledetox, #screentime

#### 3. Collect Feedback
- Use Firebase Crash Reporting
- In-app feedback form
- Beta tester survey

#### 4. Iterate
- Fix critical bugs within 24 hours
- Update friction levels based on feedback
- Optimize performance

---

## Phase 3: Production Monitoring

### Error Tracking (Sentry)

Install Sentry in Flutter:
```bash
flutter pub add sentry_flutter

# Initialize in main.dart
await SentryFlutter.init(
  (options) {
    options.dsn = 'https://your-sentry-dsn@sentry.io/project-id';
    options.tracesSampleRate = 1.0;
  },
);
```

### Performance Monitoring
```bash
# Monitor API response times
# Track user engagement
# Monitor crash rate
# Monitor storage usage
```

### Analytics
```bash
# Firebase Analytics (already in pubspec.yaml)
# Track feature usage
# Track user retention
# Track user cohorts
```

---

## Phase 4: Post-Launch Optimization

### App Performance
- [ ] Lazy load large lists
- [ ] Optimize images (WebP format)
- [ ] Cache API responses
- [ ] Preload common data

### Backend Optimization
- [ ] Enable D1 caching
- [ ] Optimize database queries
- [ ] Add database indexes
- [ ] Monitor API latency

### User Feedback Loop
- [ ] Weekly review of crash reports
- [ ] Monthly release cycle
- [ ] User surveys quarterly
- [ ] Feature prioritization based on feedback

---

## Deployment Checklist

### Backend (Cloudflare Workers)
- [ ] JWT_SECRET set in production
- [ ] SendGrid API key configured
- [ ] D1 database backups enabled
- [ ] KV namespace created
- [ ] CORS configured for app domain
- [ ] Error logging configured
- [ ] Rate limiting tuned
- [ ] Database indices created
- [ ] All endpoints tested
- [ ] Load testing passed

### iOS App Store
- [ ] Privacy policy published
- [ ] Screenshots captured (5-8)
- [ ] App icon 1024x1024 submitted
- [ ] Feature graphic created
- [ ] Release notes written
- [ ] Support URL provided
- [ ] TestFlight beta tested (50+ users)
- [ ] All permissions justified
- [ ] Build number incremented
- [ ] Version 1.0.0 ready

### Android Play Store
- [ ] Privacy policy published
- [ ] Screenshots captured (4-8)
- [ ] App icon 512x512 submitted
- [ ] Feature graphic created
- [ ] Release notes written
- [ ] Support URL provided
- [ ] Internal testing completed (50+ users)
- [ ] All permissions documented
- [ ] Keystore secure and backed up
- [ ] Version code incremented
- [ ] Version 1.0.0 ready

### Monitoring & Analytics
- [ ] Sentry error tracking enabled
- [ ] Firebase Analytics configured
- [ ] Backend error logging active
- [ ] Performance monitoring set up
- [ ] Crash reporting configured
- [ ] Usage analytics enabled

### Legal & Compliance
- [ ] Privacy policy compliant (GDPR, CCPA)
- [ ] Terms of service finalized
- [ ] Data deletion mechanism implemented
- [ ] User consent forms ready
- [ ] Accessibility audit completed

---

## Troubleshooting

### App Store Rejection
- **"Requires parental controls UI"** → Already implemented with Family Mode
- **"Unclear addiction recovery purpose"** → Add clear description and screenshot
- **"Requires settings app"** → Add Settings link in-app

### Play Store Rejection
- **"Accessibility service misuse"** → Clearly document usage for app blocking
- **"Storage permission unclear"** → Show permission in-app before requesting

### Backend Deployment Issues
- **"D1 quota exceeded"** → Upgrade plan or archive old data
- **"Workers timeout"** → Optimize database queries
- **"KV rate limits"** → Increase namespace size

---

## Success Metrics

### User Acquisition
- Target: 1,000 downloads in first month
- Target: 5,000 downloads by month 3
- Target: 50,000 downloads by launch + 6 months

### Engagement
- Target: 40% DAU/MAU ratio
- Target: 5+ policies per active user
- Target: 2+ panic button uses per user per month

### Retention
- Target: 30% retention after day 1
- Target: 15% retention after day 7
- Target: 10% retention after day 30

### Crash Rate
- Target: <0.1% crash rate
- Target: <5% ANR rate (Android)

---

## Rollback Plan

If deployment fails:

1. **Backend Rollback**
   ```bash
   git checkout previous-tag
   npm run deploy:prod
   ```

2. **App Rollback**
   - Remove app from App Store/Play Store
   - Release patch version from previous stable branch

3. **Data Recovery**
   - D1 supports point-in-time recovery (contact Cloudflare support)
   - KV data is automatically replicated

---

## Support

- **Deployment Issues:** deployment@unscroll.app
- **User Support:** support@unscroll.email
- **Bug Reports:** bugs@unscroll.app

---

**Ready to launch! 🚀**
