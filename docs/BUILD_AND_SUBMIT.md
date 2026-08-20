# 🚀 Build & Submit Guide (No CI/CD)

**Status:** ✅ Ready to submit to app stores  
**Date:** August 20, 2026

---

## 📦 What's Ready to Submit

### ✅ 1. Chrome Extension (READY NOW)
- **File:** `extensions/chrome/unscroll-chrome-extension.zip` (8.6 KB)
- **Status:** ✅ Packaged and ready
- **Contents:** manifest.json, content.js, background.js, styles.css
- **Features:** 
  - Blocks Instagram Reels
  - Blocks YouTube Shorts
  - Blocks TikTok videos
  - Schedule-based blocking
  - Local storage tracking

### 🔄 2. Flutter App (iOS & Android)
- **Status:** ⏳ Requires build (see options below)
- **Time:** 30-60 minutes to build
- **Requirements:** Flutter SDK

### ⚡ 3. Backend API
- **Status:** ✅ Already live
- **URL:** `https://unscroll-api-prod.sahilxleo916.workers.dev`
- **Verified:** Working ✓

---

## 🌐 Chrome Extension Submission

### Step 1: Prepare Files
✅ Already done! File: `extensions/chrome/unscroll-chrome-extension.zip`

### Step 2: Create Developer Account
Go to: https://chrome.google.com/webstore/devconsole/
- Sign in with your Google account
- Pay $5 one-time developer fee
- Create developer profile

### Step 3: Upload to Chrome Web Store

1. Click **"New Item"** in Chrome Web Store Console
2. Click **"Upload"** → Select `unscroll-chrome-extension.zip`
3. Fill in details:
   - **Name:** UnScroll
   - **Category:** Productivity
   - **Description:** 
     ```
     UnScroll helps you escape doomscroll addiction on Instagram Reels, 
     YouTube Shorts, and TikTok. Block distracting content during your 
     risk windows, with built-in friction and accountability features.
     ```
   - **Screenshots:** (2-5 screenshots showing the extension working)
   - **Privacy Policy:** (link to your privacy policy)

4. Click **"Submit for Review"**
5. Wait for Google review (typically 1-3 days)

### Step 4: Enable Analytics
- After submission, enable Chrome Web Store Analytics
- Monitor installation numbers and ratings

---

## 📱 Flutter App: Choose Your Build Method

### **Option A: Minimal Manual Build (Recommended)**

If you want to build locally on any machine:

```bash
# 1. Install Flutter from: https://flutter.dev/docs/get-started/install
# 2. Navigate to your Unscroll directory
cd ~/Unscroll

# 3. Build iOS app
flutter build ios --release

# 4. Build Android app
flutter build appbundle --release

# Generated files:
# iOS: build/ios/ipa/unscroll.ipa
# Android AAB: build/app/outputs/bundle/release/app-release.aab
```

**Time:** 30-45 minutes  
**Disk Space:** ~5 GB  
**Requirements:** Mac for iOS, or use cloud build

### **Option B: Use Cloud Build (Flutter Hosting)**

No local build needed:

1. Go to: https://github.com/Real-Sahil/Unscroll
2. Go to **Settings** → **Actions** → **Runners**
3. Set up GitHub Actions runner (free tier available)
4. Action will build on push to `release` branch

**Time:** Automatic on push  
**Disk Space:** None needed locally

### **Option C: Pre-Built Templates**

Use flutter's web-based test builds:

```bash
flutter create --platforms=ios,android test_build
# This scaffolds a minimal app for testing
```

---

## 🏪 App Store Submission

### iOS (App Store)

**Requirements:**
- Apple Developer Account ($99/year)
- Built `.ipa` file (from `flutter build ios --release`)
- App Store Connect access

**Steps:**

1. Go to: https://appstoreconnect.apple.com/
2. Click **"My Apps"** 
3. If UnScroll doesn't exist:
   - Click **"Create App"**
   - Name: UnScroll
   - Bundle ID: com.unscroll.app
   - Platform: iOS
4. Click **"Builds"** → **"Select Build"**
5. Upload your `.ipa` file using Xcode or Transporter:
   ```bash
   xcrun altool --upload-app --file unscroll.ipa \
     --type ios -u your-apple-id@example.com -p your-app-password
   ```
6. Fill in app details:
   - Screenshots (5 per device size)
   - Description
   - Keywords
   - Support URL
   - Privacy Policy URL
7. Click **"Submit for Review"**
8. Wait 1-3 days for review

### Android (Play Store)

**Requirements:**
- Google Play Developer Account ($25 one-time)
- Built `.aab` file (from `flutter build appbundle --release`)
- App signing certificate

**Steps:**

1. Go to: https://play.google.com/console/
2. Click **"Create App"**
   - Name: UnScroll
   - Default language: English
3. Complete questionnaire
4. Go to **"Release"** → **"Create Release"**
5. Upload your `.aab` file
6. Fill in app details:
   - Screenshots (4-8 per phone/tablet size)
   - Feature graphics
   - Description
   - Short description (80 chars max)
   - Video URL (optional)
7. Set price (Free)
8. Complete content rating questionnaire
9. Click **"Review"** → **"Start rollout"**
10. Choose rollout:
    - **Closed testing:** 10% of users for feedback
    - **Open beta:** Public beta test
    - **Production:** Full release
11. Click **"Confirm rollout"**
12. Wait 2-4 hours for review

---

## 📋 Asset Checklist

### Chrome Extension ✅
- [x] manifest.json
- [x] content.js
- [x] background.js
- [x] styles.css
- [x] Packaged in zip file

### iOS App (When Built)
- [ ] `.ipa` file
- [ ] 5+ screenshots (for each device size)
- [ ] App description
- [ ] Keywords
- [ ] Support URL
- [ ] Privacy policy

### Android App (When Built)
- [ ] `.aab` file
- [ ] 4-8 screenshots (phone and tablet)
- [ ] Feature graphics (1024x500px)
- [ ] Description
- [ ] Short description (80 chars)
- [ ] Privacy policy

---

## 🎯 Which to Submit First?

**Recommended Order:**

1. **Chrome Extension** (Takes 5 minutes)
   - Fastest to submit
   - Good way to learn the process
   - Get user feedback while building mobile

2. **Android (Play Store)** (Takes 1-2 hours)
   - Faster review process
   - Easier to test
   - Can use internal testing first

3. **iOS (App Store)** (Takes 2-3 hours)
   - More complex requirements
   - Longer review process (1-3 days)
   - Better to have stable Android version first

---

## 📊 Timeline Estimate

| Task | Time | Status |
|------|------|--------|
| Chrome Extension Submit | 15 min | ✅ Ready |
| Build Flutter App | 30-60 min | 🔄 Pending |
| iOS App Store Submit | 1-2 hours | ⏳ After build |
| Android Play Store Submit | 1-2 hours | ⏳ After build |
| Review Time (total) | 3-5 days | ⏳ After submission |

**Total from now:** ~5-7 days to have all apps live

---

## 🆘 Troubleshooting

### "I can't build Flutter locally"
→ Use GitHub Actions cloud build (Option B)

### "App Store Connect not showing my app"
→ Create it in App Store Connect first, then upload build

### "Play Store says invalid AAB file"
→ Ensure you used `flutter build appbundle --release` (not apk)

### "Chrome extension won't upload"
→ Make sure manifest.json version is incremented (e.g., "1.0.1" → "1.0.2")

### "Need to sign Android app"
→ Flutter handles this automatically with `--release` flag

---

## 📝 Next Steps

1. **Immediate (Today):**
   - [ ] Get accounts (Apple, Google, Chrome Developer)
   - [ ] Submit Chrome Extension (15 min)
   - [ ] Start Flutter build (can run overnight)

2. **Tomorrow:**
   - [ ] Submit Android to Play Store
   - [ ] Submit iOS to App Store
   - [ ] Monitor review status

3. **Next Week:**
   - [ ] Apps appear in stores
   - [ ] Start beta testing with users
   - [ ] Monitor crash reports and reviews

---

## 🎉 Success Criteria

✅ **Chrome Extension:**
- Submitted to Chrome Web Store
- Visible in search results
- At least 1 installation

✅ **iOS App:**
- Available on App Store
- Can install via TestFlight or public release
- 5+ star rating

✅ **Android App:**
- Available on Play Store
- Can install directly
- 4+ star rating

---

## 📞 Developer Account Links

- **Apple Developer:** https://developer.apple.com/
- **Google Play Console:** https://play.google.com/console/
- **Chrome Web Store Developer:** https://chrome.google.com/webstore/devconsole/

---

**Ready to submit?** Start with the Chrome Extension - it's the fastest! 🚀

Last Updated: August 20, 2026
