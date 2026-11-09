# 🚀 Quick Start: Build KhetoPedia APK

**Choose your method:**

---

## ⚡ Method 1: Automated Script (Easiest)

### Step 1: Install Flutter

1. **Right-click** `setup-flutter.ps1`
2. Select **"Run with PowerShell"** or **"Run as Administrator"**
3. Wait 10-15 minutes for installation
4. **Close PowerShell when done**

### Step 2: Build APK

1. **Open NEW PowerShell window** (to refresh PATH)
2. **Right-click** `build-apk.ps1`
3. Select **"Run with PowerShell"**
4. Choose build type when prompted
5. Wait 5-10 minutes
6. **Done!** APK is in `build\app\outputs\flutter-apk\`

---

## 📝 Method 2: Manual Commands

### Prerequisites:
```powershell
# Install Flutter (run as Administrator)
winget install --id=Google.Flutter -e

# Close and reopen PowerShell
```

### Build APK:
```powershell
cd f:\khetopedia

# Clean and prepare
flutter clean
flutter pub get

# Add Android platform (first time only)
flutter create --platforms android .

# Build release APK
flutter build apk --release

# APK location:
# build\app\outputs\flutter-apk\app-release.apk
```

---

## 📱 Install on Android Device

### Step 1: Transfer APK
- USB cable: Copy APK to phone
- Google Drive / OneDrive: Upload and download on phone
- Email: Send APK as attachment

### Step 2: Enable Installation
1. Go to **Settings** → **Security** / **Apps**
2. Enable **"Install unknown apps"** for your file manager / browser
3. Tap the APK file
4. Tap **"Install"**

### Step 3: Open App
1. Find **"KhetoPedia"** in your app drawer
2. Open the app
3. **Important:** Make sure backend server is running at `http://YOUR_IP:8000`

---

## 🔧 If Something Goes Wrong

### Flutter not found after installation:
1. Close all PowerShell windows
2. Open NEW PowerShell
3. Try again

### Build fails:
```powershell
# Check status
flutter doctor

# Accept licenses
flutter doctor --android-licenses

# Try again
flutter clean
flutter pub get
flutter build apk --release
```

### Android SDK missing:
1. Install Android Studio: https://developer.android.com/studio
2. Open Android Studio → SDK Manager
3. Install Android SDK
4. Run `flutter doctor --android-licenses`

---

## 📦 Build Types

| Type | Command | Size | Use Case |
|------|---------|------|----------|
| **Release** | `flutter build apk --release` | ~50-80MB | Distribution |
| **Split** | `flutter build apk --split-per-abi` | ~30-35MB | Smaller size |
| **Debug** | `flutter build apk --debug` | ~100MB+ | Testing only |

**Recommendation:** Use **Release** for normal distribution, **Split** if size matters.

---

## ⚙️ Backend Configuration

Before distributing APK, update API endpoint in:

`lib/core/network/api_constants.dart`:
```dart
class ApiConstants {
  // Change this to your server IP
  static const String baseUrl = 'http://YOUR_SERVER_IP:8000';
}
```

**Options:**
- Local: `http://192.168.1.XXX:8000` (WiFi network)
- Cloud: `https://your-domain.com` (production)
- Tunnel: Use ngrok/cloudflare tunnel for testing

---

## ✅ Pre-Distribution Checklist

Before sharing APK:

- [ ] Flutter installed
- [ ] Android SDK installed
- [ ] All licenses accepted (`flutter doctor` shows all ✓)
- [ ] Backend API URL configured
- [ ] App builds without errors
- [ ] Tested on at least one Android device
- [ ] App icon set (optional but recommended)
- [ ] Backend server accessible from phone

---

## 🎯 Expected Build Time

| Task | First Time | Subsequent |
|------|-----------|------------|
| Flutter install | 10-15 min | - |
| Android setup | 15-20 min | - |
| First build | 10-15 min | - |
| Later builds | 2-5 min | 2-5 min |

**Total first-time setup:** ~40-60 minutes  
**Later builds:** ~5 minutes

---

## 📞 Need Help?

1. **Check BUILD_APK_GUIDE.md** for detailed steps
2. **Run `flutter doctor`** to see what's missing
3. **Check error messages** in PowerShell output
4. **Common issues are documented** in BUILD_APK_GUIDE.md

---

## 🎉 Success Indicators

You'll know it worked when:
- ✅ `flutter doctor` shows all checks passed
- ✅ Build completes with "Built build\app\outputs\flutter-apk\app-release.apk"
- ✅ APK file exists in the outputs folder
- ✅ APK installs and runs on Android device

---

**Ready? Run `setup-flutter.ps1` to start!**
