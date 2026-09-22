import Foundation
import IOBluetooth

// Private IOBluetooth preference API — not available in App Store, fine for standalone tools.
@_silgen_name("IOBluetoothPreferenceSetControllerPowerState")
private func IOBluetoothPreferenceSetControllerPowerState(_ state: Int32)

@MainActor
final class BluetoothService {
    var onStatusChange: ((BluetoothStatus) -> Void)?

    private var observers: [NSObjectProtocol] = []

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

        refresh()
    }

    func refresh() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let status: BluetoothStatus
            if let controller = IOBluetoothHostController.default() {
                status = BluetoothStatus(
                    isAvailable: true,
                    isPoweredOn: controller.powerState == kBluetoothHCIPowerStateON
                )
            } else {
                status = .unavailable
            }

            DispatchQueue.main.async { [weak self] in
                self?.onStatusChange?(status)
            }
        }
    }

    /// Toggle Bluetooth power state using the private IOBluetooth preference API.
    /// This is the same mechanism used by `blueutil` and similar macOS utilities.
    func setBluetoothPower(_ enabled: Bool) {
        IOBluetoothPreferenceSetControllerPowerState(enabled ? 1 : 0)
        // Slight delay then refresh — the power state change is async in bluetoothd
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.refresh()
        }
    }

    deinit {
        observers.forEach(NotificationCenter.default.removeObserver)
    }
}

