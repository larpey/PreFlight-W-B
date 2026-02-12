import SwiftUI

/// Reusable row for fuel tank input.
/// Displays tank name, arm, HapticSlider for gallons, computed weight,
/// and a "Full" quick-action button. Tap the gallons value for direct input.
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
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Header
            HStack {
                Text(tank.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("Arm: \(String(format: "%.1f", tank.arm.value))\"")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Max \(String(format: "%.0f", tank.maxGallons.value)) gal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Slider
            HapticSlider(
                value: $gallons,
                range: 0...tank.maxGallons.value,
                step: 0.5,
                accentColor: .statusInfo
            )

            // Footer
            HStack {
                Button {
                    directInputText = String(format: "%.1f", gallons)
                    showDirectInput = true
                } label: {
                    HStack(spacing: Spacing.xxs) {
                        Text(String(format: "%.1f", gallons))
                            .font(.headline)
                            .monospacedDigit()
                        Text("gal")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("(\(Int(weight)) lbs)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(Color.pfText)
                }

                Spacer()

                // Full button
                Button("Full") {
                    gallons = tank.maxGallons.value
                    Haptic.medium()
                }
                .font(.caption.weight(.medium))
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xxs)
                .background(Color.statusInfo.opacity(0.12))
                .clipShape(Capsule())

                Stepper("", value: $gallons, in: 0...tank.maxGallons.value, step: 1)
                    .labelsHidden()
                    .fixedSize()
                    .onChange(of: gallons) { _, _ in
                        Haptic.selection()
                    }
            }
        }
        .padding(Spacing.sm)
        .background {
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(Color.statusInfo.opacity(0.04))
                    .frame(width: geo.size.width * fraction)
            }
        }
        .background(Color.pfCard)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .appShadow(.small)
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
    .background(Color.pfBackground)
}
