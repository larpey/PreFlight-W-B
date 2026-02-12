import SwiftUI

/// An animated status badge with a pulsing dot and status text.
enum StatusLevel {
    case safe
    case caution
    case danger

    var color: Color {
        switch self {
        case .safe: .statusSafe
        case .caution: .statusCaution
        case .danger: .statusDanger
        }
    }

    var icon: String {
        switch self {
        case .safe: "checkmark.circle.fill"
        case .caution: "exclamationmark.triangle.fill"
        case .danger: "xmark.octagon.fill"
        }
    }
}

struct AnimatedStatusBadge: View {
    let status: StatusLevel
    let text: String

    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: status.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(status.color)
                .scaleEffect(isPulsing && status != .safe ? 1.15 : 1.0)
                .animation(
                    status != .safe
                        ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true)
                        : .default,
                    value: isPulsing
                )

            Text(text)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(status.color)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(status.color.opacity(0.12))
        .clipShape(Capsule())
        .onAppear {
            isPulsing = true
        }
    }
}
