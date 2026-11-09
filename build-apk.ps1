# KhetoPedia APK Builder Script
# Run this AFTER Flutter is installed

Write-Host "🏗️  KhetoPedia APK Builder" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
Write-Host "🔍 Checking Flutter installation..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "✅ Flutter found: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter not found!" -ForegroundColor Red
    Write-Host "Please run setup-flutter.ps1 first" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Navigate to project directory
$projectDir = "f:\khetopedia"
Set-Location $projectDir
Write-Host "📂 Project directory: $projectDir" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clean previous builds
Write-Host "🧹 Step 1/6: Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
Write-Host "✅ Clean complete" -ForegroundColor Green
Write-Host ""

# Step 2: Get dependencies
Write-Host "📦 Step 2/6: Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get dependencies" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "✅ Dependencies installed" -ForegroundColor Green
Write-Host ""

# Step 3: Check for android folder
Write-Host "🔍 Step 3/6: Checking Android platform..." -ForegroundColor Yellow
if (-not (Test-Path "android")) {
    Write-Host "⚠️  Android platform not found. Creating..." -ForegroundColor Yellow
    flutter create --platforms android .
    Write-Host "✅ Android platform added" -ForegroundColor Green
} else {
    Write-Host "✅ Android platform exists" -ForegroundColor Green
}
Write-Host ""

# Step 4: Run flutter doctor
Write-Host "🏥 Step 4/6: Running Flutter Doctor..." -ForegroundColor Yellow
flutter doctor
Write-Host ""

# Step 5: Ask user which build type
Write-Host "🎯 Step 5/6: Choose build type:" -ForegroundColor Yellow
Write-Host "1. Release APK (single file, ~50-80MB)" -ForegroundColor White
Write-Host "2. Split APKs (per architecture, ~30-35MB each)" -ForegroundColor White
Write-Host "3. Debug APK (for testing only, larger)" -ForegroundColor White
Write-Host ""
$buildChoice = Read-Host "Enter choice (1/2/3) [Default: 1]"

if ([string]::IsNullOrWhiteSpace($buildChoice)) {
    $buildChoice = "1"
}

Write-Host ""

# Step 6: Build APK
Write-Host "🔨 Step 6/6: Building APK..." -ForegroundColor Yellow
Write-Host "This will take 5-10 minutes on first build..." -ForegroundColor Gray
Write-Host ""

$buildSuccess = $false

switch ($buildChoice) {
    "1" {
        Write-Host "Building Release APK..." -ForegroundColor Cyan
        flutter build apk --release
        if ($LASTEXITCODE -eq 0) {
            $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
            $buildSuccess = $true
        }
    }
    "2" {
        Write-Host "Building Split APKs..." -ForegroundColor Cyan
        flutter build apk --split-per-abi --release
        if ($LASTEXITCODE -eq 0) {
            $apkPath = "build\app\outputs\flutter-apk\"
            $buildSuccess = $true
        }
    }
    "3" {
        Write-Host "Building Debug APK..." -ForegroundColor Cyan
        flutter build apk --debug
        if ($LASTEXITCODE -eq 0) {
            $apkPath = "build\app\outputs\flutter-apk\app-debug.apk"
            $buildSuccess = $true
        }
    }
    default {
        Write-Host "❌ Invalid choice" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host ""

if ($buildSuccess) {
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "🎉 APK BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📍 APK Location:" -ForegroundColor Yellow
    Write-Host "   $apkPath" -ForegroundColor White
    Write-Host ""
    
    # Get APK size
    if ($buildChoice -eq "2") {
        Write-Host "📦 APK Files:" -ForegroundColor Yellow
        Get-ChildItem "build\app\outputs\flutter-apk\*.apk" | ForEach-Object {
            $sizeMB = [math]::Round($_.Length / 1MB, 2)
            Write-Host "   $($_.Name) - ${sizeMB}MB" -ForegroundColor White
        }
    } else {
        $apkFile = Get-Item $apkPath
        $sizeMB = [math]::Round($apkFile.Length / 1MB, 2)
        Write-Host "📦 APK Size: ${sizeMB}MB" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "✅ Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Transfer APK to your Android device" -ForegroundColor White
    Write-Host "2. Enable 'Install from Unknown Sources'" -ForegroundColor White
    Write-Host "3. Open and install the APK file" -ForegroundColor White
    Write-Host "4. Make sure backend is running for full functionality" -ForegroundColor White
    Write-Host ""
    
    # Ask if user wants to open the folder
    $openFolder = Read-Host "Open APK folder? (y/n) [Default: y]"
    if ([string]::IsNullOrWhiteSpace($openFolder) -or $openFolder -eq "y") {
        Start-Process "build\app\outputs\flutter-apk"
    }
    
} else {
    Write-Host "================================================" -ForegroundColor Red
    Write-Host "❌ APK BUILD FAILED!" -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Check error messages above" -ForegroundColor White
    Write-Host "2. Run: flutter doctor" -ForegroundColor White
    Write-Host "3. Make sure Android SDK is installed" -ForegroundColor White
    Write-Host "4. Run: flutter doctor --android-licenses" -ForegroundColor White
    Write-Host "5. Try: flutter clean && flutter pub get" -ForegroundColor White
    Write-Host ""
    Write-Host "📖 Full guide: BUILD_APK_GUIDE.md" -ForegroundColor Cyan
}

Write-Host ""
Read-Host "Press Enter to exit"
