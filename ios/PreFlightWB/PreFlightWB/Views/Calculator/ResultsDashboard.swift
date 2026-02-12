import SwiftUI

/// Summary card displayed at the top of the calculator screen.
/// Shows total weight, CG, weight margin, and overall status with animated transitions.
struct ResultsDashboard: View {
    let result: CalculationResult
    let aircraft: Aircraft

    /// Tracks the previous within-limits state for haptic feedback on transitions.
    @State private var wasWithinLimits: Bool?

    private var isWithinLimits: Bool {
        result.isWithinWeightLimit && result.isWithinCGEnvelope
    }

    private var weightFraction: Double {
        min(result.totalWeight / aircraft.maxGrossWeight.value, 1.5)
    }

    private var statusLevel: StatusLevel {
        if !result.isWithinWeightLimit || !result.isWithinCGEnvelope {
            return .danger
        } else if weightFraction > 0.95 {
            return .caution
        } else {
            return .safe
        }
    }

    private var statusText: String {
        if !result.isWithinWeightLimit {
            return "OVER WEIGHT"
        } else if !result.isWithinCGEnvelope {
            return "CG OUT OF RANGE"
        } else if weightFraction > 0.95 {
            return "Near Limits"
        } else {
            return "Within Limits"
        }
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Status badge
            HStack {
                AnimatedStatusBadge(status: statusLevel, text: statusText)
                Spacer()
            }

            // Weight and CG row
            HStack(spacing: Spacing.md) {
                // Total weight
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("Total Weight")
                        .font(.caption)
                        .foregroundStyle(Color.pfTextSecondary)
                    Text("\(formatted(result.totalWeight, decimals: 0)) lbs")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(result.isWithinWeightLimit ? .primary : Color.statusDanger)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }

                Spacer()

                // CG
                VStack(alignment: .trailing, spacing: Spacing.xxs) {
                    Text("CG Position")
                        .font(.caption)
                        .foregroundStyle(Color.pfTextSecondary)
                    Text("\(formatted(result.cg, decimals: 2))\"")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(result.isWithinCGEnvelope ? .primary : Color.statusDanger)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
            }

            // Weight progress bar
            VStack(spacing: Spacing.xxs) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.pfSeparator.opacity(0.3))
                            .frame(height: 12)

                        // Fill bar
                        RoundedRectangle(cornerRadius: 6)
                            .fill(weightBarColor)
                            .frame(
                                width: max(0, min(geometry.size.width, geometry.size.width * weightFraction)),
                                height: 12
                            )
                            .animation(.spring(response: 0.4), value: weightFraction)
                    }
                }
                .frame(height: 12)

                HStack {
                    Text("0 lbs")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Text("Max \(formatted(aircraft.maxGrossWeight.value, decimals: 0)) lbs")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            }

            // Margins row — each in its own mini glass card
            HStack(spacing: Spacing.xs) {
                marginCard(
                    icon: "scalemass",
                    label: "Weight",
                    value: "\(formatted(result.weightMargin, decimals: 0)) lbs",
                    isPositive: result.weightMargin >= 0
                )

                marginCard(
                    icon: "arrow.left",
                    label: "Fwd CG",
                    value: "\(formatted(result.cgForwardMargin, decimals: 1))\"",
                    isPositive: result.cgForwardMargin >= 0
                )

                marginCard(
                    icon: "arrow.right",
                    label: "Aft CG",
                    value: "\(formatted(result.cgAftMargin, decimals: 1))\"",
                    isPositive: result.cgAftMargin >= 0
                )
            }
        }
        .padding(Spacing.md)
        .background(Color.pfCard)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .onChange(of: isWithinLimits) { oldValue, newValue in
            guard let wasIn = wasWithinLimits else {
                wasWithinLimits = newValue
                return
            }
            if !wasIn && newValue {
                // Transitioned INTO limits
                Haptic.success()
            } else if wasIn && !newValue {
                // Transitioned OUT of limits
                Haptic.error()
            }
            wasWithinLimits = newValue
        }
        .onAppear {
            wasWithinLimits = isWithinLimits
        }
    }

    // MARK: - Helpers

    private var weightBarColor: Color {
        if weightFraction > 1.0 {
            return .statusDanger
        } else if weightFraction > 0.95 {
            return .statusCaution
        } else {
            return .statusSafe
        }
    }

    private func marginCard(icon: String, label: String, value: String, isPositive: Bool) -> some View {
        VStack(spacing: Spacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(isPositive ? Color.pfTextSecondary : Color.statusDanger)

            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(Color.pfTextSecondary)

            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(isPositive ? .primary : Color.statusDanger)
                .monospacedDigit()
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xs)
        .padding(.horizontal, Spacing.xxs)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
    }

    private func formatted(_ value: Double, decimals: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(decimals)f", value)
    }
}

#Preview {
    ResultsDashboard(
        result: CalculationResult(
            totalWeight: 2100,
            totalMoment: 189000,
            cg: 40.5,
            isWithinWeightLimit: true,
            isWithinCGEnvelope: true,
            isWithinAllStationLimits: true,
            weightMargin: 200,
            cgForwardMargin: 5.0,
            cgAftMargin: 6.5,
            stationDetails: [],
            fuelDetails: [],
            warnings: []
        ),
        aircraft: .cessna172m
    )
    .padding()
    .background(Color.pfBackground)
}
