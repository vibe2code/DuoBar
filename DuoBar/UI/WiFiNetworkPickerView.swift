import SwiftUI

struct WiFiNetworkPickerView: View {
    let currentSSID: String?
    let onConnect: (_ ssid: String, _ password: String?) async -> Bool
    let onOpenSettings: () -> Void

    @State private var networks: [WiFiNetworkInfo] = []
    @State private var isScanning = false
    @State private var passwordTarget: WiFiNetworkInfo? = nil
    @State private var password = ""
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
            }
        } else {
            Task { await connectDirect(to: network, password: nil) }
        }
    }

    private func handleConnect(_ network: WiFiNetworkInfo) {
        let pwd = password.isEmpty ? nil : password
        Task { await connectDirect(to: network, password: pwd) }
    }

    private func connectDirect(to network: WiFiNetworkInfo, password: String?) async {
        isConnecting = true
        connectionError = false
        let success = await onConnect(network.ssid, password)
        isConnecting = false
        if success {
            withAnimation { passwordTarget = nil }
        } else {
            connectionError = true
        }
    }

    private func cancelPassword() {
        withAnimation(.spring(response: 0.3)) {
            passwordTarget = nil
            password = ""
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
                VStack(spacing: 6) {
                    SecureField(localized("Password"), text: $password)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12))
                        .onSubmit { onConnect() }

                    if connectionError {
                        Text(localized("Incorrect password"))
                            .font(.system(size: 10.5))
                            .foregroundStyle(.red)
                    }

                    HStack(spacing: 8) {
                        Button(localized("Cancel"), action: onCancelPassword)
                            .buttonStyle(.plain)
                            .font(.system(size: 11.5))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button(localized("Join"), action: onConnect)
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                            .font(.system(size: 11.5, weight: .semibold))
                            .disabled(password.isEmpty)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 6)
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
            if isScanning && networks.isEmpty {
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
                    onConnect: { ssid, pwd in
                        await statusStore.connectToWiFi(ssid: ssid, password: pwd)
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
    let onConnect: (String, String?) async -> Bool

    @State private var passwordTarget: String? = nil
    @State private var password = ""
    @State private var isConnecting = false
    @State private var connectionError = false

    var body: some View {
        VStack(spacing: 2) {
            ForEach(networks) { network in
                WiFiNetworkRow(
                    network: network,
                    isSelected: network.ssid == currentSSID,
                    isConnecting: isConnecting && passwordTarget == network.ssid,
                    showingPassword: passwordTarget == network.ssid,
                    password: $password,
                    connectionError: connectionError && passwordTarget == network.ssid,
                    onTap: { handleTap(network) },
                    onConnect: { handleConnect(network) },
                    onCancelPassword: { cancelPassword() }
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 4)
    }

    private func handleTap(_ network: WiFiNetworkInfo) {
        connectionError = false
        guard network.ssid != currentSSID else { return }
        if network.isSecured {
            withAnimation(.spring(response: 0.3)) {
                passwordTarget = network.ssid
                password = ""
            }
        } else {
            Task { await doConnect(ssid: network.ssid, pwd: nil) }
        }
    }

    private func handleConnect(_ network: WiFiNetworkInfo) {
        Task { await doConnect(ssid: network.ssid, pwd: password.isEmpty ? nil : password) }
    }

    private func doConnect(ssid: String, pwd: String?) async {
        isConnecting = true
        connectionError = false
        let ok = await onConnect(ssid, pwd)
        isConnecting = false
        if ok { withAnimation { passwordTarget = nil } }
        else { connectionError = true }
    }

    private func cancelPassword() {
        withAnimation(.spring(response: 0.3)) {
            passwordTarget = nil
            password = ""
            connectionError = false
        }
    }
}
