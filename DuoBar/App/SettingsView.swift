import ServiceManagement
import SwiftUI

struct SettingsView: View {
    enum SettingsTab: String, Hashable {
        case general
        case menuBar
        case battery
        case about
        #if DEBUG
        case debug
        #endif
    }

    @AppStorage(PreferenceKeys.showBatteryPercentage) private var showBatteryPercentage = true
    @AppStorage(PreferenceKeys.animationsEnabled) private var animationsEnabled = true
    @AppStorage(PreferenceKeys.menuBarIconScale) private var menuBarIconScale = MenuBarIconSize.defaultScale
    @AppStorage(PreferenceKeys.batteryColorCoding) private var batteryColorCoding = false
    @AppStorage(PreferenceKeys.adaptiveRingPriority) private var adaptiveRingPriorityRaw = PerformancePreference.automatic.rawValue
    @AppStorage(PreferenceKeys.adaptiveRingColorCoding) private var adaptiveRingColorCoding = false
    @AppStorage(PreferenceKeys.openOnHover) private var openOnHover = false
    @StateObject private var launchAtLogin = LaunchAtLoginService()
    @ObservedObject private var adaptiveRingMonitor = AdaptiveRingMonitor.shared
    private let deviceContextService = DeviceContextService()

    @State private var selectedTab: SettingsTab

    init(initialTab: SettingsTab = (ProcessInfo.processInfo.arguments.contains("--marketing-settings") ? .menuBar : .general)) {
        _selectedTab = State(initialValue: initialTab)
    }

    #if DEBUG
    @AppStorage(PreferenceKeys.simulateDesktopMac) private var simulateDesktopMac = false
    #endif

    var body: some View {
        TabView(selection: $selectedTab) {
            generalTab
                .tabItem {
                    Label(localized("General"), systemImage: "gearshape")
                }
                .tag(SettingsTab.general)

            menuBarTab
                .tabItem {
                    Label(localized("Menu Bar"), systemImage: "menubar.rectangle")
                }
                .tag(SettingsTab.menuBar)

            if showsBatteryRingSettings || showsAdaptiveRingSettings {
                batteryTab
                    .tabItem {
                        Label(localized("Battery & Power"), systemImage: "battery.100.bolt")
                    }
                    .tag(SettingsTab.battery)
            }

            aboutTab
                .tabItem {
                    Label(localized("About"), systemImage: "info.circle")
                }
                .tag(SettingsTab.about)

            #if DEBUG
            if !MarketingCaptureMode.isEnabled {
                debugTab
                    .tabItem {
                        Label(localized("Developer"), systemImage: "hammer")
                    }
                    .tag(SettingsTab.debug)
            }
            #endif
        }
        .frame(width: 480, height: tabHeight)
        .background(WindowConfigurator())
        .background(
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow, state: .active)
                .ignoresSafeArea()
        )
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
            launchAtLogin.refresh()
            if showsAdaptiveRingSettings {
                adaptiveRingMonitor.setPreference(adaptiveRingPriority.wrappedValue)
            }
        }
        .onChange(of: adaptiveRingPriorityRaw) { _ in
            if showsAdaptiveRingSettings {
                adaptiveRingMonitor.setPreference(adaptiveRingPriority.wrappedValue)
            }
        }
    }

    private var tabHeight: CGFloat {
        #if DEBUG
        if selectedTab == .debug { return 700 }
        #endif
        switch selectedTab {
        case .general: return 270
        case .menuBar: return 430
        case .battery: return 310
        case .about: return 320
        #if DEBUG
        case .debug: return 700
        #endif
        }
    }

    // MARK: - General Tab

    private var generalTab: some View {
        ScrollView {
            VStack(spacing: 14) {
                SettingsSectionCard(title: localized("Startup")) {
                    SettingsCardRow(
                        icon: "arrow.right.circle.fill",
                        iconColor: .blue,
                        title: localized("Launch DuoBar at login"),
                        subtitle: localized("Automatically launch DuoBar when you log into your Mac.")
                    ) {
                        Toggle("", isOn: Binding(
                            get: { launchAtLogin.isEnabled },
                            set: launchAtLogin.setEnabled
                        ))
                        .toggleStyle(.switch)
                        .labelsHidden()
                    }

                    if launchAtLogin.requiresApproval {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)
                            Text(localized("Approval is required in System Settings → General → Login Items."))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 4)
                    }

                    if let errorMessage = launchAtLogin.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .textSelection(.enabled)
                    }
                }

                SettingsSectionCard(title: localized("Interaction")) {
                    SettingsCardRow(
                        icon: "hand.point.up.left.fill",
                        iconColor: .purple,
                        title: localized("Open on Hover"),
                        subtitle: localized("Open DuoBar when the pointer moves over the menu bar icon.")
                    ) {
                        Toggle("", isOn: $openOnHover)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }
                }
            }
            .padding(16)
        }
        .scrollContentBackground(.hidden)
    }

    // MARK: - Menu Bar Tab

    private var menuBarTab: some View {
        ScrollView {
            VStack(spacing: 14) {
                SettingsSectionCard(title: localized("Preview")) {
                    MenuBarLivePreview(scale: resolvedMenuBarIconScale.wrappedValue)
                }

                SettingsSectionCard(title: localized("Appearance")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            SettingsIconLabel(icon: "arrow.left.and.right", iconColor: .purple)
                            Text(localized("Icon Size"))
                                .font(.system(size: 13))

                            Spacer()

                            Text("\(Int((resolvedMenuBarIconScale.wrappedValue * 100).rounded()))%")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Color.primary.opacity(0.06), in: Capsule())
                        }

                        HStack(spacing: 12) {
                            Text(localized("Small"))
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            Slider(
                                value: resolvedMenuBarIconScale,
                                in: MenuBarIconSize.minimumScale...MenuBarIconSize.maximumScale,
                                step: MenuBarIconSize.step
                            )
                            .accessibilityLabel(localized("Menu bar icon size"))

                            Text(localized("Large"))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Text(localized("Adjust DuoBar to better match your menu bar."))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }

                SettingsSectionCard(title: localized("Behavior")) {
                    SettingsCardRow(
                        icon: "percent",
                        iconColor: .green,
                        title: localized("Show battery percentage in popover"),
                        subtitle: nil
                    ) {
                        Toggle("", isOn: $showBatteryPercentage)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    Divider().opacity(0.4)

                    SettingsCardRow(
                        icon: "sparkles",
                        iconColor: .pink,
                        title: localized("Enable animations"),
                        subtitle: nil
                    ) {
                        Toggle("", isOn: $animationsEnabled)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }
                }
            }
            .padding(16)
        }
        .scrollContentBackground(.hidden)
    }

    // MARK: - Battery & Power Tab

    private var batteryTab: some View {
        ScrollView {
            VStack(spacing: 14) {
                if showsBatteryRingSettings {
                    SettingsSectionCard(title: localized("Battery Ring")) {
                        SettingsCardRow(
                            icon: "paintpalette.fill",
                            iconColor: .orange,
                            title: localized("Battery Color Coding"),
                            subtitle: localized("Color the battery ring green, yellow, or red based on charge level.")
                        ) {
                            Toggle("", isOn: $batteryColorCoding)
                                .toggleStyle(.switch)
                                .labelsHidden()
                        }
                    }
                }

                if showsAdaptiveRingSettings {
                    SettingsSectionCard(title: localized("Adaptive Ring")) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                SettingsIconLabel(icon: "gauge.with.dots.needle.bottom.50percent", iconColor: .indigo)
                                Text(localized("Adaptive Ring Priority"))
                                    .font(.system(size: 13))

                                Spacer()

                                Picker("", selection: adaptiveRingPriority) {
                                    ForEach(PerformancePreference.allCases, id: \.self) { preference in
                                        Text(preference.localizedDisplayName).tag(preference)
                                    }
                                }
                                .labelsHidden()
                                .pickerStyle(.menu)
                                .frame(maxWidth: 160)
                            }

                            Text(localized("Used only when multiple system conditions need attention. Critical conditions can still take priority."))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)

                        Divider().opacity(0.4)

                        SettingsCardRow(
                            icon: "slider.horizontal.2.square",
                            iconColor: .mint,
                            title: localized("Adaptive Ring Color Coding"),
                            subtitle: nil
                        ) {
                            Toggle("", isOn: $adaptiveRingColorCoding)
                                .toggleStyle(.switch)
                                .labelsHidden()
                        }
                    }
                }
            }
            .padding(16)
        }
        .scrollContentBackground(.hidden)
    }

    // MARK: - About Tab

    private var aboutTab: some View {
        VStack(spacing: 16) {
            Spacer()

            // App Icon with macOS drop shadow & border
            if let iconImage = NSImage(named: "AppIcon") ?? NSApp.applicationIconImage {
                Image(nsImage: iconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 72, height: 72)
                    .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 3)
            } else {
                Image(systemName: "gauge.with.dots.needle.bottom.50percent")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.accentColor)
            }

            VStack(spacing: 4) {
                Text("DuoBar")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    Text("Version 1.2.0")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)

                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)

                    Text("Build 4")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.primary.opacity(0.05), in: Capsule())

                Text(localized("Lightweight, native status & monitor for your macOS menu bar."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
                    .padding(.horizontal, 32)
            }

            HStack(spacing: 12) {
                Button(action: {
                    PreferenceKeys.updaterService?.checkForUpdates()
                }) {
                    Label(localized("Check for Updates…"), systemImage: "arrow.triangle.2.circlepath")
                }
                .controlSize(.regular)
                .disabled(!(PreferenceKeys.updaterService?.canCheckForUpdates ?? false))

                if let gitHubURL = URL(string: "https://github.com/vibe2code/DuoBar") {
                    Link(destination: gitHubURL) {
                        Label("GitHub", systemImage: "link")
                    }
                    .controlSize(.regular)
                }
            }
            .padding(.top, 4)

            Spacer()

            Text("Released under the MIT License.")
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
                .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
    }

    // MARK: - Debug Tab

    #if DEBUG
    private var debugTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DebugPerformanceDiagnosticsView()
                DebugDuoGlyphTuningView()
            }
            .padding(16)
        }
    }
    #endif

    // MARK: - Helpers

    private var adaptiveRingPriority: Binding<PerformancePreference> {
        Binding(
            get: { PerformancePreference(rawValue: adaptiveRingPriorityRaw) ?? .automatic },
            set: { adaptiveRingPriorityRaw = $0.rawValue }
        )
    }

    private var resolvedMenuBarIconScale: Binding<Double> {
        Binding(
            get: { MenuBarIconSize.resolve(menuBarIconScale) },
            set: { menuBarIconScale = MenuBarIconSize.resolve($0) }
        )
    }

    private var showsAdaptiveRingSettings: Bool {
        #if DEBUG
        AdaptiveRingSettingsEligibility.isEligible(
            for: deviceContextService.current(),
            simulateDesktop: simulateDesktopMac
        )
        #else
        AdaptiveRingSettingsEligibility.isEligible(for: deviceContextService.current())
        #endif
    }

    private var showsBatteryRingSettings: Bool {
        #if DEBUG
        deviceContextService.current(simulateDesktop: simulateDesktopMac).ringBehavior == .batteryRing
        #else
        deviceContextService.current().ringBehavior == .batteryRing
        #endif
    }
}

// MARK: - Native Styling Components

private struct SettingsSectionCard<Content: View>: View {
    let title: String?
    @ViewBuilder let content: () -> Content

    init(title: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }

            VStack(spacing: 8) {
                content()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(nsColor: .controlBackgroundColor).opacity(0.35))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                    )
            )
        }
    }
}

private struct SettingsIconLabel: View {
    let icon: String
    let iconColor: Color

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 22, height: 22)
            .background(iconColor, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
    }
}

private struct SettingsCardRow<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(spacing: 12) {
            SettingsIconLabel(icon: icon, iconColor: iconColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundStyle(.primary)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 8)

            content()
        }
        .padding(.vertical, 3)
    }
}

private struct MenuBarLivePreview: View {
    let scale: Double

    private static let previewStatus = SystemStatus(
        battery: BatteryStatus(
            percentage: 82,
            isCharging: false,
            isPluggedIn: true,
            isFullyCharged: false,
            isAvailable: true
        ),
        network: NetworkStatus(
            isAvailable: true,
            isConnected: true,
            transport: .wifi,
            interfaceName: "en0",
            isWiFiPoweredOn: true,
            ssid: "Wi-Fi",
            rssi: -45
        ),
        audio: AudioStatus(
            isAvailable: true,
            volume: OutputVolumeStatus(level: 0.75, isMuted: false, isSettable: true, isMuteSettable: true)
        ),
        bluetooth: BluetoothStatus(isAvailable: true, isPoweredOn: true)
    )

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                Text(localized("Simulated Menu Bar"))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer()

                // Authentic DuoBar glyph rendering matching real macOS menu bar
                DuoGlyphView(
                    status: Self.previewStatus,
                    metrics: DuoGlyphMetrics.standard.scaled(by: scale),
                    animationsEnabled: false
                )
                .frame(
                    width: DuoGlyphMetrics.standard.scaled(by: scale).statusItemWidth,
                    height: 22
                )

                // Standard macOS menu bar indicators
                Image(systemName: "switch.2")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                Text("9:41")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Window Translucency & Materials

private final class WindowConfigView: NSView {
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        applyWindowTranslucency()
    }

    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        applyWindowTranslucency()
    }

    private func applyWindowTranslucency() {
        guard let window = self.window else { return }
        window.isOpaque = false
        window.backgroundColor = .clear
        window.titlebarAppearsTransparent = true

        if let themeFrame = window.contentView?.superview {
            let identifier = NSUserInterfaceItemIdentifier("DuoBarWindowVisualEffect")
            if !themeFrame.subviews.contains(where: { $0.identifier == identifier }) {
                let effectView = NSVisualEffectView(frame: themeFrame.bounds)
                effectView.identifier = identifier
                effectView.autoresizingMask = [.width, .height]
                effectView.material = .sidebar
                effectView.blendingMode = .behindWindow
                effectView.state = .active
                themeFrame.addSubview(effectView, positioned: .below, relativeTo: nil)
            }
        }
    }
}

private struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> WindowConfigView {
        WindowConfigView()
    }

    func updateNSView(_ nsView: WindowConfigView, context: Context) {
        DispatchQueue.main.async {
            nsView.viewDidMoveToWindow()
        }
    }
}

private struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .sidebar
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    var state: NSVisualEffectView.State = .active

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
    }
}

