#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

VERSION="${1:-1.2.0}"
TAG="v${VERSION#v}"

echo "==> 📦 Building DuoBar release..."
"$REPO_ROOT/tools/build-app.sh"

echo "==> 🗜️ Creating DuoBar.zip..."
rm -f "$REPO_ROOT/build/DuoBar.zip"
cd "$REPO_ROOT/build"
ditto -c -k --keepParent DuoBar.app DuoBar.zip
cd "$REPO_ROOT"

echo "==> 🔏 Signing with Sparkle Ed25519..."
python3 - <<'EOF'
import base64, os
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

priv_b64 = os.environ.get('SPARKLE_PRIVATE_KEY') or "BgWmQnqZbpzQnJ5FdT0QMiT0VZXL0J0xCbUfhAUhVzVOKyeoklMD83OL98pVNluzLDYHgb52OnzS0lW0OZYcfg=="
key_bytes = base64.b64decode(priv_b64)
private_key = Ed25519PrivateKey.from_private_bytes(key_bytes[:32])

zip_path = 'build/DuoBar.zip'
with open(zip_path, 'rb') as f:
    data = f.read()

sig = private_key.sign(data)
sig_b64 = base64.b64encode(sig).decode()
size = len(data)

print(f"SIZE: {size}")
print(f"SIG: {sig_b64}")

with open('build/sparkle.env', 'w') as out:
    out.write(f"SPARKLE_SIG={sig_b64}\nSPARKLE_SIZE={size}\n")
EOF

source "$REPO_ROOT/build/sparkle.env"

echo "==> 📝 Updating appcast.xml..."
DATE=$(date -u +"%a, %d %b %Y %H:%M:%S +0000")
cat > "$REPO_ROOT/appcast.xml" <<APPCAST
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>DuoBar</title>
    <link>https://github.com/vibe2code/DuoBar</link>
    <description>DuoBar releases</description>
    <language>en</language>
    <item>
      <title>DuoBar ${VERSION}</title>
      <pubDate>${DATE}</pubDate>
      <sparkle:version>${VERSION}</sparkle:version>
      <sparkle:shortVersionString>${VERSION}</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>13.0</sparkle:minimumSystemVersion>
      <description><![CDATA[
        <h2>DuoBar ${VERSION}</h2>
        <ul>
          <li>Interactive Wi-Fi network picker directly in the popover</li>
          <li>Interactive Core Audio output selector</li>
          <li>Translucent native macOS Settings window with blurred glass and materials</li>
          <li>17 world languages with automatic system detection</li>
          <li>Automatic background updater via Sparkle</li>
          <li>High-resolution App Icon</li>
        </ul>
      ]]></description>
      <enclosure
        url="https://github.com/vibe2code/DuoBar/releases/download/${TAG}/DuoBar.zip"
        sparkle:edSignature="${SPARKLE_SIG}"
        length="${SPARKLE_SIZE}"
        type="application/octet-stream"
      />
    </item>
  </channel>
</rss>
APPCAST

echo "==> 🚀 Publishing GitHub Release ${TAG}..."
gh release create "${TAG}" "$REPO_ROOT/build/DuoBar.zip" "$REPO_ROOT/appcast.xml" \
  --title "DuoBar ${VERSION}" \
  --generate-notes \
  --repo vibe2code/DuoBar \
  || gh release upload "${TAG}" "$REPO_ROOT/build/DuoBar.zip" "$REPO_ROOT/appcast.xml" --clobber --repo vibe2code/DuoBar

echo "==> ✨ Release published successfully!"
