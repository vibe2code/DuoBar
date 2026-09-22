import SwiftUI

struct WiFiNetworkPickerView: View {
    let currentSSID: String?
    let onConnect: (_ ssid: String, _ password: String?) async -> Bool
    let onOpenSettings: () -> Void

    @State private var networks: [WiFiNetworkInfo] = []
    @State private var isScanning = false
    @State private var passwordTarget: WiFiNetworkInfo? = nil
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var savePassword = true
    @State private var isFromKeychain = false
    @State private var isFetchingSystemPassword = false
    @State private var isConnecting = false
    @State private var connectionError = false

    var body: some View {
        VStack(spacing: 0) {
            if isScanning && networks.isEmpty {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.75)
                    Text(localized("Scanning…"))
                        .font(.system(size: 11.5))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            } else if networks.isEmpty {
                Text(localized("No networks found"))
                    .font(.system(size: 11.5))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            } else {
                VStack(spacing: 2) {
                    ForEach(networks) { network in
                        WiFiNetworkRow(
                            network: network,
                            isSelected: network.ssid == currentSSID,
                            isConnecting: isConnecting && passwordTarget?.ssid == network.ssid,
                            showingPassword: passwordTarget?.ssid == network.ssid,
                            password: $password,
                            isPasswordVisible: $isPasswordVisible,
                            savePassword: $savePassword,
                            isFromKeychain: isFromKeychain,
                            isFetchingSystemPassword: isFetchingSystemPassword && passwordTarget?.ssid == network.ssid,
                            connectionError: connectionError && passwordTarget?.ssid == network.ssid,
                            onTap: { handleNetworkTap(network) },
                            onConnect: { handleConnect(network) },
                            onCancelPassword: { cancelPassword() }
                        )
                    }
                }
            }

            Divider()
                .padding(.vertical, 6)

            Button(action: onOpenSettings) {
                HStack(spacing: 6) {
                    Image(systemName: "wifi")
                        .font(.system(size: 11))
                    Text(localized("Wi-Fi Settings…"))
                        .font(.system(size: 11.5, weight: .medium))
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 4)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.primary.opacity(0.035), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        .transition(.opacity.combined(with: .move(edge: .top)))
        .task { await scan() }
    }

    private func scan() async {
        isScanning = true
        networks = await onConnect("__scan__", nil) == false
            ? []
            : []
        isScanning = false
    }

    fileprivate func loadNetworks(_ loaded: [WiFiNetworkInfo]) {
        networks = loaded
        isScanning = false
    }

    private func handleNetworkTap(_ network: WiFiNetworkInfo) {
        connectionError = false
        if network.ssid == currentSSID { return }
        if network.isSecured {
            withAnimation(.spring(response: 0.3)) {
                passwordTarget = network
                password = ""
                isPasswordVisible = false
                savePassword = true
                isFromKeychain = false
                isFetchingSystemPassword = false
            }

            if let saved = WiFiKeychainService.shared.getSavedPassword(for: network.ssid) {
                password = saved
                isFromKeychain = true
                return
            }

            if WiFiKeychainService.shared.isKnownSystemNetwork(ssid: network.ssid) {
                isFetchingSystemPassword = true
                Task {
                    if let sysPwd = await WiFiKeychainService.shared.fetchSystemPassword(for: network.ssid, timeoutSeconds: 3.5) {
                        await MainActor.run {
                            if passwordTarget?.ssid == network.ssid {
                                password = sysPwd
                                isFromKeychain = true
                                isFetchingSystemPassword = false
                                WiFiKeychainService.shared.savePassword(sysPwd, for: network.ssid)
                            }
                        }
                    } else {
                        await MainActor.run {
                            if passwordTarget?.ssid == network.ssid {
                                isFetchingSystemPassword = false
                            }
                        }
                    }
                }
            }
        } else {
            Task { await connectDirect(to: network, password: nil) }
        }
    }

    private func handleConnect(_ network: WiFiNetworkInfo) {
        let pwd = password.isEmpty ? nil : password
        let shouldSave = savePassword
        Task {
            let success = await connectDirect(to: network, password: pwd)
            if success && shouldSave, let pwd, !pwd.isEmpty {
                WiFiKeychainService.shared.savePassword(pwd, for: network.ssid)
            }
        }
    }

    @discardableResult
    private func connectDirect(to network: WiFiNetworkInfo, password: String?) async -> Bool {
        isConnecting = true
        connectionError = false
        let success = await onConnect(network.ssid, password)
        isConnecting = false
        if success {
            withAnimation { passwordTarget = nil }
        } else {
            connectionError = true
        }
        return success
    }

    private func cancelPassword() {
        withAnimation(.spring(response: 0.3)) {
            passwordTarget = nil
            password = ""
            isPasswordVisible = false
            savePassword = true
            isFromKeychain = false
            isFetchingSystemPassword = false
            connectionError = false
        }
    }
}

// MARK: - WiFiNetworkRow

private struct WiFiNetworkRow: View {
    let network: WiFiNetworkInfo
    let isSelected: Bool
    let isConnecting: Bool
    let showingPassword: Bool
    @Binding var password: String
    @Binding var isPasswordVisible: Bool
    @Binding var savePassword: Bool
    let isFromKeychain: Bool
    let isFetchingSystemPassword: Bool
    let connectionError: Bool
    let onTap: () -> Void
    let onConnect: () -> Void
    let onCancelPassword: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 10) {
                    signalIcon
                        .frame(width: 20)

                    Text(network.ssid)
                        .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? .primary : .secondary)
                        .lineLimit(1)

                    Spacer(minLength: 4)

                    if network.isSecured {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.tertiary)
                    }

                    if isSelected && !isConnecting {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.accentColor)
                    } else if isConnecting {
                        ProgressView().scaleEffect(0.6)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 7)
                .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear,
                            in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)

            if showingPassword {
                VStack(spacing: 7) {
                    // Password Input Field with Show/Hide Eye Button
                    HStack(spacing: 6) {
                        Group {
                            if isPasswordVisible {
                                TextField(localized("Password"), text: $password)
                            } else {
                                SecureField(localized("Password"), text: $password)
                            }
                        }
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12))
                        .onSubmit { onConnect() }

                        Button(action: { isPasswordVisible.toggle() }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .font(.system(size: 11.5))
                                .foregroundStyle(.secondary)
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(.plain)
                        .help(isPasswordVisible ? localized("Hide password") : localized("Show password"))
                    }

                    // Keychain Indicator or Fetching Progress
                    if isFetchingSystemPassword {
                        HStack(spacing: 6) {
                            ProgressView().scaleEffect(0.55)
                            Text(localized("Checking Keychain…"))
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 2)
                    } else if isFromKeychain && !password.isEmpty {
                        HStack(spacing: 5) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(Color.accentColor)
                            Text(localized("Saved in Keychain"))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 2)
                    }

                    if connectionError {
                        HStack {
                            Text(localized("Incorrect password"))
                                .font(.system(size: 10.5))
                                .foregroundStyle(.red)
                            Spacer()
                        }
                        .padding(.horizontal, 2)
                    }

                    // Save Password Checkbox & Action Buttons
                    HStack(alignment: .center, spacing: 8) {
                        Toggle(isOn: $savePassword) {
                            Text(localized("Save password"))
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                        .toggleStyle(.checkbox)
                        .controlSize(.mini)

                        Spacer()

                        Button(localized("Cancel"), action: onCancelPassword)
                            .buttonStyle(.plain)
                            .font(.system(size: 11.5))
                            .foregroundStyle(.secondary)

                        Button(localized("Join"), action: onConnect)
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                            .font(.system(size: 11.5, weight: .semibold))
                            .disabled(password.isEmpty)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 7)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.spring(response: 0.3), value: showingPassword)
    }

    private var signalIcon: some View {
        let bars = network.signalBars
        let name: String
        switch bars {
        case 4: name = "wifi"
        case 3: name = "wifi"
        case 2: name = "wifi.exclamationmark"
        default: name = "wifi.slash"
        }
        return Image(systemName: name)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(bars >= 3 ? (isSelected ? Color.accentColor : .secondary) : .orange)
    }
}

// MARK: - Wrapper that triggers real scan via store
struct WiFiNetworkPickerContainer: View {
    @ObservedObject var statusStore: SystemStatusStore
    let currentSSID: String?

    @State private var networks: [WiFiNetworkInfo] = []
    @State private var isScanning = true

    var body: some View {
        VStack(spacing: 0) {
            if statusStore.status.network.isWiFiPoweredOn == false {
                Text(localized("Wi-Fi disabled"))
                    .font(.system(size: 11.5))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 8)
            } else if isScanning && networks.isEmpty {
                HStack(spacing: 8) {
                    ProgressView().scaleEffect(0.75)
                    Text(localized("Scanning…"))
                        .font(.system(size: 11.5))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .padding(.horizontal, 8)
            } else if networks.isEmpty {
                Text(localized("No networks found"))
                    .font(.system(size: 11.5))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 8)
            } else {
                WiFiNetworkListView(
                    networks: networks,
                    currentSSID: currentSSID,
                    onConnect: { ssid, pwd, shouldSave in
                        let success = await statusStore.connectToWiFi(ssid: ssid, password: pwd)
                        if success && shouldSave, let pwd, !pwd.isEmpty {
                            WiFiKeychainService.shared.savePassword(pwd, for: ssid)
                        }
                        return success
                    }
                )
            }

            Divider()
                .padding(.horizontal, 8)
                .padding(.vertical, 6)

            Button(action: openWiFiSettings) {
                HStack(spacing: 6) {
                    Image(systemName: "wifi")
                        .font(.system(size: 11))
                    Text(localized("Wi-Fi Settings…"))
                        .font(.system(size: 11.5, weight: .medium))
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .padding(.horizontal, 12)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 4)
        }
        .padding(.vertical, 6)
        .background(.primary.opacity(0.035), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        .transition(.opacity.combined(with: .move(edge: .top)))
        .task { await performScan() }
    }

    private func performScan() async {
        isScanning = true
        networks = await statusStore.scanForWiFiNetworks()
        isScanning = false
    }

    private func openWiFiSettings() {
        NSWorkspace.shared.open(
            URL(string: "x-apple.systempreferences:com.apple.preference.network?Wi-Fi")!
        )
    }
}

// MARK: - List subview
private struct WiFiNetworkListView: View {
    let networks: [WiFiNetworkInfo]
    let currentSSID: String?
    let onConnect: (_ ssid: String, _ password: String?, _ savePassword: Bool) async -> Bool

    @State private var passwordTarget: String? = nil
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var savePassword = true
    @State private var isFromKeychain = false
    @State private var isFetchingSystemPassword = false
    @State private var isConnecting = false
    @State private var connectionError = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 2) {
                ForEach(networks) { network in
                    WiFiNetworkRow(
                        network: network,
                        isSelected: network.ssid == currentSSID,
                        isConnecting: isConnecting && passwordTarget == network.ssid,
                        showingPassword: passwordTarget == network.ssid,
                        password: $password,
                        isPasswordVisible: $isPasswordVisible,
                        savePassword: $savePassword,
                        isFromKeychain: isFromKeychain,
                        isFetchingSystemPassword: isFetchingSystemPassword && passwordTarget == network.ssid,
                        connectionError: connectionError && passwordTarget == network.ssid,
                        onTap: { handleTap(network) },
                        onConnect: { handleConnect(network) },
                        onCancelPassword: { cancelPassword() }
                    )
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
        }
        .frame(maxHeight: 185)
        .padding(.horizontal, 4)
        .padding(.top, 2)
    }

    private func handleTap(_ network: WiFiNetworkInfo) {
        connectionError = false
        guard network.ssid != currentSSID else { return }
        if network.isSecured {
            withAnimation(.spring(response: 0.3)) {
                passwordTarget = network.ssid
                password = ""
                isPasswordVisible = false
                savePassword = true
                isFromKeychain = false
                isFetchingSystemPassword = false
            }

            // Step 1: Check ReDuoBar app's private Keychain first (instant)
            if let saved = WiFiKeychainService.shared.getSavedPassword(for: network.ssid) {
                password = saved
                isFromKeychain = true
                return
            }

            // Step 2: Check if macOS System Keychain knows this network
            if WiFiKeychainService.shared.isKnownSystemNetwork(ssid: network.ssid) {
                isFetchingSystemPassword = true
                Task {
                    if let sysPwd = await WiFiKeychainService.shared.fetchSystemPassword(for: network.ssid, timeoutSeconds: 3.5) {
                        await MainActor.run {
                            if passwordTarget == network.ssid {
                                password = sysPwd
                                isFromKeychain = true
                                isFetchingSystemPassword = false
                                // Save into app keychain so next time is instant
                                WiFiKeychainService.shared.savePassword(sysPwd, for: network.ssid)
                            }
                        }
                    } else {
                        await MainActor.run {
                            if passwordTarget == network.ssid {
                                isFetchingSystemPassword = false
                            }
                        }
                    }
                }
            }
        } else {
            Task { await doConnect(ssid: network.ssid, pwd: nil, shouldSave: false) }
        }
    }

    private func handleConnect(_ network: WiFiNetworkInfo) {
        Task {
            await doConnect(
                ssid: network.ssid,
                pwd: password.isEmpty ? nil : password,
                shouldSave: savePassword
            )
        }
    }

    private func doConnect(ssid: String, pwd: String?, shouldSave: Bool) async {
        isConnecting = true
        connectionError = false
        let ok = await onConnect(ssid, pwd, shouldSave)
        isConnecting = false
        if ok {
            withAnimation { passwordTarget = nil }
        } else {
            connectionError = true
        }
    }

    private func cancelPassword() {
        withAnimation(.spring(response: 0.3)) {
            passwordTarget = nil
            password = ""
            isPasswordVisible = false
            savePassword = true
            isFromKeychain = false
            isFetchingSystemPassword = false
            connectionError = false
        }
    }
}
