# Build Troubleshooting Guide

## How to Find the Error Logs

1. Go to: **https://github.com/Real-Sahil/Unscroll/actions**
2. Click the latest "Build Flutter Apps" workflow run
3. Click on either:
   - **build-android** (for APK errors)
   - **build-ios** (for iOS errors)
4. Scroll to find the failed step (usually marked with ❌ in red)
5. Click to expand the step and copy the full error message

## Common Build Failures & Solutions

### ❌ Error: "flutter: command not found"
**Cause:** PATH not properly set
**Solution:** Already fixed in workflow - uses `echo "$HOME/flutter/bin" >> $GITHUB_PATH`

### ❌ Error: "Could not find Gradle wrapper"
**Cause:** Android gradle wrapper files missing
**Solution:** Already added in commit 035306d - gradle wrapper is now included

### ❌ Error: "flutter.sdk not set in local.properties"
**Cause:** local.properties doesn't have flutter.sdk path
**Solution:** Flutter build tool auto-creates this, but we may need to ensure it's set correctly in workflow

### ❌ Error: "Gradle sync failed" or "Could not resolve dependency"
**Cause:** Package version conflicts or network issues
**Solutions:**
- Check pubspec.yaml for conflicting dependency versions
- Clear pub cache: add `flutter pub cache repair` to workflow
- Use `--verbose` flag: `flutter build apk --release --verbose`

### ❌ Error: "Java/Gradle version incompatibility"
**Cause:** Java version on runner doesn't match Gradle expectations
**Solution:** 
- Gradle 7.6.2 needs Java 11+
- ubuntu-latest typically has Java 11+
- Add to workflow: `echo "JAVA_HOME=$(which java)" >> $GITHUB_ENV`

### ❌ Error: "Minimum SDK version mismatch"
**Cause:** minSdkVersion in build.gradle (21) lower than plugin requirement
**Solution:** Already set to 21 in app/build.gradle (safe for most users)

### ❌ Error: "Could not install packages" (iOS)
**Cause:** Cocoapods dependency resolution failure
**Solution:**
- Add to iOS build step: `pod repo update`
- May need: `pod install --repo-update`

### ❌ Error: "Deployment target mismatch"
**Cause:** iOS deployment target version conflicts
**Solution:** Ensure all pods target same iOS version

### ❌ Error: "Undefined symbols for architecture arm64"
**Cause:** Missing or incompatible native dependency
**Solution:** Check if platform-specific package (flutter_accessibility_service) compiles

## Diagnostic Steps

### 1. Enable Verbose Output
Add `--verbose` flag to build commands in workflow:
```yaml
- name: Build APK
  run: |
    flutter build apk --release --verbose
```

### 2. Check Dependency Health
Add step to validate pubspec.yaml:
```yaml
- name: Check Dependencies
  run: |
    flutter pub get
    flutter analyze
    flutter doctor -v
```

### 3. Check Generated Files
After build fails, verify these exist:
- Android: `android/app/src/main/AndroidManifest.xml` ✓ (added)
- Android: `android/build.gradle` ✓ (added)
- iOS: `ios/Podfile` ✓ (added)
- iOS: `ios/Runner/Info.plist` ✓ (added)

## What to Share When Reporting Failures

When you see a build failure, copy and share:

```
❌ FAILURE DETAILS:
Job: [build-android / build-ios]
Step: [Install Flutter / Build APK / Build iOS / Package IPA]
Error Message: [Full error text from logs]
First Error Line: [Line where error starts]

Example:
Job: build-android
Step: Build APK
Error Message: 
  FAILURE: Build failed with an exception.
  * What went wrong:
  Could not resolve dependency: cannot find package:flutter_riverpod
```

## Quick Checklist

- [ ] Confirmed Flutter installed successfully
- [ ] Confirmed `flutter pub get` completed
- [ ] Checked pubspec.yaml for syntax errors
- [ ] Verified all imported packages are in pubspec.yaml
- [ ] Checked lib/main.dart doesn't import missing packages
- [ ] Confirmed no syntax errors in Dart code
- [ ] Verified Android/iOS build configuration files exist
- [ ] Checked Java/Xcode versions compatible with build tools

## Next Actions

1. **Share the full error message** from GitHub Actions logs
2. **Note which step failed** (Install Flutter, Build APK, etc.)
3. **Provide first few lines** of the error stack trace
4. I will then:
   - Identify root cause
   - Make targeted fixes to pubspec.yaml, build.gradle, or Podfile
   - Update workflow if needed
   - Commit and re-test

---

**Status:** Waiting for error details  
**Last Updated:** 2026-08-20
