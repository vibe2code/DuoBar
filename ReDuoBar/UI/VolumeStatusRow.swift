import SwiftUI

struct VolumeStatusRow: View {
    let volume: OutputVolumeStatus
    let hasOutputDevice: Bool
    let playbackDeviceIdentifier: String?
    let onSetVolume: (Double) -> Bool
    let onSetMuted: (Bool) -> Bool

    @State private var feedbackInteraction = VolumeFeedbackInteraction()
    @State private var lastNonZeroLevel: Double = 0.5

    var body: some View {
        HStack(spacing: 11) {
            muteControl

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(localized("Volume"))
                        .font(.system(size: 12.5, weight: .semibold))
                    Spacer()
                    Button(action: handleUserMuteChange) {
                        HStack(spacing: 4) {
                            Image(systemName: volume.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .font(.system(size: 9, weight: .semibold))
                            Text(stateText)
                                .font(.system(size: 10.5, weight: .medium, design: .rounded))
                                .monospacedDigit()
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            volume.isMuted
                                ? Color.red.opacity(0.18)
                                : Color.primary.opacity(0.06),
                            in: Capsule()
                        )
                        .foregroundStyle(volume.isMuted ? Color.red : Color.secondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(!volume.isSettable && !volume.isMuteSettable)
                    .help(volume.isMuted ? localized("Unmute") : localized("Mute"))
                }

                if volume.isSettable, let level = volume.level {
                    Slider(
                        value: Binding(
                            get: { level },
                            set: handleUserVolumeChange
                        ),
                        in: 0...1,
                        onEditingChanged: handleSliderEditingChanged
                    )
                    .controlSize(.mini)
                    .accessibilityLabel(localized("Output volume"))
                    .accessibilityValue(stateText)
                } else {
                    Text(hasOutputDevice ? localized("Controlled by device") : localized("Volume unavailable"))
                        .font(.system(size: 10.5))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 54)
        .background(.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        .onAppear {
            if let lvl = volume.level, lvl > 0 {
                lastNonZeroLevel = lvl
            }
        }
        .onChange(of: volume.level) { newLevel in
            if let newLevel, newLevel > 0 {
                lastNonZeroLevel = newLevel
            }
        }
    }

    @ViewBuilder
    private var muteControl: some View {
        Button {
            handleUserMuteChange()
        } label: {
            Image(systemName: volumeSymbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(volume.isMuted ? Color.red : Color.primary)
                .frame(width: 28, height: 28)
                .background(
                    volume.isMuted ? Color.red.opacity(0.16) : Color.primary.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!volume.isSettable && !volume.isMuteSettable)
        .help(volume.isMuted ? localized("Unmute") : localized("Mute"))
        .accessibilityLabel(volume.isMuted ? localized("Unmute output") : localized("Mute output"))
    }

    private var volumeSymbol: String {
        guard let percentage = volume.percentage else { return "speaker" }
        if volume.isMuted || percentage == 0 { return "speaker.slash.fill" }
        switch percentage {
        case 1...33: return "speaker.wave.1"
        case 34...66: return "speaker.wave.2"
        default: return "speaker.wave.3"
        }
    }

    private var stateText: String {
        if volume.isMuted { return localized("Muted") }
        return volume.percentage.map { localized("%d%%", $0) } ?? "—"
    }

    private func handleUserVolumeChange(_ level: Double) {
        beginSliderInteractionIfNeeded()
        guard feedbackInteraction.allowsVolumeUpdates else {
            feedbackInteraction.recordVolumeUpdate(
                previousStatus: volume,
                requestedLevel: level,
                writeSucceeded: false
            )
            return
        }

        if level > 0 {
            lastNonZeroLevel = level
        }

        let writeSucceeded = onSetVolume(level)
        feedbackInteraction.recordVolumeUpdate(
            previousStatus: volume,
            requestedLevel: level,
            writeSucceeded: writeSucceeded
        )
    }

    private func handleSliderEditingChanged(_ isEditing: Bool) {
        if isEditing {
            beginSliderInteractionIfNeeded()
            return
        }
        guard feedbackInteraction.endEditing() else { return }
        VolumeFeedbackSound.play(on: playbackDeviceIdentifier)
    }

    private func beginSliderInteractionIfNeeded() {
        feedbackInteraction.beginEditing(previousStatus: volume) {
            onSetMuted(false)
        }
    }

    private func handleUserMuteChange() {
        if volume.isMuted {
            // Unmute
            let success = onSetMuted(false)
            if !success || (volume.level ?? 0) == 0 {
                _ = onSetVolume(lastNonZeroLevel > 0 ? lastNonZeroLevel : 0.5)
            }
            VolumeFeedbackSound.play(on: playbackDeviceIdentifier)
        } else {
            // Mute
            if let lvl = volume.level, lvl > 0 {
                lastNonZeroLevel = lvl
            }
            let success = onSetMuted(true)
            if !success {
                _ = onSetVolume(0.0)
            }
        }
    }
}
