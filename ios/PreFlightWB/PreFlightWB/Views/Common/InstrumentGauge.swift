import SwiftUI

/// A 270-degree arc gauge styled like an aircraft instrument.
/// The arc fill animates and changes color (green → amber → red) based on thresholds.
/// Center displays a numeric readout with glow effect.
struct InstrumentGauge: View {
    let value: Double
    let range: ClosedRange<Double>
    let cautionThreshold: Double
    let dangerThreshold: Double
    let label: String
    let unit: String
    var decimals: Int = 0

    @State private var animatedFraction: Double = 0

    private var fraction: Double {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        return (value - range.lowerBound) / span
    }

    private var arcColor: Color {
        let f = min(fraction, 1.0)
        if f >= dangerThreshold { return .readoutRed }
        if f >= cautionThreshold { return .readoutAmber }
        return .readoutGreen
    }

    private var formattedValue: String {
        if decimals == 0 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
        }
        return String(format: "%.\(decimals)f", value)
    }

    var body: some View {
        VStack(spacing: Spacing.xs) {
            ZStack {
                // Background arc (270 degree sweep)
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(Color.cockpitBezel, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(135))

                // Value arc
                Circle()
                    .trim(from: 0, to: min(animatedFraction, 1.0) * 0.75)
                    .stroke(arcColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(135))
                    .shadow(color: arcColor.opacity(0.5), radius: 6)

                // Center readout
                VStack(spacing: 0) {
                    Text(formattedValue)
                        .font(InstrumentFont.readoutMedium)
                        .monospacedDigit()
                        .glowingReadout(color: arcColor)
                        .contentTransition(.numericText())

                    Text(unit)
                        .font(InstrumentFont.readoutUnit)
                        .foregroundStyle(Color.cockpitLabel)
                }
            }
            .frame(width: 120, height: 120)

            Text(label)
                .font(InstrumentFont.readoutLabel)
                .foregroundStyle(Color.cockpitLabel)
                .textCase(.uppercase)
                .tracking(1.0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8)) {
                animatedFraction = fraction
            }
        }
        .onChange(of: value) { _, _ in
            withAnimation(.spring(response: 0.4)) {
                animatedFraction = fraction
            }
        }
    }
}
