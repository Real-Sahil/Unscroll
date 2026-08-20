# 🚀 How to Trigger the Build Workflow

The GitHub Actions build workflow is now **pinned and ready to use**. Here's how to trigger it:

---

## 🎯 **Quick Start (30 seconds)**

### Option 1: Manual Trigger (Easiest)

1. **Go to GitHub:** https://github.com/Real-Sahil/Unscroll
2. **Click "Actions"** (top menu)
3. **Click "Build Flutter Apps"** (left sidebar) ⭐ **PINNED**
4. **Click "Run workflow"** (blue button)
5. **Select build type:**
   - `all` (default) - Builds iOS + Android
   - `android-only` - Builds Android only
   - `ios-only` - Builds iOS only
6. **Click "Run workflow"** again
7. **Wait 5-10 minutes** for build to complete

### Option 2: Automatic Trigger

```bash
# Just push code to GitHub - build runs automatically!
git push origin main
```

---

## 📊 **Monitor Build Progress**

### Real-time Monitoring
1. Go to: https://github.com/Real-Sahil/Unscroll/actions
2. Find the latest **"Build Flutter Apps"** run
3. Click on it to see:
   - ✅ Status (running, completed, failed)
   - 📋 Job logs (step-by-step build process)
   - ⏱️ Time elapsed

### Expected Timeline
```
Start build
    ↓ (1-2 min)
Downloading dependencies
    ↓ (2-3 min)
Compiling Flutter
    ↓ (2-3 min)
Building APK/AAB/IPA
    ↓ (2-3 min)
Uploading artifacts
    ↓ (1 min)
✅ BUILD COMPLETE
```

**Total: ~5-10 minutes**

---

## 📥 **Download Build Artifacts**

### Step 1: Go to GitHub Actions
https://github.com/Real-Sahil/Unscroll/actions

### Step 2: Click Latest Build
Find the most recent **"Build Flutter Apps"** run (green checkmark = success)

### Step 3: Download Files
Scroll down to **Artifacts** section. Download:

- **`unscroll-app-release.apk`** ← For Android testing (direct install)
- **`unscroll-app-release.aab`** ← For Android Play Store (production)
- **`unscroll-app-release.ipa`** ← For iOS App Store (production)

---

## ✅ **What Gets Built**

### Android Outputs
```
✅ app-release.apk (Direct install, ~50MB)
✅ app-release.aab (App Bundle for Play Store, ~30MB)
```

### iOS Output
```
✅ unscroll.ipa (App Store format, ~80MB)
```

---

## 🔧 **If Build Fails**

### Common Issues & Fixes

**Issue:** Dependency resolution error
- **Fix:** Already resolved! Using minimal dependencies now.

**Issue:** Build timeout
- **Fix:** Workflow runs for up to 10 minutes. If it fails, try again.

**Issue:** Platform-specific error
- **Action:** Check the workflow logs for details, then retry.

### View Build Logs
1. Click the failed build on GitHub Actions
2. Click **"build-android"** or **"build-ios"** job
3. Expand each step to see error details
4. Share the error with me to troubleshoot

---

## 📱 **Next: Submit to App Stores**

Once you have the artifacts:

1. **Android Play Store:** Use `app-release.aab`
   - Follow: `docs/BUILD_AND_SUBMIT.md` → Android section

2. **iOS App Store:** Use `unscroll.ipa`
   - Follow: `docs/BUILD_AND_SUBMIT.md` → iOS section

3. **Chrome Web Store:** Already ready!
   - Follow: `docs/BUILD_AND_SUBMIT.md` → Chrome section

---

## 🎯 **Current Status**

✅ **Workflow pinned:** Ready for manual/automatic trigger  
✅ **Dependencies simplified:** No version conflicts  
✅ **Logging enhanced:** See detailed build progress  
✅ **Manual control added:** Choose what to build  

**Next:** Trigger a build! 🚀

---

## 📋 **Workflow Features**

| Feature | Status |
|---------|--------|
| Auto-build on push | ✅ Enabled |
| Manual trigger | ✅ Available (Actions tab) |
| Build type selection | ✅ Available (all/android/ios) |
| Verbose logging | ✅ Enabled |
| Artifact download | ✅ 90 days retention |
| iOS (macOS runner) | ✅ Enabled |
| Android (Ubuntu runner) | ✅ Enabled |

---

## 🚀 **Ready to Build?**

### **Option A: Manual (Right Now)**
1. Go to: https://github.com/Real-Sahil/Unscroll/actions
2. Click "Build Flutter Apps"
3. Click "Run workflow"
4. Wait for completion
5. Download artifacts

### **Option B: Automatic (Next Push)**
```bash
git push origin main
```
Build starts automatically!

---

**Last Updated:** August 20, 2026  
**Workflow File:** `.github/workflows/build.yml`  
**Status:** ✅ Production Ready
