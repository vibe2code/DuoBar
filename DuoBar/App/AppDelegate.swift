import AppKit
import Combine

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
