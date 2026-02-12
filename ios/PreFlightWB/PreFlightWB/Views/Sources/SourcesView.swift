import SwiftUI

/// Source attribution display for an aircraft.
/// Shows the provenance and confidence of every specification value
/// with collapsible sections and copy-citation support.
struct SourcesView: View {
    let aircraft: Aircraft

    @State private var expandedSections: Set<String> = ["aircraft"]

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Aircraft info card (always visible, expanded by default)
                DisclosureGroup(isExpanded: binding(for: "aircraft")) {
                    aircraftInfoContent
                } label: {
                    Text("Aircraft Information")
                        .sectionHeaderStyle()
                }
                .padding(Spacing.md)
                .background(Color.pfCard)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))

                // Weight specifications
                DisclosureGroup(isExpanded: binding(for: "weights")) {
                    VStack(spacing: Spacing.sm) {
                        specRow(
                            label: "Empty Weight",
                            value: formatted(aircraft.emptyWeight.value),
                            unit: "lbs",
                            source: aircraft.emptyWeight.source
                        )
                        specRow(
                            label: "Max Gross Weight",
                            value: formatted(aircraft.maxGrossWeight.value),
                            unit: "lbs",
                            source: aircraft.maxGrossWeight.source
                        )
                        specRow(
                            label: "Useful Load",
                            value: formatted(aircraft.usefulLoad.value),
                            unit: "lbs",
                            source: aircraft.usefulLoad.source
                        )
                    }
                } label: {
                    Text("Weight Specifications")
                        .sectionHeaderStyle()
                }
                .padding(Spacing.md)
                .background(Color.pfCard)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))

                // CG Range
                DisclosureGroup(isExpanded: binding(for: "cgrange")) {
                    VStack(spacing: Spacing.sm) {
                        specRow(
                            label: "Forward Limit",
                            value: formatted(aircraft.cgRange.forward.value, decimals: 1),
                            unit: "inches",
                            source: aircraft.cgRange.forward.source
                        )
                        specRow(
                            label: "Aft Limit",
                            value: formatted(aircraft.cgRange.aft.value, decimals: 1),
                            unit: "inches",
                            source: aircraft.cgRange.aft.source
                        )
                    }
                } label: {
                    Text("CG Range")
                        .sectionHeaderStyle()
                }
                .padding(Spacing.md)
                .background(Color.pfCard)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))

                // Loading Stations
                DisclosureGroup(isExpanded: binding(for: "stations")) {
                    VStack(spacing: Spacing.sm) {
                        ForEach(aircraft.stations) { station in
                            specRow(
                                label: station.name,
                                value: "Arm \(formatted(station.arm.value, decimals: 1))\"",
                                unit: station.maxWeight.map { "(max \(formatted($0)) lbs)" } ?? "",
                                source: station.arm.source
                            )
                        }
                    }
                } label: {
                    Text("Loading Stations")
                        .sectionHeaderStyle()
                }
                .padding(Spacing.md)
                .background(Color.pfCard)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))

                // Fuel Tanks
                DisclosureGroup(isExpanded: binding(for: "fuel")) {
                    VStack(spacing: Spacing.sm) {
                        ForEach(aircraft.fuelTanks) { tank in
                            specRow(
                                label: tank.name,
                                value: "\(formatted(tank.maxGallons.value)) gal @ arm \(formatted(tank.arm.value, decimals: 1))\"",
                                unit: "",
                                source: tank.maxGallons.source
                            )
                        }
                    }
                } label: {
                    Text("Fuel Tanks")
                        .sectionHeaderStyle()
                }
                .padding(Spacing.md)
                .background(Color.pfCard)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))

                // CG Envelope
                DisclosureGroup(isExpanded: binding(for: "envelope")) {
                    envelopeSourceCard(source: aircraft.cgEnvelope.source)
                } label: {
                    Text("CG Envelope")
                        .sectionHeaderStyle()
                }
                .padding(Spacing.md)
                .background(Color.pfCard)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))

                Spacer(minLength: Spacing.xl)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.md)
        }
        .background(Color.pfBackground)
        .navigationTitle("Sources: \(aircraft.model)")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Section Binding

    private func binding(for section: String) -> Binding<Bool> {
        Binding(
            get: { expandedSections.contains(section) },
            set: { isExpanded in
                if isExpanded {
                    expandedSections.insert(section)
                } else {
                    expandedSections.remove(section)
                }
            }
        )
    }

    // MARK: - Aircraft Info Content

    private var aircraftInfoContent: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(aircraft.name)
                .font(.headline)

            HStack(spacing: 0) {
                Text(aircraft.manufacturer)
                if let year = aircraft.year {
                    Text(" \u{00B7} \(year)")
                }
                Text(" \u{00B7} TCDS \(aircraft.regulatory.tcdsNumber)")
            }
            .font(.caption)
            .foregroundStyle(Color.pfTextSecondary)

            Text("Datum: \(aircraft.datum)")
                .font(.caption)
                .foregroundStyle(Color.pfTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Spacing.xs)
    }

    // MARK: - Spec Row

    private func specRow(
        label: String,
        value: String,
        unit: String,
        source: SourceAttribution
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Value row
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                HStack(spacing: Spacing.xxs) {
                    Text(value)
                        .monospacedDigit()
                    if !unit.isEmpty {
                        Text(unit)
                    }
                }
                .font(.subheadline)
            }

            // Source attribution
            InlineSourceView(source: source)
        }
        .padding(Spacing.sm)
        .background(Color.pfBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
    }

    // MARK: - Envelope Source Card

    private func envelopeSourceCard(source: SourceAttribution) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.xs) {
                Text("Source Document")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.pfTextSecondary)
                Spacer()
                ConfidenceBadge(confidence: source.confidence)
            }

            Text(source.primary.document)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(source.primary.section)
                .font(.caption)
                .foregroundStyle(Color.pfTextSecondary)

            Text("Publisher: \(source.primary.publisher)")
                .font(.caption)
                .foregroundStyle(Color.pfTextSecondary)

            Text("Published: \(source.primary.datePublished)")
                .font(.caption)
                .foregroundStyle(Color.pfTextSecondary)

            Text("Last Verified: \(source.lastVerified)")
                .font(.caption)
                .foregroundStyle(Color.pfTextSecondary)

            // Copy citation button
            Button {
                let citation = "\(source.primary.document), \(source.primary.section) - \(source.primary.publisher) (\(source.primary.datePublished))"
                UIPasteboard.general.string = citation
                Haptic.success()
            } label: {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "doc.on.doc")
                    Text("Copy Citation")
                }
                .font(.caption)
                .foregroundStyle(Color.statusInfo)
            }
            .buttonStyle(.press)
            .padding(.top, Spacing.xxs)

            if let secondary = source.secondary {
                Divider()
                Text("Cross-Reference")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.pfTextSecondary)
                Text(secondary.document)
                    .font(.caption)
                Text("Verification: \(secondary.verification)")
                    .font(.caption)
                    .foregroundStyle(Color.pfTextSecondary)
            }

            if let notes = source.notes {
                Divider()
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(Color.statusCaution)
            }
        }
        .padding(.top, Spacing.xs)
    }

    // MARK: - Formatting

    private func formatted(_ value: Double, decimals: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(decimals)f", value)
    }
}

// MARK: - Inline Source View

/// Compact source attribution display with confidence indicator and copy button.
private struct InlineSourceView: View {
    let source: SourceAttribution

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ConfidenceBadge(confidence: source.confidence)

            Text(source.primary.document)
                .font(.caption)
                .foregroundStyle(Color.pfTextSecondary)

            Text("\u{00B7}")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Text(source.primary.section)
                .font(.caption)
                .foregroundStyle(Color.pfTextSecondary)

            Spacer(minLength: 0)

            // Copy citation button
            Button {
                let citation = "\(source.primary.document), \(source.primary.section) - \(source.primary.publisher) (\(source.primary.datePublished))"
                UIPasteboard.general.string = citation
                Haptic.success()
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.caption2)
                    .foregroundStyle(Color.statusInfo)
            }
            .buttonStyle(.press)

            if let notes = source.notes {
                Text(String(notes.prefix(60)))
                    .font(.caption)
                    .foregroundStyle(Color.statusCaution)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Confidence Badge

/// Colored dot with text label indicating confidence level.
struct ConfidenceBadge: View {
    let confidence: Confidence

    private var color: Color {
        switch confidence {
        case .high:
            return .confidenceHigh
        case .medium:
            return .confidenceMedium
        case .low:
            return .confidenceLow
        }
    }

    private var label: String {
        switch confidence {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel("\(label) confidence")
    }
}

#Preview {
    NavigationStack {
        SourcesView(aircraft: .cessna172m)
    }
}
