import SwiftUI

/// Cockpit-themed fuel tank input row.
/// Displays tank name, arm, glowing gallon/weight readout, +/- buttons,
/// CockpitSlider, and preset chips (Full / Tabs / Half / Empty).
/// Tap the readout to enter a value directly via alert.
struct FuelInputRow: View {
    let tank: FuelTank
    @Binding var gallons: Double

    @State private var showDirectInput = false
    @State private var directInputText = ""

    private var weight: Double {
        gallons * tank.fuelWeightPerGallon
    }

    private var fraction: Double {
        guard tank.maxGallons.value > 0 else { return 0 }
        return min(gallons / tank.maxGallons.value, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {

            // MARK: 1 — Header
            HStack {
                Text(tank.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.readoutWhite)
                Spacer()
                Text("Arm: \(String(format: "%.1f", tank.arm.value))\"")
                    .font(.caption)
                    .foregroundStyle(Color.cockpitLabel)
            }

            // MARK: 2 — Readout + controls
            HStack {
                // Tappable readout (direct input)
                Button {
                    directInputText = String(format: "%.1f", gallons)
                    showDirectInput = true
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", gallons))
                            .font(InstrumentFont.readoutSmall)
                            .monospacedDigit()
                            .glowingReadout(color: .readoutBlue)
                            .contentTransition(.numericText())

                        Text("gal")
                            .font(.caption)
                            .foregroundStyle(Color.cockpitLabel)

                        Text("=")
                            .font(.caption)
                            .foregroundStyle(Color.cockpitLabelDim)

                        Text("\(Int(weight))")
                            .font(.subheadline.weight(.semibold).monospacedDigit())
                            .foregroundStyle(Color.readoutWhite)

                        Text("lbs")
                            .font(.caption)
                            .foregroundStyle(Color.cockpitLabel)
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                // +/- circle buttons
                HStack(spacing: Spacing.xs) {
                    Button {
                        gallons = max(0, gallons - 1)
                        Haptic.light()
                    } label: {
                        Image(systemName: "minus")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.readoutWhite)
                            .frame(width: Spacing.touchMinimum, height: Spacing.touchMinimum)
                            .background(Color.cockpitBezel)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.press)

                    Button {
                        gallons = min(tank.maxGallons.value, gallons + 1)
                        Haptic.light()
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.readoutWhite)
                            .frame(width: Spacing.touchMinimum, height: Spacing.touchMinimum)
                            .background(Color.cockpitBezel)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.press)
                }
            }

            // MARK: 3 — Slider
            CockpitSlider(
                value: $gallons,
                range: 0...tank.maxGallons.value,
                step: 0.5,
                accentColor: .readoutBlue
            )

            // MARK: 4 — Preset chips
            HStack(spacing: Spacing.xs) {
                PresetChip(
                    label: "Full",
                    sublabel: "\(Int(tank.maxGallons.value)) gal",
                    isSelected: gallons >= tank.maxGallons.value - 0.1
                ) {
                    gallons = tank.maxGallons.value
                }

                PresetChip(
                    label: "Tabs",
                    sublabel: "\(Int(tank.maxGallons.value * 0.75)) gal",
                    isSelected: abs(gallons - tank.maxGallons.value * 0.75) < 0.5
                ) {
                    gallons = (tank.maxGallons.value * 0.75 / 0.5).rounded() * 0.5
                }

                PresetChip(
                    label: "Half",
                    sublabel: "\(Int(tank.maxGallons.value * 0.5)) gal",
                    isSelected: abs(gallons - tank.maxGallons.value * 0.5) < 0.5
                ) {
                    gallons = (tank.maxGallons.value * 0.5 / 0.5).rounded() * 0.5
                }

                PresetChip(
                    label: "Empty",
                    sublabel: "0 gal",
                    isSelected: gallons < 0.1
                ) {
                    gallons = 0
                }
            }
        }
        // MARK: 5 — Card chrome
        .padding(Spacing.md)
        .background {
            // Subtle progress fill
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(Color.readoutBlue.opacity(0.04))
                    .frame(width: geo.size.width * fraction)
            }
        }
        .background(Color.cockpitSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.cockpitBezel, lineWidth: 1)
        )
        .alert("Enter Fuel", isPresented: $showDirectInput) {
            TextField("Gallons", text: $directInputText)
                .keyboardType(.decimalPad)
            Button("OK") {
                if let val = Double(directInputText) {
                    gallons = min(val, tank.maxGallons.value)
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

#Preview {
    FuelInputRow(
        tank: FuelTank(
            id: "main_tanks",
            name: "Main Tanks",
            arm: SourcedValue(
                value: 48.0,
                unit: .inches,
                source: SourceAttribution(
                    primary: .init(
                        document: "POH",
                        section: "6-5",
                        publisher: "Cessna",
                        datePublished: "1976",
                        tcdsNumber: nil,
                        url: nil
                    ),
                    secondary: nil,
                    confidence: .high,
                    lastVerified: "2024-01-01",
                    notes: nil
                )
            ),
            maxGallons: SourcedValue(
                value: 42,
                unit: .gallons,
                source: SourceAttribution(
                    primary: .init(
                        document: "POH",
                        section: "6-5",
                        publisher: "Cessna",
                        datePublished: "1976",
                        tcdsNumber: nil,
                        url: nil
                    ),
                    secondary: nil,
                    confidence: .high,
                    lastVerified: "2024-01-01",
                    notes: nil
                )
            ),
            fuelWeightPerGallon: 6.0,
            isOptional: false
        ),
        gallons: .constant(21.0)
    )
    .padding()
    .background(Color.cockpitBackground)
}
