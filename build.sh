#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
ARCHIVE_PATH="$BUILD_DIR/dzen.xcarchive"
APP_OUTPUT="$BUILD_DIR/dzen.app"

# Clean
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Archive
xcodebuild archive \
  -project "$PROJECT_DIR/dzen.xcodeproj" \
  -scheme dzen \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_ALLOWED=YES

# Extract .app from archive
cp -R "$ARCHIVE_PATH/Products/Applications/dzen.app" "$APP_OUTPUT"

# Clean up archive
rm -rf "$ARCHIVE_PATH"

echo "Built: $APP_OUTPUT"
echo "Size: $(du -sh "$APP_OUTPUT" | cut -f1)"
