#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="${1:-1.0.0}"
APP_DIR="build/CmdEdit.app"
BUNDLE_ID="${CMDEDIT_BUNDLE_ID:-com.zijiecai.cmdedit}"

echo "Building CmdEdit..."
cd App
rm -rf .build
swift build -c release

echo "Creating App Bundle..."
rm -rf "../$APP_DIR"
mkdir -p "../$APP_DIR/Contents/MacOS"
mkdir -p "../$APP_DIR/Contents/Resources"

cp .build/release/CmdEdit "../$APP_DIR/Contents/MacOS/"

cat > "../$APP_DIR/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>CmdEdit</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>CmdEdit</string>
    <key>CFBundleDisplayName</key>
    <string>CmdEdit</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "Build complete: $APP_DIR"
echo "You can now run: cp -r build/CmdEdit.app /Applications/"
