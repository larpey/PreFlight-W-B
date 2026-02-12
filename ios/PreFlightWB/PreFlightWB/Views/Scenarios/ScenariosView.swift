import SwiftUI
import SwiftData

/// List of saved scenarios with swipe-to-delete and load functionality.
/// Styled as a cockpit instrument panel with dark surfaces and glowing readouts.
struct ScenariosView: View {
    @Query(
        filter: #Predicate<SavedScenario> { $0.deletedAt == nil },
        sort: \SavedScenario.updatedAt,
        order: .reverse
    )
    private var scenarios: [SavedScenario]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// Called when user taps a scenario to load it into the calculator.
    var onLoad: ((SavedScenario) -> Void)?

    /// Shared formatter for weight values with comma separators.
    private static let weightFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f
    }()

    var body: some View {
        Group {
            if scenarios.isEmpty {
                emptyState
            } else {
                scenarioList
            }
        }
        .navigationTitle("Saved Scenarios")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .cockpitEnvironment()
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Image(systemName: "airplane")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.cockpitBezel)
                    .offset(x: -8, y: -8)

                Image(systemName: "list.clipboard")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.cockpitBezel)
                    .offset(x: 12, y: 12)
            }
            .frame(height: 64)
            .padding(.bottom, Spacing.xs)

            Text("No Saved Scenarios")
                .font(.headline)
                .foregroundStyle(Color.readoutWhite)

            Text("Save a scenario from the calculator to see it here")
                .font(.subheadline)
                .foregroundStyle(Color.cockpitLabel)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.cockpitBackground)
    }

    // MARK: - Scenario List

    private var scenarioList: some View {
        let grouped = Dictionary(grouping: scenarios, by: \.aircraftId)

        return List {
            ForEach(grouped.keys.sorted(), id: \.self) { aircraftId in
                let aircraftName = AircraftDatabase.aircraft(for: aircraftId)?.name ?? aircraftId

                Section {
                    ForEach(grouped[aircraftId] ?? [], id: \.id) { scenario in
                        ScenarioRow(scenario: scenario, aircraftName: aircraftName)
                            .listRowBackground(Color.cockpitSurface)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Haptic.selection()
                                onLoad?(scenario)
                                dismiss()
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    softDelete(scenario)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(Color.readoutRed)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    onLoad?(scenario)
                                    dismiss()
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(Color.readoutBlue)
                            }
                    }
                } header: {
                    Text(aircraftName)
                        .textCase(.uppercase)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.cockpitLabel)
                        .tracking(0.5)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.cockpitBackground)
    }

    // MARK: - Actions

    private func softDelete(_ scenario: SavedScenario) {
        scenario.deletedAt = .now
        scenario.dirty = true
        try? modelContext.save()
    }
}

/// A row displaying a single saved scenario's summary.
private struct ScenarioRow: View {
    let scenario: SavedScenario
    let aircraftName: String

    /// Relative timestamp formatter.
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .full
        return f
    }()

    /// Weight formatter with comma separators.
    private static let weightFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            // MARK: - Aircraft Mini-Badge
            HStack(spacing: Spacing.xxs) {
                Circle()
                    .fill(Color.readoutBlue)
                    .frame(width: 6, height: 6)
                Text(aircraftName)
                    .font(.caption)
                    .foregroundStyle(Color.cockpitLabel)
            }

            // MARK: - Scenario Name
            Text(scenario.name)
                .font(.body.weight(.medium))
                .fontWeight(.bold)
                .foregroundStyle(Color.readoutWhite)

            // MARK: - Weight / Fuel Summary
            HStack(spacing: Spacing.xxs) {
                if !scenario.stationLoads.isEmpty {
                    let totalWeight = scenario.stationLoads.reduce(0.0) { $0 + $1.weight }
                    let formatted = Self.weightFormatter.string(from: NSNumber(value: totalWeight)) ?? "\(Int(totalWeight))"
                    Text("\(formatted) lbs payload")
                }

                if !scenario.stationLoads.isEmpty && !scenario.fuelLoads.isEmpty {
                    Text("\u{00B7}")
                }

                if !scenario.fuelLoads.isEmpty {
                    let totalFuel = scenario.fuelLoads.reduce(0.0) { $0 + $1.gallons }
                    Text("\(String(format: "%.0f", totalFuel)) gal fuel")
                }
            }
            .font(.caption)
            .foregroundStyle(Color.cockpitLabel)

            // MARK: - Notes Preview
            if let notes = scenario.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(Color.cockpitLabelDim)
                    .lineLimit(1)
            }

            // MARK: - Relative Timestamp
            Text(Self.relativeFormatter.localizedString(for: scenario.updatedAt, relativeTo: .now))
                .font(.caption2)
                .foregroundStyle(Color.cockpitLabelDim)
        }
        .padding(.vertical, Spacing.xxs)
    }
}

#Preview {
    NavigationStack {
        ScenariosView()
    }
    .modelContainer(for: SavedScenario.self, inMemory: true)
}
