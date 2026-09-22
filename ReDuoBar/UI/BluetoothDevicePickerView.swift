import AppKit
import SwiftUI

struct BluetoothDevicePickerView: View {
    @ObservedObject var statusStore: SystemStatusStore

    @State private var connectingAddress: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            if !statusStore.status.bluetooth.isPoweredOn {
                Text(localized("Bluetooth disabled"))
                    .font(.system(size: 11.5))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 8)
            } else if statusStore.status.bluetooth.devices.isEmpty {
                Text(localized("No devices found"))
                    .font(.system(size: 11.5))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 8)
            } else {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 2) {
                        ForEach(statusStore.status.bluetooth.devices) { device in
                            BluetoothDeviceRow(
                                device: device,
                                isConnecting: connectingAddress == device.address,
                                onToggleConnect: {
                                    handleToggleConnect(device)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                }
                .frame(maxHeight: 185)
            }

            Divider()
                .padding(.horizontal, 8)
                .padding(.vertical, 6)

            Button(action: openBluetoothSettings) {
                HStack(spacing: 6) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 11))
                    Text(localized("Bluetooth Settings…"))
                        .font(.system(size: 11.5, weight: .medium))
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.bottom, 4)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
        .background(.primary.opacity(0.035), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        .transition(.opacity.combined(with: .move(edge: .top)))
        .onAppear {
            statusStore.refreshBluetooth()
        }
    }

    private func handleToggleConnect(_ device: BluetoothDeviceInfo) {
        guard connectingAddress == nil else { return }
        connectingAddress = device.address
        Task {
            if device.isConnected {
                _ = await statusStore.disconnectBluetoothDevice(address: device.address)
            } else {
                _ = await statusStore.connectBluetoothDevice(address: device.address)
            }
            try? await Task.sleep(nanoseconds: 600_000_000)
            connectingAddress = nil
            statusStore.refreshBluetooth()
        }
    }

    private func openBluetoothSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.BluetoothSettings") {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - BluetoothDeviceRow

private struct BluetoothDeviceRow: View {
    let device: BluetoothDeviceInfo
    let isConnecting: Bool
    let onToggleConnect: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onToggleConnect) {
            HStack(spacing: 10) {
                Image(systemName: device.iconName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(device.isConnected ? Color.accentColor : Color.secondary)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 1) {
                    Text(device.name)
                        .font(.system(size: 12, weight: device.isConnected ? .semibold : .regular))
                        .foregroundStyle(device.isConnected ? .primary : .secondary)
                        .lineLimit(1)
                    Text(device.isConnected ? localized("Connected") : localized("Not connected"))
                        .font(.system(size: 10))
                        .foregroundStyle(device.isConnected ? Color.accentColor : Color.secondary.opacity(0.8))
                }

                Spacer(minLength: 4)

                if isConnecting {
                    ProgressView()
                        .scaleEffect(0.6)
                        .frame(width: 16, height: 16)
                } else if device.isConnected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                device.isConnected
                    ? Color.accentColor.opacity(isHovered ? 0.15 : 0.08)
                    : (isHovered ? Color.primary.opacity(0.05) : Color.clear),
                in: RoundedRectangle(cornerRadius: 8, style: .continuous)
            )
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
