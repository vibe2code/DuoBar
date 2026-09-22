import Foundation
import Security

/// Manages secure retrieval and persistence of Wi-Fi credentials in macOS Keychain.
final class WiFiKeychainService {
    static let shared = WiFiKeychainService()

    private let serviceIdentifier = "com.vibe2code.reduobar.wifi"

    private init() {}

    // MARK: - App-managed Keychain Storage

    /// Retrieves a saved password for the given SSID from ReDuoBar's private Keychain item.
    func getSavedPassword(for ssid: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: ssid,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    /// Saves or updates the password for the given SSID in ReDuoBar's private Keychain item.
    func savePassword(_ password: String, for ssid: String) {
        guard let data = password.data(using: .utf8) else { return }

        // Try deleting existing entry first
        deletePassword(for: ssid)

        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: ssid,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemAdd(attributes as CFDictionary, nil)
    }

    /// Deletes the saved password for the given SSID from ReDuoBar's private Keychain.
    func deletePassword(for ssid: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: ssid
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - System Keychain & Known Network Detection

    /// Checks if macOS System Keychain knows this Wi-Fi network without prompting the user.
    func isKnownSystemNetwork(ssid: String) -> Bool {
        // Fast non-prompting metadata check via `security` command
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
        process.arguments = [
            "find-generic-password",
            "-D", "AirPort network password",
            "-a", ssid
        ]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    /// Asynchronously attempts to read the Wi-Fi password from the macOS System Keychain.
    /// Note: macOS may present a standard keychain authorization prompt on first read.
    func fetchSystemPassword(for ssid: String, timeoutSeconds: Double = 3.0) async -> String? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
                process.arguments = [
                    "find-generic-password",
                    "-D", "AirPort network password",
                    "-a", ssid,
                    "-w"
                ]

                let outputPipe = Pipe()
                process.standardOutput = outputPipe
                process.standardError = Pipe()

                var hasResumed = false
                let timer = DispatchSource.makeTimerSource(queue: .global())
                timer.schedule(deadline: .now() + timeoutSeconds)
                timer.setEventHandler {
                    if !hasResumed {
                        hasResumed = true
                        if process.isRunning { process.terminate() }
                        continuation.resume(returning: nil)
                    }
                }
                timer.resume()

                do {
                    try process.run()
                    process.waitUntilExit()
                    timer.cancel()
                    if !hasResumed {
                        hasResumed = true
                        if process.terminationStatus == 0 {
                            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
                            if let raw = String(data: data, encoding: .utf8)?
                                .trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty {
                                continuation.resume(returning: raw)
                                return
                            }
                        }
                        continuation.resume(returning: nil)
                    }
                } catch {
                    timer.cancel()
                    if !hasResumed {
                        hasResumed = true
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }
}
