#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "==> 🔨 Building DuoBar with swift build (release)..."
swift build -c release

BIN_PATH="$REPO_ROOT/.build/release/DuoBar"
APP_DIR="$REPO_ROOT/build/DuoBar.app"
CONTENTS="$APP_DIR/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

echo "==> 📦 Packaging into $APP_DIR..."
rm -rf "$APP_DIR"
mkdir -p "$MACOS" "$RESOURCES"

# Copy binary
cp "$BIN_PATH" "$MACOS/DuoBar"
chmod +x "$MACOS/DuoBar"

# Create Info.plist
cat > "$CONTENTS/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleName</key>
    <string>DuoBar</string>
    <key>CFBundleDisplayName</key>
    <string>DuoBar</string>
    <key>CFBundleIdentifier</key>
    <string>com.mikeli.duobar</string>
    <key>CFBundleVersion</key>
    <string>1.1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.1.0</string>
    <key>CFBundleExecutable</key>
    <string>DuoBar</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIconName</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>DuoBar uses location access only to display the name of the Wi-Fi network you are connected to.</string>
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>DuoBar uses Bluetooth availability with public audio metadata to recognize supported Bluetooth audio connections.</string>
    <key>SUFeedURL</key>
    <string>https://vibe2code.github.io/DuoBar/appcast.xml</string>
    <key>SUPublicEDKey</key>
    <string>TisnqJJTA/Nzi/fKVTZbsyw2B4G+djp80tJVtDmWHH4=</string>
</dict>
</plist>
PLIST

echo "APPL????" > "$CONTENTS/PkgInfo"

# Copy AppIcon.icns
if [ -f "$REPO_ROOT/DuoBar/Resources/AppIcon.icns" ]; then
    cp "$REPO_ROOT/DuoBar/Resources/AppIcon.icns" "$RESOURCES/AppIcon.icns"
fi

# Copy Sparkle framework
SPARKLE_FW="$REPO_ROOT/.build/artifacts/sparkle/Sparkle/Sparkle.framework"
if [ -d "$SPARKLE_FW" ]; then
    mkdir -p "$CONTENTS/Frameworks"
    cp -R "$SPARKLE_FW" "$CONTENTS/Frameworks/"
fi

# Copy SPM resource bundle if present
SPM_BUNDLE="$REPO_ROOT/.build/release/DuoBar_DuoBar.bundle"
if [ -d "$SPM_BUNDLE" ]; then
    cp -R "$SPM_BUNDLE" "$RESOURCES/"
fi

# Copy all lproj folders (localizations)
for lproj in "$REPO_ROOT"/DuoBar/*.lproj; do
    if [ -d "$lproj" ]; then
        cp -R "$lproj" "$RESOURCES/"
    fi
done

echo "==> 🔏 Ad-hoc code signing..."
codesign --force --deep --sign - "$APP_DIR" 2>/dev/null || true

echo "==> ✨ DuoBar.app successfully built at: $APP_DIR"
