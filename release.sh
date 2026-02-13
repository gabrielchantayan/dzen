#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
APP_PATH="$BUILD_DIR/dzen.app"

# Build fresh
"$PROJECT_DIR/build.sh"

# Extract version from built app
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP_PATH/Contents/Info.plist")
TAG="v$VERSION"
ZIP_NAME="dzen-$TAG.zip"
ZIP_PATH="$BUILD_DIR/$ZIP_NAME"

MAJOR="${VERSION%%.*}"
MINOR="${VERSION#*.}"
echo "{\"major\":$MAJOR,\"minor\":$MINOR}" > "$PROJECT_DIR/version.json"

echo "Releasing $TAG..."

# Zip the .app
(cd "$BUILD_DIR" && ditto -c -k --keepParent dzen.app "$ZIP_NAME")

echo "Zipped: $ZIP_PATH ($(du -sh "$ZIP_PATH" | cut -f1))"

# Create GitHub release
gh release create "$TAG" "$ZIP_PATH" \
  --title "dzen $TAG" \
  --generate-notes

echo "Released: $TAG"
