import SwiftUI

struct AudioOutputPickerView: View {
    let devices: [AudioDeviceStatus]
    let currentUID: String?
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 2) {
                ForEach(devices) { device in
                    AudioOutputDeviceRow(
                        device: device,
                        isSelected: device.uid == currentUID,
                        onSelect: { onSelect(device.uid) }
                    )
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
        }
        .frame(maxHeight: 185)
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .background(.primary.opacity(0.035), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

private struct AudioOutputDeviceRow: View {
    let device: AudioDeviceStatus
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 10) {
                Image(systemName: deviceSymbol)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                    .frame(width: 20)

                Text(device.name)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .lineLimit(1)

                Spacer(minLength: 4)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var deviceSymbol: String {
        if device.transport.isBluetooth {
            return device.temporaryGlyph == .airPods ? "airpodspro" : "headphones"
        }
        switch device.transport {
        case .airPlay: return "airplayvideo"
        case .usb: return "cable.connector"
        case .hdmi, .displayPort: return "display"
        case .virtual: return "waveform.circle"
        case .builtIn: return "hifispeaker"
        default: return "speaker.wave.2"
        }
    }
}
