import Foundation

enum MarketingCaptureMode {
    static let stateNotification = Notification.Name("com.vibe2code.reduobar.debug.marketing-state")
    static let popoverNotification = Notification.Name("com.vibe2code.reduobar.debug.marketing-popover")

    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("--marketing-capture")
    }

    static var initialState: String {
        ProcessInfo.processInfo.arguments
            .first { $0.hasPrefix("--marketing-state=") }?
            .dropFirst("--marketing-state=".count)
            .description ?? "hero"
    }

    static var opensPopover: Bool {
        ProcessInfo.processInfo.arguments.contains("--marketing-popover")
    }

    static var expandsWiFiPicker: Bool {
        ProcessInfo.processInfo.arguments.contains("--marketing-wifi-picker")
    }

    static var expandsAudioPicker: Bool {
        ProcessInfo.processInfo.arguments.contains("--marketing-audio-picker")
    }

    static var opensSettings: Bool {
        ProcessInfo.processInfo.arguments.contains("--marketing-settings")
    }
}
