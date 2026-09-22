#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "==> 🔨 Building ReDuoBar with swift build (release)..."
swift build -c release

BIN_PATH="$REPO_ROOT/.build/release/ReDuoBar"
APP_DIR="$REPO_ROOT/build/ReDuoBar.app"
CONTENTS="$APP_DIR/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

echo "==> 📦 Packaging into $APP_DIR..."
rm -rf "$APP_DIR"
mkdir -p "$MACOS" "$RESOURCES"

# Copy binary
cp "$BIN_PATH" "$MACOS/ReDuoBar"
chmod +x "$MACOS/ReDuoBar"

# Create Info.plist
cat > "$CONTENTS/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleName</key>
    <string>ReDuoBar</string>
    <key>CFBundleDisplayName</key>
    <string>ReDuoBar</string>
    <key>CFBundleIdentifier</key>
    <string>com.vibe2code.reduobar</string>
    <key>CFBundleVersion</key>
    <string>5</string>
    <key>CFBundleShortVersionString</key>
    <string>1.2.1</string>
    <key>CFBundleExecutable</key>
    <string>ReDuoBar</string>
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
    <string>ReDuoBar uses location access only to display the name of the Wi-Fi network you are connected to.</string>
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>ReDuoBar uses Bluetooth availability with public audio metadata to recognize supported Bluetooth audio connections.</string>
    <key>SUFeedURL</key>
    <string>https://vibe2code.github.io/ReDuoBar/appcast.xml</string>
    <key>SUPublicEDKey</key>
    <string>TisnqJJTA/Nzi/fKVTZbsyw2B4G+djp80tJVtDmWHH4=</string>
</dict>
</plist>
PLIST

echo "APPL????" > "$CONTENTS/PkgInfo"

# Copy AppIcon.icns
if [ -f "$REPO_ROOT/ReDuoBar/Resources/AppIcon.icns" ]; then
    cp "$REPO_ROOT/ReDuoBar/Resources/AppIcon.icns" "$RESOURCES/AppIcon.icns"
fi

# Copy Sparkle framework
SPARKLE_FW=""
for cand in \
    "$REPO_ROOT/.build/arm64-apple-macosx/release/Sparkle.framework" \
    "$REPO_ROOT/.build/artifacts/sparkle/Sparkle/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework" \
    "$REPO_ROOT/.build/artifacts/sparkle/Sparkle/Sparkle.framework"; do
    if [ -d "$cand" ]; then
        SPARKLE_FW="$cand"
        break
    fi
done

if [ -n "$SPARKLE_FW" ]; then
    mkdir -p "$CONTENTS/Frameworks"
    cp -R "$SPARKLE_FW" "$CONTENTS/Frameworks/"
fi

# Ensure rpath is configured so dyld can locate @rpath/Sparkle.framework in Frameworks
install_name_tool -add_rpath @executable_path/../Frameworks "$MACOS/ReDuoBar" 2>/dev/null || true

# Copy SPM resource bundle if present
SPM_BUNDLE="$REPO_ROOT/.build/release/ReDuoBar_ReDuoBar.bundle"
if [ -d "$SPM_BUNDLE" ]; then
    cp -R "$SPM_BUNDLE" "$RESOURCES/"
fi

# Copy all lproj folders (localizations)
for lproj in "$REPO_ROOT"/ReDuoBar/*.lproj; do
    if [ -d "$lproj" ]; then
        cp -R "$lproj" "$RESOURCES/"
    fi
done

echo "==> 🔏 Ad-hoc code signing..."
codesign --force --deep --sign - "$APP_DIR" 2>/dev/null || true

echo "==> ✨ ReDuoBar.app successfully built at: $APP_DIR"
