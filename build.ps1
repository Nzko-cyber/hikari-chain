# Build script for Windows (PowerShell)

Write-Host "🔨 Building Hikari Chain..." -ForegroundColor Cyan

# Check if Go is installed
if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Go is not installed. Please install Go 1.25.2 from https://go.dev/dl/" -ForegroundColor Red
    exit 1
}

# Check Go version
$goVersion = go version
Write-Host "📦 Current Go: $goVersion" -ForegroundColor Yellow

# Create build directory
New-Item -ItemType Directory -Force -Path ".\build" | Out-Null

# Get version info
$commit = git log -1 --format='%H' 2>$null
if (-not $commit) { $commit = "unknown" }

$version = git describe --tags --abbrev=0 2>$null
if (-not $version) { $version = "dev" }

Write-Host "🔖 Version: $version" -ForegroundColor Green
Write-Host "🔖 Commit: $commit" -ForegroundColor Green

# Build
Write-Host "🚀 Building hikarid..." -ForegroundColor Cyan

$env:CGO_ENABLED = "0"

go build `
    -mod=readonly `
    -tags "netgo" `
    -ldflags "-X github.com/cosmos/cosmos-sdk/version.Name=hikari -X github.com/cosmos/cosmos-sdk/version.AppName=hikarid -X github.com/cosmos/cosmos-sdk/version.Version=$version -X github.com/cosmos/cosmos-sdk/version.Commit=$commit -w -s" `
    -trimpath `
    -o ".\build\hikarid.exe" `
    .\cmd\hikarid

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful! Binary: .\build\hikarid.exe" -ForegroundColor Green
    Write-Host "📍 Test with: .\build\hikarid.exe version" -ForegroundColor Yellow
} else {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}
