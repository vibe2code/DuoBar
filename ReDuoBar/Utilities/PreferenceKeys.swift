enum PreferenceKeys {
    static let showBatteryPercentage = "showBatteryPercentage"
    static let animationsEnabled = "animationsEnabled"
    static let menuBarIconScale = MenuBarIconSize.preferenceKey
    static let batteryColorCoding = "batteryColorCoding"
    static let adaptiveRingPriority = "adaptiveRingPriority"
    static let adaptiveRingColorCoding = "adaptiveRingColorCoding"
    static let openOnHover = "openOnHover"

    // Injected by AppDelegate at launch
    static var updaterService: UpdaterService?

    #if DEBUG
    static let simulateDesktopMac = "debug.simulateDesktopMac"
    #endif
}
