# 🚀 KhetoPedia APK Build Guide

Complete guide to build a working APK for the KhetoPedia Flutter app.

---

## 📋 Prerequisites

### 1. Install Flutter SDK

**Option A: Using Winget (Recommended)**
```powershell
# Open PowerShell as Administrator
winget install --id=Google.Flutter -e
```

**Option B: Manual Installation**
1. Download Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\src\flutter`
3. Add to PATH: `C:\src\flutter\bin`
4. Restart your terminal

**Verify Installation:**
```powershell
flutter --version
```

---

### 2. Install Android Studio & Android SDK

1. **Download Android Studio:** https://developer.android.com/studio
2. **Install Android Studio** with default settings
3. **Open Android Studio:**
   - Click "More Actions" → "SDK Manager"
   - Install:
     - ✅ Android SDK Platform (API 34 or latest)
     - ✅ Android SDK Build-Tools
     - ✅ Android SDK Command-line Tools
     - ✅ Android Emulator
4. **Set Environment Variables:**
   ```powershell
   # Add to System PATH:
   C:\Users\sahil\AppData\Local\Android\Sdk\platform-tools
   C:\Users\sahil\AppData\Local\Android\Sdk\cmdline-tools\latest\bin
   ```

---

### 3. Accept Android Licenses

```powershell
flutter doctor --android-licenses
# Press 'y' to accept all licenses
```

---

### 4. Run Flutter Doctor

```powershell
flutter doctor -v
```

**Expected Output:**
```
[✓] Flutter (Channel stable, version X.X.X)
[✓] Android toolchain - develop for Android devices
[✓] Chrome - develop for the web
[✓] Android Studio (version X.X)
[✓] VS Code (version X.X.X)
[✓] Connected device (1 available)
[✓] Network resources
```

---

## 🔧 Project Setup

### Step 1: Add Android Platform Support

```powershell
cd f:\khetopedia
flutter create --platforms android .
```

This creates the `android/` folder with all necessary Android configuration.

---

### Step 2: Configure Android App

Edit `android/app/build.gradle`:

```gradle
android {
    namespace = "com.khetopedia.app"
    compileSdk = 34
    
    defaultConfig {
        applicationId = "com.khetopedia.app"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }
}
```

---

### Step 3: Configure App Permissions

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    
    <application
        android:label="KhetoPedia"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- Rest of the configuration -->
    </application>
</manifest>
```

---

### Step 4: Install Dependencies

```powershell
cd f:\khetopedia
flutter pub get
```

---

### Step 5: Fix Any Issues

```powershell
# Clean previous builds
flutter clean

# Get dependencies again
flutter pub get

# Check for issues
flutter doctor
flutter analyze
```

---

## 📱 Build APK

### Option 1: Build Release APK (Recommended)

```powershell
cd f:\khetopedia
flutter build apk --release
```

**Output location:**
```
build\app\outputs\flutter-apk\app-release.apk
```

**APK Size:** ~50-80 MB

---

### Option 2: Build Split APKs (Smaller Size)

```powershell
flutter build apk --split-per-abi
```

**Output files:**
- `app-armeabi-v7a-release.apk` (ARM 32-bit, ~30MB)
- `app-arm64-v8a-release.apk` (ARM 64-bit, ~35MB) ← **Most devices**
- `app-x86_64-release.apk` (x86 64-bit, ~40MB)

**Recommendation:** Share the `arm64-v8a` APK for most users.

---

### Option 3: Build Debug APK (For Testing)

```powershell
flutter build apk --debug
```

**Note:** Debug APKs are larger and slower.

---

## 🔐 Code Signing (Optional but Recommended)

For production release, sign your APK:

### 1. Create Keystore

```powershell
keytool -genkey -v -keystore f:\khetopedia\android\app\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Create `key.properties`

Create `android/key.properties`:
```properties
storePassword=<your-password>
keyPassword=<your-password>
keyAlias=upload
storeFile=upload-keystore.jks
```

### 3. Update `build.gradle`

Add to `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

## 🧪 Testing the APK

### 1. Install on Physical Device

**Enable USB Debugging:**
1. Go to Settings → About Phone
2. Tap "Build Number" 7 times
3. Go to Developer Options → Enable USB Debugging
4. Connect phone via USB

**Install APK:**
```powershell
# Check device is connected
flutter devices

# Install directly
flutter install
```

### 2. Test on Emulator

```powershell
# List emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator-id>

# Run app
flutter run
```

---

## 📦 Final APK Checklist

Before distribution:

- [ ] App name is correct ("KhetoPedia")
- [ ] App icon is set (create `android/app/src/main/res/mipmap-*/ic_launcher.png`)
- [ ] All permissions are added to AndroidManifest.xml
- [ ] Backend API URL is configured (in `lib/core/network/api_constants.dart`)
- [ ] APK is signed (for production)
- [ ] Tested on at least 2 different devices
- [ ] No debug logs in production code
- [ ] App doesn't crash on startup

---

## 🚨 Common Issues & Fixes

### Issue 1: "Flutter not recognized"
**Fix:** Add Flutter to PATH and restart terminal.

### Issue 2: "Android license not accepted"
**Fix:** Run `flutter doctor --android-licenses`

### Issue 3: "Gradle build failed"
**Fix:** 
```powershell
cd android
.\gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

### Issue 4: "Missing permissions"
**Fix:** Add required permissions to `AndroidManifest.xml`

### Issue 5: "Build takes too long"
**Fix:** 
- Close Android Studio
- Disable antivirus temporarily
- Use `flutter build apk --release` (faster than debug)

---

## 📱 Share Your APK

### Option 1: Google Drive
1. Upload APK to Google Drive
2. Right-click → Share → Anyone with link
3. Share the link

### Option 2: GitHub Releases
1. Go to your GitHub repo
2. Click "Releases" → "Create new release"
3. Upload APK as asset
4. Publish release

### Option 3: Play Store (Production)
Follow Google Play Console publishing guide.

---

## 🎯 Next Steps After APK is Built

1. **Test thoroughly** on multiple devices
2. **Configure backend API** endpoint
3. **Add app icon** (use https://icon.kitchen)
4. **Create splash screen**
5. **Test with real ML model** (if available)
6. **Gather user feedback**
7. **Prepare for Play Store release**

---

## 💡 Pro Tips

- Use `flutter build apk --release --split-per-abi` for production
- Keep keystore file secure (DON'T commit to Git)
- Test on both Android 10+ and older versions
- Monitor APK size (aim for < 50MB)
- Use ProGuard for code obfuscation in production

---

## 📞 Need Help?

If you encounter issues:
1. Run `flutter doctor -v` and check for errors
2. Check `flutter analyze` for code issues
3. Clear build cache: `flutter clean`
4. Update Flutter: `flutter upgrade`

---

**Ready to build?** Start with Step 1 of Prerequisites!
