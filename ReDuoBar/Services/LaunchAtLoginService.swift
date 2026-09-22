import AppKit
import Combine
import Foundation
import ServiceManagement

@MainActor
final class LaunchAtLoginService: ObservableObject {
    @Published private(set) var isEnabled = false
    @Published private(set) var requiresApproval = false
    @Published private(set) var isInstalledInApplications = false
    @Published private(set) var errorMessage: String?

    init() {
        refresh()
    }

    func refresh() {
        let bundlePath = Bundle.main.bundlePath
        let inSystemApps = bundlePath.hasPrefix("/Applications/") || bundlePath == "/Applications/ReDuoBar.app"
        let inUserApps = bundlePath.contains("/Applications/")
        isInstalledInApplications = inSystemApps || inUserApps

        let status = SMAppService.mainApp.status
        isEnabled = status == .enabled || status == .requiresApproval
        requiresApproval = status == .requiresApproval
    }

    func setEnabled(_ enabled: Bool) {
        errorMessage = nil

        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        refresh()
    }

    /// Helper to install or move current app to /Applications/ReDuoBar.app and relaunch
    func installToApplications() {
        let currentBundle = Bundle.main.bundleURL
        let targetApp = URL(fileURLWithPath: "/Applications/ReDuoBar.app")
        let fileManager = FileManager.default

        do {
            if fileManager.fileExists(atPath: targetApp.path) {
                try fileManager.removeItem(at: targetApp)
            }
            try fileManager.copyItem(at: currentBundle, to: targetApp)

            // Relaunch from /Applications/ReDuoBar.app
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.activates = true
            NSWorkspace.shared.openApplication(at: targetApp, configuration: configuration) { _, _ in
                DispatchQueue.main.async {
                    NSApp.terminate(nil)
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
