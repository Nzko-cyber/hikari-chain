#!/bin/bash
# Build script for Windows (Git Bash)

echo "🔨 Building Hikari Chain..."

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "❌ Go is not installed. Please install Go 1.25.2 from https://go.dev/dl/"
    exit 1
fi

# Check Go version
GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
REQUIRED_VERSION="1.25.2"

echo "📦 Current Go version: $GO_VERSION"
echo "📦 Required Go version: $REQUIRED_VERSION"

# Create build directory
mkdir -p build

# Get version info
COMMIT=$(git log -1 --format='%H' 2>/dev/null || echo "unknown")
VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "dev")

echo "🔖 Version: $VERSION"
echo "🔖 Commit: $COMMIT"

# Build
echo "🚀 Building hikarid..."

CGO_ENABLED=0 go build \
    -mod=readonly \
    -tags "netgo" \
    -ldflags "-X github.com/cosmos/cosmos-sdk/version.Name=hikari \
              -X github.com/cosmos/cosmos-sdk/version.AppName=hikarid \
              -X github.com/cosmos/cosmos-sdk/version.Version=$VERSION \
              -X github.com/cosmos/cosmos-sdk/version.Commit=$COMMIT \
              -w -s" \
    -trimpath \
    -o ./build/hikarid.exe \
    ./cmd/hikarid

if [ $? -eq 0 ]; then
    echo "✅ Build successful! Binary: ./build/hikarid.exe"
    echo "📍 Test with: ./build/hikarid.exe version"
else
    echo "❌ Build failed!"
    exit 1
fi
