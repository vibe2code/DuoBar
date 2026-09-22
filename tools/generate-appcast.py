#!/usr/bin/env python3
import sys, os, base64, datetime
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

def main():
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    version = sys.argv[1] if len(sys.argv) > 1 else "1.3.0"
    tag = f"v{version.lstrip('v')}"
    version = version.lstrip('v')
    
    zip_path = os.environ.get('ZIP_PATH') or os.path.join(repo_root, 'build', 'ReDuoBar.zip')
    if not os.path.exists(zip_path):
        zip_path = os.path.join(os.environ.get('RUNNER_TEMP', '/tmp'), 'ReDuoBar.zip')
        
    with open(zip_path, 'rb') as f:
        data = f.read()

    size = len(data)

    priv_b64 = os.environ.get('SPARKLE_PRIVATE_KEY') or "BgWmQnqZbpzQnJ5FdT0QMiT0VZXL0J0xCbUfhAUhVzVOKyeoklMD83OL98pVNluzLDYHgb52OnzS0lW0OZYcfg=="
    key_bytes = base64.b64decode(priv_b64)
    private_key = Ed25519PrivateKey.from_private_bytes(key_bytes[:32])

    sig = private_key.sign(data)
    sig_b64 = base64.b64encode(sig).decode()

    date_str = datetime.datetime.now(datetime.timezone.utc).strftime("%a, %d %b %Y %H:%M:%S +0000")

    appcast_content = f"""<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>ReDuoBar</title>
    <link>https://github.com/vibe2code/ReDuoBar</link>
    <description>ReDuoBar releases</description>
    <language>en</language>
    <item>
      <title>ReDuoBar {version}</title>
      <pubDate>{date_str}</pubDate>
      <sparkle:version>{version}</sparkle:version>
      <sparkle:shortVersionString>{version}</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>13.0</sparkle:minimumSystemVersion>
      <description><![CDATA[
        <h2>ReDuoBar {version}</h2>
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
        url="https://github.com/vibe2code/ReDuoBar/releases/download/{tag}/ReDuoBar.zip"
        sparkle:edSignature="{sig_b64}"
        length="{size}"
        type="application/octet-stream"
      />
    </item>
  </channel>
</rss>
"""
    output_path = os.path.join(repo_root, 'appcast.xml')
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(appcast_content)

    print(f"Generated appcast.xml for ReDuoBar {version} (size={size}, sig={sig_b64})")

    # Output for GitHub Actions if running in CI
    gh_out = os.environ.get('GITHUB_OUTPUT')
    if gh_out and os.path.exists(gh_out):
        with open(gh_out, 'a') as out:
            out.write(f"VERSION={version}\n")
            out.write(f"TAG={tag}\n")
            out.write(f"SPARKLE_SIG={sig_b64}\n")
            out.write(f"SIZE={size}\n")

if __name__ == '__main__':
    main()
