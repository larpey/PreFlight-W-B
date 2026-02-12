import SwiftUI

/// A compact, always-visible results summary that stays at the top of the
/// calculator regardless of which tab is selected.
struct CompactResultsHeader: View {
    let result: CalculationResult
    let aircraft: Aircraft

    private var isWithinLimits: Bool {
        result.isWithinWeightLimit && result.isWithinCGEnvelope
    }

    private var statusLevel: StatusLevel {
        if !result.isWithinWeightLimit || !result.isWithinCGEnvelope {
            return .danger
        }
        let weightPct = result.totalWeight / aircraft.maxGrossWeight.value
        if weightPct > 0.95 {
            return .caution
        }
        return .safe
    }

    private var weightFraction: Double {
        min(result.totalWeight / aircraft.maxGrossWeight.value, 1.5)
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Status dot
            Circle()
                .fill(statusLevel.color)
                .frame(width: 10, height: 10)

            // Weight
            VStack(alignment: .leading, spacing: 0) {
                Text("Weight")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Text("\(formatted(result.totalWeight)) lbs")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(result.isWithinWeightLimit ? Color.pfText : Color.statusDanger)
            }

            // Mini weight bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.pfSeparator.opacity(0.3))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(statusLevel.color)
                        .frame(width: max(0, min(geo.size.width, geo.size.width * weightFraction)))
                }
            }
            .frame(width: 60, height: 4)

            Spacer()

            // CG
            VStack(alignment: .trailing, spacing: 0) {
                Text("CG")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Text("\(String(format: "%.1f", result.cg))\"")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(result.isWithinCGEnvelope ? Color.pfText : Color.statusDanger)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
    }

    private func formatted(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
}
