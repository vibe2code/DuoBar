import AppKit
import Combine
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let isRunningTests: Bool
    private var instanceLock: ApplicationInstanceLock?
    private var statusStore: SystemStatusStore?
    private var menuBarController: MenuBarController?
    private var wakeObserver: NSObjectProtocol?
    private var updaterService: UpdaterService?
    private var marketingCaptureObserver: NSObjectProtocol?
    private var marketingPopoverObserver: NSObjectProtocol?

    override init() {
        isRunningTests = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        UserDefaults.standard.register(defaults: [
            PreferenceKeys.showBatteryPercentage: true,
            PreferenceKeys.animationsEnabled: true,
            PreferenceKeys.menuBarIconScale: MenuBarIconSize.defaultScale,
            PreferenceKeys.batteryColorCoding: false,
            // Sparkle appcast URL — points to GitHub Pages branch
            "SUFeedURL": "https://vibe2code.github.io/DuoBar/appcast.xml",
            "SUPublicEDKey": "TisnqJJTA/Nzi/fKVTZbsyw2B4G+djp80tJVtDmWHH4="
        ])
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard !isRunningTests else { return }
        guard menuBarController == nil else { return }

        let instanceLock = ApplicationInstanceLock()
        guard instanceLock.acquire() else {
            #if DEBUG
            NSLog("[DuoBar] another instance already owns the menu-bar item")
            #endif
            NSApp.terminate(nil)
            return
        }
        self.instanceLock = instanceLock

        NSApp.setActivationPolicy(.accessory)
        let statusStore = SystemStatusStore()
        self.statusStore = statusStore

        // Start auto-updater
        let updaterService = UpdaterService()
        self.updaterService = updaterService
        PreferenceKeys.updaterService = updaterService

        if MarketingCaptureMode.isEnabled {
            statusStore.applyMarketingCaptureState(MarketingCaptureMode.initialState)
            marketingCaptureObserver = DistributedNotificationCenter.default().addObserver(
                forName: MarketingCaptureMode.stateNotification,
                object: nil,
                queue: .main
            ) { [weak statusStore] notification in
                guard let state = notification.userInfo?["state"] as? String else { return }
                Task { @MainActor in
                    statusStore?.applyMarketingCaptureState(state)
                }
            }
        }

        let menuBarController = MenuBarController(statusStore: statusStore)
        self.menuBarController = menuBarController

        if MarketingCaptureMode.isEnabled, MarketingCaptureMode.opensPopover {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak menuBarController] in
                menuBarController?.setPopoverVisibleForMarketingCapture(true)
            }
        }
        if MarketingCaptureMode.opensSettings {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if let appMenu = NSApp.mainMenu?.items.first?.submenu,
                   let settingsItem = appMenu.items.first(where: { $0.keyEquivalent == "," }),
                   let action = settingsItem.action {
                    NSApp.sendAction(action, to: settingsItem.target, from: settingsItem)
                } else {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }
            }

            if ProcessInfo.processInfo.arguments.contains("--save-settings-screenshot") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    if let window = NSApp.windows.first(where: { $0.isVisible && ($0.toolbar != nil || $0.title.contains("Menu Bar") || $0.title.contains("Settings") || $0.title.contains("Строка")) }) {
                        let windowId = window.windowNumber
                        let task = Process()
                        task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
                        task.arguments = ["-l", "\(windowId)", "/Users/pingvi/DATA/GitHub/DuoBar/assets/duobar-settings.png"]
                        try? task.run()
                        task.waitUntilExit()
                        NSLog("[DuoBar] Saved native settings window screenshot with windowNumber \(windowId)!")
                    }
                    NSApp.terminate(nil)
                }
            }
        }
        if MarketingCaptureMode.isEnabled {
            marketingPopoverObserver = DistributedNotificationCenter.default().addObserver(
                forName: MarketingCaptureMode.popoverNotification,
                object: nil,
                queue: .main
            ) { [weak menuBarController] notification in
                guard let visible = notification.userInfo?["visible"] as? Bool else { return }
                Task { @MainActor in
                    menuBarController?.setPopoverVisibleForMarketingCapture(visible)
                }
            }
        }

        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak statusStore] _ in
            Task { @MainActor in
                statusStore?.refresh()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        #if DEBUG
        if let marketingCaptureObserver {
            DistributedNotificationCenter.default().removeObserver(marketingCaptureObserver)
            self.marketingCaptureObserver = nil
        }
        if let marketingPopoverObserver {
            DistributedNotificationCenter.default().removeObserver(marketingPopoverObserver)
            self.marketingPopoverObserver = nil
        }
        #endif

        if let wakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(wakeObserver)
            self.wakeObserver = nil
        }
        menuBarController?.invalidate()
        menuBarController = nil
        statusStore = nil
        instanceLock?.release()
        instanceLock = nil
    }
}
