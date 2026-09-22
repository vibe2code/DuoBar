import Foundation
import IOBluetooth

// Private IOBluetooth preference API — not available in App Store, fine for standalone tools.
@_silgen_name("IOBluetoothPreferenceSetControllerPowerState")
private func IOBluetoothPreferenceSetControllerPowerState(_ state: Int32)

@MainActor
final class BluetoothService: NSObject {
    var onStatusChange: ((BluetoothStatus) -> Void)?

    private var observers: [NSObjectProtocol] = []
    private var connectNotification: IOBluetoothUserNotification?
    private var periodicTimer: Timer?
    private var lastStatus: BluetoothStatus?

    func start() {
        guard observers.isEmpty else { return }

        let center = NotificationCenter.default
        let names = [
            Notification.Name.IOBluetoothHostControllerPoweredOn,
            Notification.Name.IOBluetoothHostControllerPoweredOff
        ]

        observers = names.map { name in
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in
                    self?.refresh()
                }
            }
        }

        connectNotification = IOBluetoothDevice.register(
            forConnectNotifications: self,
            selector: #selector(bluetoothDeviceDidConnect(_:device:))
        )

        periodicTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }

        refresh()
    }

    @objc private func bluetoothDeviceDidConnect(_ notification: IOBluetoothUserNotification, device: IOBluetoothDevice) {
        Task { @MainActor in
            self.refresh()
        }
    }

    func refresh() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let status: BluetoothStatus
            if let controller = IOBluetoothHostController.default() {
                let isPoweredOn = controller.powerState == kBluetoothHCIPowerStateON
                var devices: [BluetoothDeviceInfo] = []

                if isPoweredOn, let rawDevices = IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] {
                    devices = rawDevices.compactMap { d in
                        guard let address = d.addressString, !address.isEmpty else { return nil }
                        let name = d.nameOrAddress ?? d.name ?? address
                        return BluetoothDeviceInfo(
                            name: name,
                            address: address,
                            isConnected: d.isConnected(),
                            isPaired: d.isPaired(),
                            majorClass: UInt32(d.deviceClassMajor),
                            minorClass: UInt32(d.deviceClassMinor)
                        )
                    }
                    // Sort: connected devices first, then alphabetically
                    devices.sort { a, b in
                        if a.isConnected != b.isConnected {
                            return a.isConnected && !b.isConnected
                        }
                        return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
                    }
                }

                status = BluetoothStatus(
                    isAvailable: true,
                    isPoweredOn: isPoweredOn,
                    devices: devices
                )
            } else {
                status = .unavailable
            }

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                guard status != self.lastStatus else { return }
                self.lastStatus = status
                self.onStatusChange?(status)
            }
        }
    }

    /// Connect to a paired device by its MAC address.
    func connect(address: String) async -> Bool {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let device = IOBluetoothDevice(addressString: address) else {
                    continuation.resume(returning: false)
                    return
                }

                let ret = device.openConnection()
                let success = (ret == kIOReturnSuccess) || device.isConnected()

                // Refresh after connection attempt
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self?.refresh()
                }

                continuation.resume(returning: success)
            }
        }
    }

    /// Disconnect from a device by its MAC address.
    func disconnect(address: String) async -> Bool {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let device = IOBluetoothDevice(addressString: address) else {
                    continuation.resume(returning: false)
                    return
                }

                let ret = device.closeConnection()
                let success = (ret == kIOReturnSuccess) || !device.isConnected()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self?.refresh()
                }

                continuation.resume(returning: success)
            }
        }
    }

    /// Toggle Bluetooth power state using the private IOBluetooth preference API.
    func setBluetoothPower(_ enabled: Bool) {
        IOBluetoothPreferenceSetControllerPowerState(enabled ? 1 : 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.refresh()
        }
    }

    deinit {
        observers.forEach(NotificationCenter.default.removeObserver)
        connectNotification?.unregister()
        periodicTimer?.invalidate()
    }
}
