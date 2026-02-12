import SwiftUI

/// Displays a list of calculation warnings as color-coded alert cards
/// with animated entry transitions and haptic feedback.
struct SafetyAlerts: View {
    let warnings: [CalculationWarning]

    var body: some View {
        VStack(spacing: Spacing.xs) {
            ForEach(Array(warnings.enumerated()), id: \.offset) { _, warning in
                WarningCard(warning: warning)
                    .transition(.asymmetric(
                        insertion: .push(from: .top),
                        removal: .opacity
                    ))
            }
        }
        .animation(.spring(response: 0.3), value: warnings.count)
        .onAppear {
            if warnings.contains(where: { $0.level == .danger }) {
                Haptic.error()
            } else if !warnings.isEmpty {
                Haptic.warning()
            }
        }
    }
}

/// A single warning card with material background overlaid with status color.
private struct WarningCard: View {
    let warning: CalculationWarning

    private var statusColor: Color {
        switch warning.level {
        case .danger:
            return .statusDanger
        case .warning:
            return .statusCaution
        case .caution:
            return .statusCaution
        }
    }

    private var iconName: String {
        switch warning.level {
        case .danger:
            return "exclamationmark.octagon.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .caution:
            return "exclamationmark.circle.fill"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: iconName)
                .font(.body)
                .foregroundStyle(statusColor)
                .frame(width: 24, alignment: .center)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(warning.message)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                if let detail = warning.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let remediation = warning.remediation {
                    Text(remediation)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.statusInfo)
                }

                if let ref = warning.regulatoryRef {
                    Text(ref)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(statusColor)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(Spacing.sm)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(statusColor.opacity(0.1))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .strokeBorder(statusColor.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    SafetyAlerts(warnings: [
        CalculationWarning(
            level: .danger,
            code: .overMaxGross,
            message: "Aircraft exceeds maximum takeoff weight",
            detail: "2,450 lbs exceeds limit of 2,300 lbs by 150 lbs",
            regulatoryRef: "FAR 91.103"
        ),
        CalculationWarning(
            level: .warning,
            code: .overMaxLanding,
            message: "Current weight exceeds max landing weight",
            detail: "Plan fuel burn before landing",
            regulatoryRef: nil
        ),
        CalculationWarning(
            level: .caution,
            code: .nearMaxGross,
            message: "Approaching maximum takeoff weight",
            detail: "50 lbs remaining (2.2% margin)",
            regulatoryRef: nil
        )
    ])
    .padding()
    .background(Color.pfBackground)
}
