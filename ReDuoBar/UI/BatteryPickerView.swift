import AppKit
import SwiftUI

struct BatteryPickerView: View {
    @ObservedObject var statusStore: SystemStatusStore

    var body: some View {
        VStack(spacing: 0) {
            // Low Power Mode Toggle Row
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.badge.clock.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(statusStore.status.battery.isLowPowerModeEnabled ? Color.yellow : Color.secondary)
                    Text(localized("Low Power Mode"))
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { statusStore.status.battery.isLowPowerModeEnabled },
                    set: { statusStore.setLowPowerMode($0) }
                ))
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.mini)
            }
            .padding(.horizontal, 12)
            .padding(.top, 6)
            .padding(.bottom, 6)

            Divider()
                .padding(.horizontal, 8)
                .padding(.bottom, 6)

            // Battery Info details
            VStack(spacing: 5) {
                HStack {
                    Text(localized("Power Source"))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(powerSourceText)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.primary)
                }

                if let timeText = formattedTimeRemaining {
                    HStack {
                        Text(statusStore.status.battery.isCharging ? localized("Until Full") : localized("Remaining"))
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(timeText)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)

            Divider()
                .padding(.horizontal, 8)
                .padding(.vertical, 6)

            Button(action: openBatterySettings) {
                HStack(spacing: 6) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 11))
                    Text(localized("Battery Settings…"))
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
        .padding(.vertical, 4)
        .background(.primary.opacity(0.035), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var powerSourceText: String {
        let battery = statusStore.status.battery
        if battery.isPluggedIn {
            return localized("Power Adapter")
        }
        return localized("Battery Power")
    }

    private var formattedTimeRemaining: String? {
        guard let minutes = statusStore.status.battery.timeRemaining, minutes > 0 else { return nil }
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return localized("%dh %dm", hours, mins)
        } else {
            return localized("%dm", mins)
        }
    }

    private func openBatterySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.battery") {
            NSWorkspace.shared.open(url)
        }
    }
}
