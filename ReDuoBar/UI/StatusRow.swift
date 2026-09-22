import SwiftUI

struct StatusRow: View {
    let symbol: String
    let title: String
    let detail: String
    let stateText: String
    let tint: Color
    var isExpanded: Bool = false
    var action: (() -> Void)? = nil
    var trailing: AnyView? = nil

    init(
        symbol: String,
        title: String,
        detail: String,
        stateText: String,
        tint: Color,
        isExpanded: Bool = false,
        action: (() -> Void)? = nil,
        trailing: AnyView? = nil
    ) {
        self.symbol = symbol
        self.title = title
        self.detail = detail
        self.stateText = stateText
        self.tint = tint
        self.isExpanded = isExpanded
        self.action = action
        self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: 8) {
            // Main clickable part:
            Group {
                if let action {
                    Button(action: action) {
                        mainContent
                    }
                    .buttonStyle(.plain)
                } else {
                    mainContent
                }
            }

            Spacer(minLength: 4)

            // Right side:
            if let trailing {
                HStack(spacing: 6) {
                    if action != nil {
                        Button(action: { action?() }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(.tertiary)
                                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                                .animation(.spring(response: 0.3), value: isExpanded)
                                .frame(width: 14, height: 28)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    trailing
                }
            } else if action != nil {
                HStack(spacing: 4) {
                    Text(stateText)
                        .font(.system(size: 10.5, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.spring(response: 0.3), value: isExpanded)
                }
            } else {
                Text(stateText)
                    .font(.system(size: 10.5, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 48)
        .background(
            .primary.opacity(action != nil && isExpanded ? 0.07 : 0.045),
            in: RoundedRectangle(cornerRadius: 11, style: .continuous)
        )
        .contentShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
        .animation(.easeInOut(duration: 0.15), value: isExpanded)
    }

    private var mainContent: some View {
        HStack(spacing: 11) {
            iconView

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 12.5, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                if !detail.isEmpty {
                    Text(detail)
                        .font(.system(size: 10.5))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .minimumScaleFactor(0.72)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
        }
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var iconView: some View {
        if symbol.hasPrefix("NS") || symbol.contains("Template"), let img = NSImage(named: NSImage.Name(symbol)) {
            Image(nsImage: img)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 14, height: 16)
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}
