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

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // MARK: - Aircraft Name
            Text(aircraft.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color.pfText)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            // MARK: - Manufacturer + Model
            Text("\(aircraft.manufacturer) \(aircraft.model)")
                .font(.subheadline)
                .foregroundStyle(Color.pfTextSecondary)
                .lineLimit(1)

            // MARK: - Spec Row
            specRow

            Spacer(minLength: Spacing.xxs)

            // MARK: - Category Badge + Chevron
            HStack {
                categoryBadge

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: CornerRadius.md, padding: Spacing.md)
    }

    // MARK: - Spec Row

    private var specRow: some View {
        let emptyWeight = Self.weightFormatter.string(from: NSNumber(value: aircraft.emptyWeight.value)) ?? "\(Int(aircraft.emptyWeight.value))"
        let maxWeight = Self.weightFormatter.string(from: NSNumber(value: aircraft.maxGrossWeight.value)) ?? "\(Int(aircraft.maxGrossWeight.value))"
        let usefulLoad = Self.weightFormatter.string(from: NSNumber(value: aircraft.usefulLoad.value)) ?? "\(Int(aircraft.usefulLoad.value))"

        return HStack(spacing: Spacing.xxs) {
            Text("Empty: \(emptyWeight) lbs")
            Text("\u{2022}")
                .foregroundStyle(.quaternary)
            Text("Max: \(maxWeight) lbs")
            Text("\u{2022}")
                .foregroundStyle(.quaternary)
            Text("Useful: \(usefulLoad) lbs")
        }
        .font(.caption.monospacedDigit())
        .foregroundStyle(Color.pfTextSecondary)
        .lineLimit(1)
        .minimumScaleFactor(0.75)
    }

    // MARK: - Category Badge

    private var categoryBadge: some View {
        let isSingleEngine = aircraft.category == .singleEngine
        let label = isSingleEngine ? "Single Engine" : "Multi Engine"
        let color = isSingleEngine ? Color.statusInfo : Color.statusCaution

        return Text(label)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .padding(.horizontal, Spacing.xs + 2)
            .padding(.vertical, Spacing.xxs + 1)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}
