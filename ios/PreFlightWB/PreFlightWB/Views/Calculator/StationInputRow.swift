import SwiftUI

/// Cockpit-themed station load input row.
/// Displays station name, arm, glowing weight readout with +/- controls,
/// a CockpitSlider, and preset chips for seat stations.
/// Tap the weight readout to enter a number directly via an alert.
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
        VStack(alignment: .leading, spacing: Spacing.sm) {

            // MARK: 1 - Header row
            HStack {
                Text(station.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.readoutWhite)

                Spacer()

                Text("Arm: \(String(format: "%.1f", station.arm.value))\"")
                    .font(.caption)
                    .foregroundStyle(Color.cockpitLabel)
            }

            // MARK: 2 - Weight readout + controls row
            HStack {
                // Tappable weight readout
                Button {
                    directInputText = "\(Int(weight))"
                    showDirectInput = true
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(weight))")
                            .font(InstrumentFont.readoutSmall)
                            .monospacedDigit()
                            .glowingReadout(color: .readoutWhite)
                            .contentTransition(.numericText())

                        Text("lbs")
                            .font(.caption)
                            .foregroundStyle(Color.cockpitLabel)
                    }
                }
                .buttonStyle(.press)

                Spacer()

                // Max weight label
                if let maxWeight = station.maxWeight {
                    Text("/ \(Int(maxWeight))")
                        .font(.caption)
                        .foregroundStyle(Color.cockpitLabel)
                }

                // +/- circle buttons
                HStack(spacing: Spacing.xs) {
                    Button {
                        weight = max(weight - 5, 0)
                        Haptic.light()
                    } label: {
                        Image(systemName: "minus")
                            .font(.caption.weight(.bold))
                            .frame(width: Spacing.touchMinimum, height: Spacing.touchMinimum)
                            .background(Color.cockpitBezel)
                            .clipShape(Circle())
                            .foregroundStyle(Color.readoutWhite)
                    }
                    .buttonStyle(.press)

                    Button {
                        weight = min(weight + 5, station.maxWeight ?? weight + 5)
                        Haptic.light()
                    } label: {
                        Image(systemName: "plus")
                            .font(.caption.weight(.bold))
                            .frame(width: Spacing.touchMinimum, height: Spacing.touchMinimum)
                            .background(Color.cockpitBezel)
                            .clipShape(Circle())
                            .foregroundStyle(Color.readoutWhite)
                    }
                    .buttonStyle(.press)
                }
            }

            // MARK: 3 - CockpitSlider
            CockpitSlider(
                value: $weight,
                range: 0...(station.maxWeight ?? 400),
                step: 1,
                accentColor: .readoutBlue
            )

            // MARK: 4 - Preset chips (seat stations only)
            if isSeatStation {
                HStack(spacing: Spacing.xs) {
                    ForEach(passengerPresets, id: \.label) { preset in
                        PresetChip(
                            label: shortLabel(for: preset.label),
                            sublabel: "\(Int(preset.weight)) lbs",
                            isSelected: abs(weight - preset.weight) < 1,
                            action: {
                                weight = min(preset.weight, station.maxWeight ?? 9999)
                            }
                        )
                    }
                }
            }
        }
        // MARK: 5 - Card chrome
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

    // MARK: - Short Label Extraction

    /// Extracts a short display label from a full preset label.
    /// "Adult M 195" -> "Adult M", "Child 87" -> "Child", "Empty" -> "Empty"
    private func shortLabel(for label: String) -> String {
        let parts = label.split(separator: " ")
        // If last component is a number, drop it
        if let last = parts.last, Double(last) != nil {
            return parts.dropLast().joined(separator: " ")
        }
        return label
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
    .background(Color.cockpitBackground)
}
