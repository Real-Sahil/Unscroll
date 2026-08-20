# 🤖 Automatic Build Guide (GitHub Actions)

**Status:** ✅ Setup Complete  
**Time to build:** Automatic (5-10 minutes)  
**Cost:** FREE

---

## 🎯 How It Works

GitHub Actions automatically builds your Flutter apps every time you push code to GitHub. The builds happen in the cloud, and you download the ready-to-submit files.

```
You push to GitHub
    ↓
GitHub Actions triggers (automatic)
    ↓
Builds Android APK + AAB
Builds iOS IPA
    ↓
Download build files
    ↓
Submit to app stores
```

---

## 📱 What Gets Built

### Android
- **app-release.apk** - Direct install file for testing
- **app-release.aab** - Upload to Google Play Store (production)

### iOS
- **unscroll.ipa** - Upload to App Store (production)

---

## ✅ To Trigger a Build (3 Simple Steps)

### Option 1: Automatic (Easiest)
Builds happen automatically when you push code to `main` branch:
```bash
git push origin main
```
That's it! GitHub Actions starts building.

### Option 2: Manual Trigger (Via GitHub Web)

1. Go to: https://github.com/Real-Sahil/Unscroll
2. Click **Actions** tab
3. Click **Build Flutter Apps** (left sidebar)
4. Click **Run workflow** (blue button)
5. Click **Run workflow** again
6. Wait 10-15 minutes for builds to complete

---

## 📥 Download Build Files

### Step 1: Go to GitHub Actions

https://github.com/Real-Sahil/Unscroll/actions

### Step 2: Find Latest Build

Look for the most recent run (shows "✅ Build Flutter Apps")

### Step 3: Download Artifacts

Click on the run and scroll down to **Artifacts**:
- `unscroll-app-release.apk` ← Android test file
- `unscroll-app-release.aab` ← Android Play Store submission
- `unscroll-app-release.ipa` ← iOS App Store submission

Download whichever you need.

---

## 🏪 Submit to App Stores

See `docs/BUILD_AND_SUBMIT.md` for complete submission instructions:

### Android Play Store
1. Download `unscroll-app-release.aab`
2. Go to: https://play.google.com/console/
3. Click "Create Release"
4. Upload the `.aab` file
5. Submit

### iOS App Store
1. Download `unscroll-app-release.ipa`
2. Go to: https://appstoreconnect.apple.com/
3. Click "Builds" → "Select Build"
4. Upload using Transporter app or Xcode
5. Submit

---

## 🔄 Build Status

Check build status anytime at:
https://github.com/Real-Sahil/Unscroll/actions/workflows/build.yml

Status indicators:
- ✅ Green checkmark = Build succeeded
- ❌ Red X = Build failed
- 🟡 Orange dot = Building in progress

---

## ⚠️ If Build Fails

If a build fails:
1. Click the failed run on GitHub Actions
2. Scroll to find the error message
3. Common issues:
   - **Dependency version conflicts** → Update pubspec.yaml
   - **Code errors** → Fix and push new code
   - **Missing files** → Check project structure

Let me know the error and I'll fix it!

---

## 🎯 Current Status

✅ **Build workflow set up**  
✅ **Chrome extension packaged**  
✅ **API deployed to production**

**Next steps:**
1. Trigger a build (push code or manual trigger)
2. Download APK/AAB/IPA files
3. Submit to app stores (5-10 minutes per store)
4. Done! Apps go live in 1-3 days

---

## 📊 Timeline from Now

```
NOW
└─ Trigger build (push code)
     ↓ (5-10 min)
   Apps built
     ↓
   Download files
     ↓ (5 min each)
   Submit to app stores
     ↓ (1-3 days)
   Apps LIVE! 🎉
```

---

## 💡 Pro Tips

1. **Build happens automatically** - Just commit and push
2. **Test before building** - Make sure your code works first
3. **Download immediately** - Artifacts are kept for 90 days
4. **Multiple builds ok** - You can rebuild anytime by pushing code
5. **Version number** - Update `version: 0.1.0+1` in pubspec.yaml between releases

---

## 🚀 Ready?

Just push code to GitHub and GitHub Actions handles the rest! 

```bash
git push origin main
```

Then monitor at: https://github.com/Real-Sahil/Unscroll/actions

Simple as that! 🎉

---

Last Updated: August 20, 2026
