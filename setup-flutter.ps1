# KhetoPedia Flutter Setup Script
# Run this as Administrator: Right-click → Run as Administrator

Write-Host "🚀 KhetoPedia Flutter Setup Script" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click this file and select 'Run as Administrator'" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✅ Running with Administrator privileges" -ForegroundColor Green
Write-Host ""

# Step 1: Check if winget is available
Write-Host "📦 Step 1: Checking for winget..." -ForegroundColor Yellow
try {
    $wingetVersion = winget --version
    Write-Host "✅ winget is installed: $wingetVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ winget is not available." -ForegroundColor Red
    Write-Host "Please install App Installer from Microsoft Store." -ForegroundColor Yellow
    Write-Host "URL: https://apps.microsoft.com/detail/9nblggh4nns1" -ForegroundColor Cyan
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Step 2: Install Flutter using winget
Write-Host "🎯 Step 2: Installing Flutter SDK..." -ForegroundColor Yellow
Write-Host "This may take 5-10 minutes..." -ForegroundColor Gray

try {
    winget install --id=Google.Flutter -e --accept-source-agreements --accept-package-agreements
    Write-Host "✅ Flutter SDK installation completed!" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter installation failed: $_" -ForegroundColor Red
    Write-Host "Please install manually from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Step 3: Add Flutter to PATH
Write-Host "🔧 Step 3: Configuring Flutter PATH..." -ForegroundColor Yellow

# Typical Flutter installation path for winget
$flutterPath = "$env:LOCALAPPDATA\Pub\Cache\bin"
$flutterPath2 = "C:\tools\flutter\bin"

$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($currentPath -notlike "*$flutterPath*") {
    Write-Host "Adding Flutter to User PATH..." -ForegroundColor Gray
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$flutterPath", "User")
}

Write-Host "✅ Flutter PATH configured" -ForegroundColor Green
Write-Host ""

# Step 4: Refresh environment
Write-Host "🔄 Step 4: Refreshing environment variables..." -ForegroundColor Yellow
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
Write-Host "✅ Environment refreshed" -ForegroundColor Green
Write-Host ""

# Step 5: Run Flutter doctor
Write-Host "🏥 Step 5: Running Flutter Doctor..." -ForegroundColor Yellow
Write-Host ""

try {
    flutter doctor -v
    Write-Host ""
    Write-Host "✅ Flutter doctor completed!" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Flutter command not found in current session." -ForegroundColor Yellow
    Write-Host "Please close and reopen PowerShell to refresh PATH." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "🎉 Flutter Setup Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Close this PowerShell window" -ForegroundColor White
Write-Host "2. Open a NEW PowerShell window" -ForegroundColor White
Write-Host "3. Navigate to your project: cd f:\khetopedia" -ForegroundColor White
Write-Host "4. Run: flutter doctor" -ForegroundColor White
Write-Host "5. Install Android Studio if not installed" -ForegroundColor White
Write-Host "6. Run: flutter doctor --android-licenses" -ForegroundColor White
Write-Host "7. Add Android platform: flutter create --platforms android ." -ForegroundColor White
Write-Host "8. Build APK: flutter build apk --release" -ForegroundColor White
Write-Host ""
Write-Host "📖 Full guide: See BUILD_APK_GUIDE.md" -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter to exit"
