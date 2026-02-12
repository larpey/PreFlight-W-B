import SwiftUI

/// Reusable row for a station load input.
/// Displays station name, arm value, HapticSlider and stepper for weight adjustment.
/// Tap the weight value to enter a number directly via an alert.
struct StationInputRow: View {
    let station: Station
    @Binding var weight: Double

    @State private var showDirectInput = false
    @State private var directInputText = ""

    private var fraction: Double {
        guard let max = station.maxWeight, max > 0 else { return 0 }
        return min(weight / max, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Header: station name + arm
            HStack {
                Text(station.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("Arm: \(String(format: "%.1f", station.arm.value))\"")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if let maxWeight = station.maxWeight {
                    Text("Max \(Int(maxWeight)) lbs")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Slider
            HapticSlider(
                value: $weight,
                range: 0...(station.maxWeight ?? 400),
                step: 1,
                accentColor: .statusInfo
            )

            // Preset buttons (for seat stations only, not baggage)
            if isSeatStation {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.xxs) {
                        ForEach(passengerPresets, id: \.label) { preset in
                            Button {
                                weight = min(preset.weight, station.maxWeight ?? 9999)
                                Haptic.light()
                            } label: {
                                Text(preset.label)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .fixedSize()
                                    .padding(.horizontal, Spacing.xs)
                                    .padding(.vertical, 4)
                                    .background(
                                        abs(weight - preset.weight) < 1
                                            ? Color.statusInfo.opacity(0.2)
                                            : Color.pfSeparator.opacity(0.2)
                                    )
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.trailing, Spacing.xs)
                }
            }

            // Footer: weight value (tappable) + stepper
            HStack {
                Button {
                    directInputText = "\(Int(weight))"
                    showDirectInput = true
                } label: {
                    Text("\(Int(weight)) lbs")
                        .font(.headline)
                        .monospacedDigit()
                        .foregroundStyle(Color.pfText)
                }

                Spacer()

                Stepper("", value: $weight, in: 0...(station.maxWeight ?? 400), step: 5)
                    .labelsHidden()
                    .fixedSize()
                    .onChange(of: weight) { _, _ in
                        Haptic.selection()
                    }
            }
        }
        .padding(Spacing.sm)
        .background {
            // Subtle progress fill
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(Color.statusInfo.opacity(0.04))
                    .frame(width: geo.size.width * fraction)
            }
        }
        .background(Color.pfCard)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .appShadow(.small)
        .alert("Enter Weight", isPresented: $showDirectInput) {
            TextField("Weight (lbs)", text: $directInputText)
                .keyboardType(.decimalPad)
            Button("OK") {
                if let val = Double(directInputText) {
                    weight = min(val, station.maxWeight ?? 9999)
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    // MARK: - Passenger Presets (FAA AC 120-27F)

    private struct Preset {
        let label: String
        let weight: Double
    }

    /// Whether this station is a seat (not baggage/cargo).
    private var isSeatStation: Bool {
        let id = station.id.lowercased()
        return id.contains("seat") || id.contains("pilot") || id.contains("pax")
    }

    /// Winter = Nov through Mar, Summer = Apr through Oct.
    private var isWinter: Bool {
        let month = Calendar.current.component(.month, from: Date())
        return month >= 11 || month <= 3
    }

    /// FAA AC 120-27F standard passenger weights.
    private var passengerPresets: [Preset] {
        let maleWeight: Double = isWinter ? 195 : 190
        let femaleWeight: Double = isWinter ? 175 : 170
        let childWeight: Double = isWinter ? 87 : 82
        return [
            Preset(label: "Adult M \(Int(maleWeight))", weight: maleWeight),
            Preset(label: "Adult F \(Int(femaleWeight))", weight: femaleWeight),
            Preset(label: "Child \(Int(childWeight))", weight: childWeight),
            Preset(label: "Empty", weight: 0),
        ]
    }
}

#Preview {
    StationInputRow(
        station: Station(
            id: "front_seats",
            name: "Front Seats",
            arm: SourcedValue(
                value: 37.0,
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
            maxWeight: 400,
            defaultWeight: 170
        ),
        weight: .constant(170)
    )
    .padding()
    .background(Color.pfBackground)
}
