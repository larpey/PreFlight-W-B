import SwiftUI

struct AircraftCard: View {
    let aircraft: Aircraft

    /// Shared formatter for comma-separated weight values.
    private static let weightFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f
    }()

    // MARK: - Computed Properties

    private var aircraftIcon: String {
        aircraft.category == .singleEngine ? "airplane" : "airplane.departure"
    }

    private var categoryColor: Color {
        aircraft.category == .singleEngine ? .readoutBlue : .readoutAmber
    }

    private var categoryGradient: LinearGradient {
        LinearGradient(
            colors: [categoryColor, categoryColor.opacity(0.3)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top accent bar: 4pt colored stripe
            Rectangle()
                .fill(categoryGradient)
                .frame(height: 4)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Row 1: Icon circle + Name/Manufacturer + Category badge
                HStack(spacing: Spacing.sm) {
                    // 48x48 icon circle
                    ZStack {
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(categoryColor.opacity(0.1))
                            .frame(width: 48, height: 48)
                        Image(systemName: aircraftIcon)
                            .font(.system(size: 22))
                            .foregroundStyle(categoryColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(aircraft.name)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.readoutWhite)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("\(aircraft.manufacturer) \(aircraft.model)")
                            .font(.caption)
                            .foregroundStyle(Color.cockpitLabel)
                            .lineLimit(1)
                    }

                    Spacer()

                    categoryBadge
                }

                // Row 2: Three spec chips
                HStack(spacing: Spacing.xs) {
                    specChip(label: "Empty", value: formatted(aircraft.emptyWeight.value), unit: "lbs")
                    specChip(label: "Max", value: formatted(aircraft.maxGrossWeight.value), unit: "lbs")
                    specChip(label: "Useful", value: formatted(aircraft.usefulLoad.value), unit: "lbs")
                }

                // Row 3: CTA
                HStack {
                    Spacer()
                    HStack(spacing: Spacing.xs) {
                        Text("Calculate W&B")
                            .font(.subheadline.weight(.medium))
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(Color.readoutBlue)
                }
            }
            .padding(Spacing.md)
        }
        .background(Color.cockpitSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.cockpitBezel, lineWidth: 1)
        )
        .appShadow(.medium)
    }

    // MARK: - Category Badge

    private var categoryBadge: some View {
        let isSingleEngine = aircraft.category == .singleEngine
        let label = isSingleEngine ? "Single Engine" : "Multi Engine"
        let color = categoryColor

        return Text(label)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    // MARK: - Spec Chip

    private func specChip(label: String, value: String, unit: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.cockpitLabel)
                .textCase(.uppercase)
                .tracking(0.5)
            HStack(spacing: 2) {
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(Color.readoutWhite)
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(Color.cockpitLabel)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xs)
        .background(Color.cockpitBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xs))
    }

    // MARK: - Formatting Helper

    private func formatted(_ value: Double) -> String {
        Self.weightFormatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
}
