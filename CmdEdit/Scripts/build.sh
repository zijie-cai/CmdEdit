#!/bin/bash
set -e

# Ensure we are in the project root
cd "$(dirname "$0")/.."

echo "Building CmdEdit..."
cd App
swift build -c release

echo "Creating App Bundle..."
APP_DIR="../build/CmdEdit.app"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp .build/release/CmdEdit "$APP_DIR/Contents/MacOS/"

cat > "$APP_DIR/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>CmdEdit</string>
    <key>CFBundleIdentifier</key>
    <string>com.cmdedit.app</string>
    <key>CFBundleName</key>
    <string>CmdEdit</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

echo "Build complete: build/CmdEdit.app"
echo "You can now run: cp -r build/CmdEdit.app /Applications/"
