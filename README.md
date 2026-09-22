<div align="center">

<img src="assets/app-icon.png" alt="DuoBar App Icon" width="110" height="110">

# DuoBar

### The all-in-one macOS menu bar indicator for Battery, Network, and Volume — Reimagined.

**Three live states. One glyph. Zero menu bar clutter.**

[![Latest Release](https://img.shields.io/github/v/release/vibe2code/DuoBar?style=for-the-badge&color=007AFF&label=Release)](https://github.com/vibe2code/DuoBar/releases/latest)
[![Build CI](https://img.shields.io/github/actions/workflow/status/vibe2code/DuoBar/build.yml?branch=main&style=for-the-badge&label=Build%20CI)](https://github.com/vibe2code/DuoBar/actions/workflows/build.yml)
[![Release CI](https://img.shields.io/github/actions/workflow/status/vibe2code/DuoBar/release.yml?style=for-the-badge&label=Release%20CI)](https://github.com/vibe2code/DuoBar/actions/workflows/release.yml)
[![Platform](https://img.shields.io/badge/Platform-macOS%2013%2B-lightgrey?style=for-the-badge&logo=apple)](https://github.com/vibe2code/DuoBar/releases)
[![Architecture](https://img.shields.io/badge/Arch-Universal%20(arm64%20%2B%20x86__64)-informational?style=for-the-badge)](https://github.com/vibe2code/DuoBar/releases)
[![Languages](https://img.shields.io/badge/Languages-17%20Locales-orange?style=for-the-badge)](https://github.com/vibe2code/DuoBar#--17-world-languages-supported)
[![License](https://img.shields.io/github/license/vibe2code/DuoBar?style=for-the-badge&color=brightgreen)](LICENSE)

<br>

[**⬇️ Download Latest Release**](https://github.com/vibe2code/DuoBar/releases/latest) · [**🌐 Official Website**](https://vibe2code.github.io/DuoBar/) · [**✨ What's New**](#-comparison-original-duobar-vs-modern-duobar) · [**📖 Documentation**](#-installation) · [**💬 Report Issue**](https://github.com/vibe2code/DuoBar/issues)

<br>

<table align="center">
  <tr>
    <td align="center" width="33%">
      <b>Status Popover</b><br>
      <i>3-in-1 live system control</i><br><br>
      <img src="assets/duobar-popover.png" alt="DuoBar Popover" width="280">
    </td>
    <td align="center" width="33%">
      <b>Wi-Fi Picker & Power</b><br>
      <i>CoreWLAN scan & 1-click switch</i><br><br>
      <img src="assets/duobar-wifi-picker.png" alt="Wi-Fi Picker" width="280">
    </td>
    <td align="center" width="33%">
      <b>Audio Output Switcher</b><br>
      <i>Core Audio peripheral switcher</i><br><br>
      <img src="assets/duobar-audio-picker.png" alt="Audio Output Picker" width="280">
    </td>
  </tr>
  <tr>
    <td align="center" width="33%">
      <b>General & Hover</b><br>
      <i>Launch at login & Open on Hover</i><br><br>
      <img src="assets/duobar-general.png" alt="DuoBar General Settings" width="280">
    </td>
    <td align="center" width="33%">
      <b>Menu Bar & Preview</b><br>
      <i>Scaling slider & simulated bar</i><br><br>
      <img src="assets/duobar-settings.png" alt="DuoBar Menu Bar Settings" width="280">
    </td>
    <td align="center" width="33%">
      <b>About & Updates</b><br>
      <i>Version 1.2.0 & Sparkle update</i><br><br>
      <img src="assets/duobar-about.png" alt="DuoBar About Dialog" width="280">
    </td>
  </tr>
</table>

</div>

---

## ⚡ Overview

DuoBar adapts the unified 3-in-1 status concept for your Mac's menu bar. Instead of cluttering your menu bar with separate battery, Wi-Fi, and volume icons, DuoBar combines them into a single, elegant glyph:

* **Outer Ring:** Live Battery Ring on MacBooks (charge level, dynamic bolt, low-power states) or Adaptive Performance Ring on desktop Macs.
* **Center Glyph:** Active network indicator (Wi-Fi signal strength, Ethernet, or offline state) with dynamic AirPods connection animations.
* **Lower Dots:** Four live dots representing output volume.

Modern DuoBar elevates this visual concept into a **fully interactive, system-grade macOS utility** featuring direct network and audio switching, native frosted-glass settings, Sparkle automatic updates, and 17 localizations.

---

## ⚔️ Comparison: Original DuoBar vs. Modern DuoBar

| Feature / Capability | Original DuoBar (v1.0.0) | Modern DuoBar (vibe2code) | Impact & Improvements |
| :--- | :---: | :---: | :--- |
| **📶 Wi-Fi Network Picker** | ❌ None *(Static text)* | **✅ Full Interactive Picker** | Scans surrounding Wi-Fi networks in real-time via CoreWLAN, displays signal bars (3 tiers), security badges, and enables 1-click network connection with password dialog. |
| **⚡ Wi-Fi Power Control** | ❌ None | **✅ 1-Click Power Toggle** | Turn Wi-Fi module on or off instantly directly from the popover or network picker header. |
| **🎧 Audio Output Selector** | ❌ None *(Static text)* | **✅ Interactive Switcher** | Direct Core Audio device enumeration. Switch output seamlessly between Built-in Speakers, AirPods, Bluetooth headsets, HDMI, and USB DACs right from the popover. |
| **👆 Open on Hover** | ❌ None | **✅ Instant Hover Reveal** | Optional toggle in Settings to open the status popover automatically when hovering over the menu bar icon. |
| **🔋 Laptop Adaptive Ring** | ❌ None | **✅ Smart 100% Handover** | When a MacBook is plugged in and reaches full charge, DuoBar automatically transitions the ring to display CPU / thermal load or display brightness. |
| **🪟 Settings Window Design** | ⚠️ Basic Gray Form | **✅ Frosted Glass Translucency** | Native macOS Ventura/Sonoma/Sequoia styling using `NSVisualEffectView` (`.behindWindow`), translucent material cards, and transparent titlebar. |
| **👁️ Live Glyph Preview** | ❌ None | **✅ Live Settings Preview** | Interactive preview of the menu bar glyph inside the Settings window with real-time size adjustment. |
| **🌍 Localizations** | ⚠️ 3 Languages *(en, zh-Hans, zh-Hant)* | **✅ 17 World Languages** | Full native translations with auto system language detection: English, Russian, Ukrainian, Greek, German, French, Spanish, Italian, Portuguese (BR), Japanese, Korean, Chinese, Arabic, Hindi, Turkish, Polish. |
| **🔄 Auto-Updates** | ❌ None *(Manual download)* | **✅ Sparkle 2 + Ed25519** | Fully automated background updates signed with Ed25519 keys, hosted on GitHub Pages appcast feed. Includes in-app "Check for Updates..." button. |
| **🎨 App Icon & Branding** | ❌ Xcode Placeholder | **✅ High-Res Retina Icon** | Custom polished metallic dark icon (`AppIcon.icns` & 256×256 PNG) integrated into the `.app` bundle, Dock, and About window. |
| **⚙️ CLI Packaging** | ❌ Xcode IDE Only | **✅ Standalone `build-app.sh`** | Build, bundle, sign, and package a standalone `DuoBar.app` using `swift build` directly from the command line without opening Xcode. |
| **🤖 GitHub Actions CI/CD** | ❌ None | **✅ Automated CI & Releases** | Automated build verification on every commit/PR (`build.yml`), plus automated releases and appcast deployments (`release.yml`). |
| **📏 Menu Bar Sizing** | ⚠️ Static size | **✅ Scaling Slider** | Granular icon scaling control with real-time feedback to fit any display notch or resolution. |
| **🚀 Launch at Login** | ⚠️ Rudimentary | **✅ Native `SMAppService`** | Robust Ventura/Sonoma/Sequoia `SMAppService` integration with system approval status tracking. |

---

## 🌟 Key Innovations & Enhancements

### 📶 Interactive Wi-Fi Network Picker & ⚡ 1-Click Power Toggle
No more navigating through macOS System Settings or Control Center just to connect to a hotspot or toggle Wi-Fi:
* **Live Network Discovery:** Scans surrounding Wi-Fi networks in real-time using `CoreWLAN`.
* **Visual Status Indicators:** Multi-tier signal strength icons (Strong, Good, Weak) and security lock badges (WPA2/WPA3).
* **Instant Power Switch:** Turn your Mac's Wi-Fi interface ON or OFF with a single click directly from the popover or network header.
* **Seamless Connection:** Connect to networks with a native password prompt and immediate status confirmation.

### 🎧 Seamless Audio Output Switcher
Instantly redirect system audio without opening Control Center or Sound preferences:
* **Core Audio Integration:** Enumerates all active output devices (MacBook Speakers, AirPods, Bluetooth headphones, Studio Display, HDMI, and USB DACs).
* **Direct 1-Click Switching:** Select your output destination with instant feedback and active checkmark.
* **Per-Device Glyphs:** Tailored SF Symbols for AirPods Pro, over-ear headphones, displays, and built-in speakers.

### 👆 Open on Hover (Instant Hover Reveal)
Access your system status faster than ever:
* **Frictionless Interaction:** Open the DuoBar popover automatically simply by moving your mouse cursor over the menu bar icon.
* **Intelligent Tracking:** Built-in debounce and hover-tracking container prevents accidental triggers and unwanted flicker.
* **Customizable:** Toggle on or off anytime in **Settings → General**.

### 🔋 Laptop Adaptive Ring (100% Full Charge Handover)
Maximizing the utility of your menu bar space:
* **Smart Charge Transition:** When your MacBook is plugged in and reaches 100% battery, DuoBar automatically transitions the outer ring from battery status to an adaptive system performance monitor (display brightness, CPU load, or thermals).
* **Desktop Mac Support:** On iMac, Mac mini, and Mac Studio, DuoBar defaults to the adaptive system ring out of the box.

### 🪟 Native Translucent macOS Settings
Designed from the ground up to match modern macOS Sequoia and Sonoma styling:
* **Frosted Glass Vibrancy:** Powered by `NSVisualEffectView` with `.behindWindow` blending and `.ultraThinMaterial` grouped cards.
* **Structured Tabs:**
  * **General:** Launch at login (`SMAppService`) and Open on Hover interaction.
  * **Menu Bar:** Granular icon scaling slider (Small to Large) with a **Live Simulated Menu Bar** preview, animation controls, and popover battery percentage toggle.
  * **Battery & Power:** Custom battery color-coding and low-power alert thresholds.
  * **About:** Version info (Version 1.2.0 • Build 4), MIT License details, GitHub repository link, and centralized Sparkle update checker.

### 🌐 17 World Languages Supported
DuoBar automatically detects and adapts to your macOS system language on launch:

| Flag | Language | Flag | Language |
| :---: | :--- | :---: | :--- |
| 🇺🇸 | **English** (`en`) | 🇯🇵 | **日本語** (`ja`) |
| 🇷🇺 | **Русский** (`ru`) | 🇰🇷 | **한국어** (`ko`) |
| 🇺🇦 | **Українська** (`uk`) | 🇨🇳 | **简体中文** (`zh-Hans`) |
| 🇬🇷 | **Ελληνικά** (`el`) | 🇹🇼 | **繁體中文** (`zh-Hant`) |
| 🇩🇪 | **Deutsch** (`de`) | 🇸🇦 | **العربية** (`ar`) |
| 🇫🇷 | **Français** (`fr`) | 🇮🇳 | **हिन्दी** (`hi`) |
| 🇪🇸 | **Español** (`es`) | 🇹🇷 | **Türkçe** (`tr`) |
| 🇮🇹 | **Italiano** (`it`) | 🇵🇱 | **Polski** (`pl`) |
| 🇧🇷 | **Português (Brasil)** (`pt-BR`) | | |

### 🔄 Automatic Updates via Sparkle 2 & GitHub Pages
* Built on the robust **Sparkle 2** auto-update framework.
* Every binary release is cryptographically signed using **Ed25519 (EdDSA)**.
* Appcast manifest (`appcast.xml`) is continuously updated and hosted via **GitHub Pages** (`https://vibe2code.github.io/DuoBar/appcast.xml`).
* Centralized "Check for Updates..." button in the About tab, plus silent background update checks.

---

## 🚀 GitHub Actions Automation

DuoBar features a robust CI/CD pipeline on GitHub Actions:

* **[Build CI (`build.yml`)](.github/workflows/build.yml):**
  * Automatically triggered on every `push` and `pull_request` to `main`.
  * Runs on `macos-15` runner.
  * Compiles release binaries, generates the `.app` bundle, validates code signing, and creates downloadable `DuoBar.zip` build artifacts.
* **[Release CI (`release.yml`)](.github/workflows/release.yml):**
  * Automatically triggered on git tags (e.g. `v1.2.0`) or manual workflow dispatch.
  * Generates cryptographically signed Sparkle appcast entries with Ed25519.
  * Publishes GitHub Releases with release notes and attachments.
  * Deploys updated `appcast.xml` and download portal to the `gh-pages` branch.

---

## 📥 Installation

### Direct Download
1. Download the latest `DuoBar.zip` from [**GitHub Releases**](https://github.com/vibe2code/DuoBar/releases/latest).
2. Unzip and drag `DuoBar.app` to your `/Applications` folder.
3. Launch **DuoBar**.

> [!NOTE]
> Because community builds are ad-hoc signed, macOS Gatekeeper may show a warning on first launch. If prompted, right-click `DuoBar.app` and select **Open**, or navigate to **System Settings → Privacy & Security → Open Anyway**.

---

## 🔨 Building from Source

### Prerequisites
* macOS 13.0+ (Ventura, Sonoma, Sequoia)
* Xcode 15+ or Swift 5.9+ Command Line Tools (`xcode-select --install`)

### Fast Build via Terminal
You can build and package a complete standalone `DuoBar.app` with a single command:

```bash
git clone https://github.com/vibe2code/DuoBar.git
cd DuoBar

# Build release and package into build/DuoBar.app
chmod +x ./tools/build-app.sh
./tools/build-app.sh
```

The output will be available at `build/DuoBar.app`.

### Using Xcode IDE
Open `DuoBar.xcodeproj` in Xcode, select the **DuoBar** target, and press **Cmd + R**.

---

## 🔒 Privacy & Permissions

* **100% Local Processing:** All battery, network, and audio data is processed strictly on-device.
* **Zero Telemetry:** No analytics, no tracking, and no third-party data collection.
* **Network Permissions:**
  * **Location Services:** macOS requires location permission for `CoreWLAN` to display Wi-Fi network names (SSIDs). Denying this permission will still allow DuoBar to display signal strength and interface status.
  * **Bluetooth:** Used via Core Audio to identify active AirPods and audio peripherals.

---

## 📄 License & Acknowledgements

* Licensed under the [MIT License](LICENSE).
* Re-engineered and expanded by [**vibe2code**](https://github.com/vibe2code).
* Original concept and foundation inspired by [DuoBar by Mikeli7666](https://github.com/Mikeli7666/DuoBar).
