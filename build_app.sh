#!/bin/bash
set -e

echo "🔨 Building SnipIt..."

# Build the executable
swift build -c release

# Create .app bundle structure
APP_NAME="SnipIt.app"
APP_DIR="$APP_NAME/Contents"
rm -rf "$APP_NAME"
mkdir -p "$APP_DIR/MacOS"
mkdir -p "$APP_DIR/Resources"

# Copy executable
cp .build/release/SnipIt "$APP_DIR/MacOS/SnipIt"

# Create Info.plist
cat > "$APP_DIR/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>SnipIt</string>
    <key>CFBundleIdentifier</key>
    <string>com.snipit.SnipIt</string>
    <key>CFBundleName</key>
    <string>SnipIt</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025. All rights reserved.</string>
    <key>NSScreenCaptureDescription</key>
    <string>SnipIt needs permission to capture regions of your screen for OCR.</string>
</dict>
</plist>
EOF

echo "✅ SnipIt.app created!"
echo ""
echo "To install:"
echo "  cp -r SnipIt.app /Applications/"
echo ""
echo "To run:"
echo "  open SnipIt.app"
echo ""
echo "To add to login items:"
echo "  System Settings → General → Login Items → Add SnipIt.app"
