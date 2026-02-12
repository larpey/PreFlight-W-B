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
