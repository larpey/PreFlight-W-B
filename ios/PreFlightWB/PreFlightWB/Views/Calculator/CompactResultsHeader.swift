import SwiftUI

/// Cockpit-style instrument header that displays weight, CG, and status at a glance.
/// Retains the `CompactResultsHeader` name so the parent CalculatorView needs no changes.
struct CompactResultsHeader: View {
    let result: CalculationResult
    let aircraft: Aircraft

    // MARK: - Computed Properties

    private var isWithinLimits: Bool {
        result.isWithinWeightLimit && result.isWithinCGEnvelope
    }

    private var statusLevel: StatusLevel {
        if !result.isWithinWeightLimit || !result.isWithinCGEnvelope {
            return .danger
        }
        if weightFraction > 0.95 {
            return .caution
        }
        return .safe
    }

    private var statusText: String {
        if !result.isWithinWeightLimit {
            return "OVER WEIGHT"
        }
        if !result.isWithinCGEnvelope {
            return "CG OUT OF RANGE"
        }
        if weightFraction > 0.95 {
            return "Near Limits"
        }
        return "Within Limits"
    }

    private var weightFraction: Double {
        min(result.totalWeight / aircraft.maxGrossWeight.value, 1.5)
    }

    // MARK: - Color Logic

    private var weightColor: Color {
        if !result.isWithinWeightLimit {
            return .readoutRed
        }
        if weightFraction > 0.95 {
            return .readoutAmber
        }
        return .readoutGreen
    }

    private var cgColor: Color {
        result.isWithinCGEnvelope ? .readoutGreen : .readoutRed
    }

    private var barColor: Color {
        if weightFraction > 1.0 {
            return .readoutRed
        }
        if weightFraction > 0.95 {
            return .readoutAmber
        }
        return .readoutGreen
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // 1 ── Status banner row
            statusBannerRow

            // 2 ── Primary readout row
            primaryReadoutRow

            // 3 ── Weight utilization bar
            weightUtilizationBar
        }
        .padding(Spacing.md)
        .background(Color.cockpitSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(statusLevel.color.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Subviews

    private var statusBannerRow: some View {
        HStack {
            AnimatedStatusBadge(status: statusLevel, text: statusText)

            Spacer()

            Text("Max \(formatted(aircraft.maxGrossWeight.value))")
                .font(.caption)
                .foregroundStyle(Color.cockpitLabel)
        }
    }

    private var primaryReadoutRow: some View {
        HStack(alignment: .firstTextBaseline) {
            // Weight readout
            VStack(alignment: .leading, spacing: 2) {
                Text("WEIGHT")
                    .font(InstrumentFont.readoutLabel)
                    .foregroundStyle(Color.cockpitLabel)
                    .tracking(1.0)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(formatted(result.totalWeight))
                        .font(InstrumentFont.readoutLarge)
                        .monospacedDigit()
                        .glowingReadout(color: weightColor)
                        .contentTransition(.numericText())

                    Text("lbs")
                        .font(InstrumentFont.readoutUnit)
                        .foregroundStyle(Color.cockpitLabel)
                }
            }

            Spacer()

            // CG readout
            VStack(alignment: .trailing, spacing: 2) {
                Text("CG")
                    .font(InstrumentFont.readoutLabel)
                    .foregroundStyle(Color.cockpitLabel)
                    .tracking(1.0)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", result.cg))
                        .font(InstrumentFont.readoutLarge)
                        .monospacedDigit()
                        .glowingReadout(color: cgColor)
                        .contentTransition(.numericText())

                    Text("in")
                        .font(InstrumentFont.readoutUnit)
                        .foregroundStyle(Color.cockpitLabel)
                }
            }
        }
    }

    private var weightUtilizationBar: some View {
        VStack(spacing: Spacing.xxs) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.cockpitBezel)
                        .frame(height: 8)

                    // Fill bar
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(
                            width: max(0, min(geo.size.width, geo.size.width * weightFraction)),
                            height: 8
                        )
                        .shadow(color: barColor.opacity(0.5), radius: 4)

                    // Red marker line at 100%
                    if weightFraction < 1.3 {
                        Rectangle()
                            .fill(Color.readoutRed.opacity(0.6))
                            .frame(width: 2, height: 14)
                            .position(x: geo.size.width, y: 4)
                    }
                }
            }
            .frame(height: 8)

            // Margin labels
            HStack {
                Text("Remaining: \(formatted(result.weightMargin)) lbs")
                    .font(.caption2)
                    .foregroundStyle(result.weightMargin >= 0 ? Color.readoutGreen : Color.readoutRed)

                Spacer()

                Text("CG: \(String(format: "%.1f", result.cgForwardMargin))\" fwd / \(String(format: "%.1f", result.cgAftMargin))\" aft")
                    .font(.caption2)
                    .foregroundStyle(Color.cockpitLabel)
            }
        }
    }

    // MARK: - Helpers

    private func formatted(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
}
