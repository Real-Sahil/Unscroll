# UnScroll Beta Launch & App Store Submission Guide

## Overview
This guide covers the complete process for beta testing, app store submission, and public launch of the UnScroll addiction-recovery app.

---

## Phase 1: Beta Testing (4-6 weeks)

### 1.1 Beta Tester Recruitment

**Target Audience:**
- 50-100 heavy doomscroller users (30-60+ min/day on Reels/Shorts)
- Mix of iOS (25) and Android (25) devices
- Age 18-40 with varying tech literacy
- Recovery-focused communities (Reddit, support groups)

**Recruitment Channels:**
```
Reddit:
- r/nosurf (No Surfing community)
- r/StopGaming (Addiction recovery)
- r/productivity
- r/internetfasting

Communities:
- Digital Minimalism forums
- Addiction recovery groups
- Productivity communities
- University student services

Social Media:
- ProductHunt early access
- Twitter @unscroll_app
- Recovery-focused hashtags (#digitaldetox #nosurf)
```

**Recruitment Form:**
```
1. Current daily usage (Reels/Shorts/TikTok in minutes)
2. Device(s) to test on (iOS/Android)
3. Recovery goals (sleep, focus, relationships, mood)
4. Willingness to provide feedback (weekly)
5. Availability (6-week commitment)
```

### 1.2 Beta Testing Phases

**Phase 1A: Internal Testing (Week 1-2)**
- Small group (5-10 team members + close friends)
- Core functionality verification
- Basic friction testing
- Android/iOS platform testing
- Fix critical bugs before external beta

**Phase 1B: Closed Beta (Week 3-4)**
- 30-50 external testers
- Real-world usage scenarios
- Friction level feedback
- Cooldown effectiveness
- UX/onboarding improvements
- Performance on low-end devices

**Phase 1C: Open Beta (Week 5-6)**
- 50-100+ testers
- Final refinements
- Marketing feedback
- App store submission preparation
- Production readiness validation

### 1.3 Beta Testing Metrics

**Quantitative Metrics to Track:**
```
# Engagement
- Daily Active Users (DAU)
- Session duration
- Features used per session
- Onboarding completion rate (target: >80%)

# Friction Effectiveness
- Policy disable attempts
- Time from attempt to re-enable
- Panic button usage frequency
- Relapse detection accuracy

# Technical
- Crash rate (<0.1%)
- Performance (startup <2s)
- Memory usage (<100MB)
- Battery impact (<5% drain/hour)

# Retention
- 7-day retention (target: >60%)
- 14-day retention (target: >40%)
- 30-day retention (target: >25%)

# Satisfaction
- Net Promoter Score (NPS) (target: >40)
- In-app rating (target: >4.0 stars)
- Friction effectiveness rating
```

**Qualitative Feedback:**
- Weekly surveys (Google Forms / Typeform)
- One-on-one user interviews (5-10 testers/phase)
- Discord/Slack channel for feedback
- Bug reports via in-app crash reporting

### 1.4 Beta Feedback Loop

**Weekly Cadence:**
```
Monday: Deploy new build
Tuesday-Wednesday: Testers use app
Thursday: Collect feedback (surveys, interviews)
Friday: Prioritize fixes and features
Weekend: Development & testing

Next Monday: Deploy next build
```

**Feedback Template:**
```
What went well?
- [Specific feature/experience]

What needs improvement?
- [Friction too high/low, UX unclear, feature missing]

Would you recommend to a friend?
- [Yes/No/Maybe]

Additional comments?
- [Any other feedback]
```

---

## Phase 2: App Store Submission (2 weeks)

### 2.1 iOS App Store Submission

**Pre-Submission Checklist:**
```
□ Build & code signing
  □ Release build created
  □ Code signed with production certificate
  □ Provisioning profile valid

□ App metadata
  □ App name finalized
  □ Subtitle: "Block Reels & Shorts"
  □ Description (160 char): Compelling 30-second pitch
  □ Keywords: "app blocker, focus mode, addiction recovery"
  □ Category: Health & Fitness (or Productivity)
  □ Content rating completed
  □ Privacy policy linked (GDPR/CCPA compliant)
  □ Terms of service linked

□ Screenshots & preview
  □ 5-6 screenshots per device size (iPhone, iPad)
  □ Showcase key features (home, friction, panic button)
  □ Text overlays: "Block Reels", "Recover Your Time"
  □ Preview video (15-30s showing core flow)

□ Ratings & review
  □ Age rating completed (Health & Fitness: 17+)
  □ Content description checked
  □ Export Compliance verified (encryption)

□ Testing
  □ All features tested on iPhone 15, 14, 13
  □ Crash testing on iOS 16, 17
  □ Screen Time permission working
  □ Deep linking tested
```

**App Store Connect Setup:**
1. Navigate to App Store Connect
2. Create new app
3. Fill out app information:
   ```
   App Name: UnScroll
   Bundle ID: com.unscroll.app
   SKU: UNSCROLL-001
   Platform: iOS
   ```
4. Add screenshots (5 per device):
   - Home screen with policy status
   - Friction dialog during block
   - Panic button confirmation
   - Relapse log analytics
   - Notification preferences
5. Upload build via Xcode or Transporter
6. Complete rating questionnaire
7. Review and submit

**Description Example:**
```
Take control of your attention. UnScroll blocks Instagram Reels, 
YouTube Shorts, and TikTok—the platforms designed to keep you 
scrolling endlessly.

Designed for addiction recovery with:
• Friction layers that give you time to reconsider
• Panic button for urgent moments
• Accountability partnerships for support
• Privacy-first: all data stays on your device

Reclaim your time. Recover your life.
```

**Expected Review Timeline:**
- Submission → Initial review: 24-48 hours
- If rejections: Fix and resubmit (same day)
- Approval to release: Same day or next
- **Total: 3-5 days typical**

**Common Rejection Reasons & Fixes:**
| Reason | Fix |
|--------|-----|
| "Interferes with standard iOS functionality" | Clarify we use only approved APIs (DeviceActivity, Screen Time) |
| "Privacy concerns" | Add clear privacy policy, explain data stays local |
| "Misleading marketing" | Tone down claims, focus on friction/support |
| "Health claim without evidence" | Remove "treat/cure" language, use "support recovery" |

### 2.2 Google Play Store Submission

**Pre-Submission Checklist:**
```
□ Build & signing
  □ Release APK signed
  □ Bundle created (AAB format recommended)
  □ Version code incremented
  □ Min SDK: 26, Target: 34

□ App listing
  □ App name & subtitle
  □ Description (4000 char limit)
  □ Full description with features
  □ Category: Productivity
  □ Content rating questionnaire
  □ Privacy policy (GDPR compliant)
  □ Terms of service (optional but recommended)

□ Graphics
  □ Icon (512x512, PNG)
  □ Feature graphic (1024x500, PNG)
  □ Screenshots (5-8, min 320x426 on phones)
  □ Video preview (15-30s, YouTube link)
  □ Promo image (1200x628, optional)

□ Testing
  □ Tested on 5+ Android versions (10-14)
  □ Tested on various screen sizes (phones, tablets)
  □ AccessibilityService working
  □ Deep linking verified
  □ Crash-free for 48 hours

□ Compliance
  □ Target API level is latest
  □ No banned APIs used
  □ Permissions justified
  □ No malicious behavior detected
```

**Play Console Setup:**
1. Create new app
2. Fill app details:
   ```
   App name: UnScroll
   Package name: com.unscroll.app
   Default language: English (US)
   App type: Application
   Category: Productivity
   ```
3. Add screenshots/graphics
4. Write description:
   ```
   Focus Mode for Short-Form Addiction Recovery
   
   Instagram Reels. YouTube Shorts. TikTok. These apps are 
   designed to keep you scrolling endlessly.
   
   UnScroll puts you back in control:
   
   ✓ Block Reels & Shorts with one tap
   ✓ Friction layers slow down your impulses
   ✓ Panic button for urgent moments
   ✓ Track your recovery journey
   ✓ Privacy-first: all data stays local
   
   For anyone struggling with doomscrolling, short-form video 
   addiction, or seeking to reclaim their attention.
   ```
5. Fill content rating questionnaire
6. Upload AAB bundle
7. Review and submit

**Privacy & Permissions Justification:**
```
Permission: android.permission.QUERY_ALL_PACKAGES
Why: Detect which apps are installed (Reels, Shorts, TikTok)

Permission: android.permission.BIND_ACCESSIBILITY_SERVICE
Why: Monitor app launches and detect short-form content

Permission: android.permission.POST_NOTIFICATIONS
Why: Send reminders and focus mode status updates

Permission: android.permission.SCHEDULE_EXACT_ALARM
Why: Trigger protection windows at scheduled times
```

**Expected Review Timeline:**
- Submission → Review: 2-4 hours typical
- If rejections: Review feedback, fix, resubmit (same day)
- Approval to release: 2-4 hours
- **Total: 12-24 hours typical**

**Common Rejection Reasons & Fixes:**
| Reason | Fix |
|--------|-----|
| "Interferes with core platform functionality" | Clarify we use AccessibilityService (approved use case) |
| "Misleading claims" | Tone down, use "supported by friction layers" |
| "Privacy violation" | Emphasize no data collection, all local |
| "Excessive permissions" | Provide clear justification for each permission |

---

## Phase 3: Launch Preparation (1 week before launch)

### 3.1 Marketing Materials

**Social Media Content:**
```
Post 1 (Instagram/Twitter):
"Apps are designed to keep you scrolling. 
We're designed to help you stop.

Launching UnScroll: Recover your attention, 
one friction layer at a time. 🎯

#DigitalWellness #Productivity #Recovery"

Post 2 (LinkedIn):
"For the past 3 years, social media platforms have 
optimized their algorithms to maximize engagement. 
What if you had a tool optimized for your wellbeing instead?

Introducing UnScroll - launching this week."

Post 3 (Reddit - r/nosurf):
"UnScroll is here: Open-source friction layers 
for Reels/Shorts blocking. Built by someone 
who struggled too. Feedback welcome!"
```

**ProductHunt Submission:**
```
Title: UnScroll – Reclaim Your Time from Endless Scrolling
Tagline: Friction layers + Panic button for Reels/Shorts addiction
Category: Productivity / Health & Fitness

Description:
Apps are engineered for maximum engagement. UnScroll is engineered 
for maximum recovery.

Features:
🚫 Block Instagram Reels, YouTube Shorts, TikTok
⏰ Friction layers delay your impulses
🆘 Panic button for moments of weakness
📊 Track your recovery journey (private, on-device)
👥 Accountability partnerships (coming soon)

Made by someone who lost years to doomscrolling. 
Now helping others reclaim theirs.
```

**Press Kit:**
```
File: docs/PRESS_KIT.md

About UnScroll:
- One-liner: Addiction-resistant blocker for Reels & Shorts
- 10-word: Friction layers help you recover from doomscroll
- Vision: 1M users in recovery from short-form addiction
- Founded: August 2026
- Team: 1 founder + open-source contributors

Media Assets:
- Logo (SVG + PNG)
- App screenshots (5)
- Founder photo (high-res)
- Feature sheet (PDF)
```

### 3.2 Communication Strategy

**Launch Timing:**
- Tuesday 10 AM PST (optimal for tech communities)
- 48 hours before ProductHunt launch
- Coordinate with major recovery communities

**Day-Of Timeline:**
```
8:00 AM - Send press releases to recovery blogs
9:00 AM - Post on Reddit r/nosurf, r/StopGaming
10:00 AM - ProductHunt launch (top of page)
10:30 AM - Social media posts (Twitter, Instagram, LinkedIn)
11:00 AM - Email beta testers with launch link
1:00 PM - Monitor feedback, respond to comments
3:00 PM - Consider featured post on ProductHunt
EOD - Compile feedback for post-launch iteration
```

**Communication Channels:**
- Email: launch@unscroll.app (updates)
- Twitter: @unscroll_app (real-time feedback)
- Discord: Invite link in ProductHunt post
- Reddit: AMA thread in r/nosurf
- GitHub: Issues and discussions for feedback

---

## Phase 4: Post-Launch (Weeks 1-4)

### 4.1 Monitoring & Quick Fixes

**First 48 Hours:**
- Monitor crash reports (target: <0.1%)
- Check user feedback on ProductHunt, Reddit, Twitter
- Fix any critical bugs same day
- Update app store screenshots based on user feedback

**First Week:**
```
Mon: Monitor DAU, retention, crashes
Tue: Review feedback, prioritize fixes
Wed: Deploy hotfix for top 3 issues
Thu: Collect reviews, respond to feedback
Fri: Analyze week 1 metrics
```

**Metrics to Track:**
```
# Adoption
- Total downloads (iOS + Android)
- Daily installs
- Install retention (Day 1, 7, 30)

# Engagement
- Daily Active Users (DAU)
- Session length
- Features used (policy creation, panic button, etc)

# Quality
- Crash-free users
- One-star reviews (investigate reasons)
- Average app store rating

# Recovery
- Avg time to re-enable protection
- Median relapse-free streak
- Panic button usage frequency
```

### 4.2 Communication & Support

**Customer Support Process:**
```
Support channels:
1. In-app crash reporting (priority: critical)
2. Email: support@unscroll.app
3. Reddit: r/unscroll (community)
4. GitHub: Issues (for features/bugs)
5. Twitter: @unscroll_app (urgent)

Response times:
- Crashes: 4 hours
- Feature requests: 24 hours
- General questions: 48 hours
```

**FAQ Preparation:**
```
Q: Will this affect my normal Instagram/YouTube use?
A: No! We only block Reels, Shorts, and Stories. 
   Messages, DMs, and educational content work normally.

Q: Is my data safe?
A: Yes. All data stays on your device. We don't collect 
   or store any usage information without your permission.

Q: Can I disable it?
A: Yes, with a 24-hour cooldown to give you time to reconsider. 
   This friction layer is designed to help you succeed.

Q: Why is it free?
A: We believe recovery should be accessible to everyone. 
   We'll offer optional premium features later.

Q: Open source?
A: Yes! Source code available on GitHub. 
   Contributions welcome at Real-Sahil/Unscroll.
```

### 4.3 Content & Community Building

**Blog Posts:**
1. "Why Reels & Shorts Are So Addictive" (psychology/design)
2. "How Friction Layers Help Recovery" (personal story + science)
3. "App Blocker Guide: Comparing Solutions" (comparison, our perspective)
4. "Building Accountability: Partner & Coach Modes" (feature spotlight)

**Community Development:**
```
# Discord Server
- #announcements (updates)
- #support (help & troubleshooting)
- #wins (share recovery progress)
- #feature-requests (voting)
- #introduce-yourself (community)

# Reddit Presence
- Maintain r/unscroll (official subreddit)
- Active participation in r/nosurf, r/StopGaming
- Weekly "Motivation Monday" posts
- Monthly AMA with team

# GitHub
- Open-source contributions (Android/iOS)
- Feature discussions
- Security reporting process
```

---

## Post-Launch Success Metrics

### 6-Month Targets
```
# Growth
- 10,000+ downloads (5K iOS, 5K Android)
- 5,000+ monthly active users
- 40%+ 7-day retention
- 20%+ 30-day retention

# Quality
- 4.5+ star rating (iOS App Store)
- 4.3+ star rating (Google Play)
- <0.05% crash rate
- <10% uninstall rate in week 1

# Engagement
- 15+ min average session
- 60%+ have created policy
- 30%+ use panic button weekly
- 20%+ enable family mode

# Impact
- 100+ recovery stories shared
- 50+ media mentions
- 1000+ GitHub stars
- Partnerships with 5+ recovery organizations
```

---

## Launch Day Checklist

```
48 hours before:
□ Test final iOS build on 3+ devices
□ Test final Android build on 3+ devices
□ Verify app store listings look good
□ Email summary sent to beta testers
□ ProductHunt post scheduled
□ Social media posts drafted

24 hours before:
□ Do final QA pass
□ Verify crash reporting working
□ Set up customer support email
□ Monitor app store for any issues
□ Brief team on launch day

Launch day (T-0):
□ Submit final builds if not live
□ Coordinate with ProductHunt
□ Post on social media
□ Notify beta testers
□ Monitor metrics in real-time
□ Respond to early feedback

Launch day (T+24h):
□ Analyze Day 1 metrics
□ Collect user feedback
□ Address top support questions
□ Post thank you on ProductHunt
□ Plan Day 2 updates if needed

Launch week:
□ Daily standup: metrics + feedback
□ Hotfix any critical issues same day
□ Feature suggestion voting system
□ Continued community engagement
```

---

## Success Definition

**"UnScroll Launch is Successful If..."**

1. **Technical**: App stays live without major outages, crash rate <0.1%
2. **Adoption**: 5,000+ downloads in week 1
3. **Engagement**: 3,000+ weekly active users (40%+ of downloaders)
4. **Retention**: 40%+ still using after 7 days
5. **Quality**: 4.0+ star rating (combined iOS + Android)
6. **Community**: Active Discord/Reddit communities forming
7. **Impact**: Genuine user stories of recovery shared
8. **Feedback**: Users excited about roadmap (family mode, coach tools)

---

**Launch Timeline Summary:**
- Beta Testing: 4-6 weeks (concurrent with app store submission prep)
- App Store Submission: 2 weeks
- Launch Preparation: 1 week
- **Total: 7-9 weeks from NOW to public launch**

**Current Status**: Beta recruitment starting this week
**Target Public Launch**: October 2026

---

**Last Updated**: August 19, 2026  
**Status**: Beta Launch Planning Complete  
**Next Step**: Recruit first 50 beta testers
