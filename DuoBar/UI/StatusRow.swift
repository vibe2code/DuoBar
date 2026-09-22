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
        Group {
            if let action, trailing == nil {
                Button(action: action) { rowContent }
                    .buttonStyle(.plain)
            } else {
                rowContent
            }
        }
    }

    private var rowContent: some View {
        HStack(spacing: 11) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 12.5, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                Text(detail)
                    .font(.system(size: 10.5))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            Spacer(minLength: 8)

            if let trailing {
                trailing
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
        .background(.primary.opacity(action != nil && isExpanded ? 0.07 : 0.045),
                    in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
        .animation(.easeInOut(duration: 0.15), value: isExpanded)
    }
}
