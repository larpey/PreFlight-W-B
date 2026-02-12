import SwiftUI
import SwiftData

/// Main calculator screen. Takes an Aircraft and allows the user to adjust
/// station and fuel loads, view results, CG envelope chart, and save scenarios.
///
/// Single scrollable page with collapsible sections (Loading / Fuel / Results)
/// and a cockpit-style instrument header pinned at the top.
struct CalculatorView: View {
    let aircraft: Aircraft
    let initialScenario: SavedScenario?

    @State private var stationWeights: [String: Double] = [:]
    @State private var fuelGallons: [String: Double] = [:]
    @State private var fuelBurnGallons: Double = 0
    @State private var showSaveSheet = false
    @State private var showChart = false
    @State private var loadedScenarioId: String?
    @State private var loadedScenarioName: String?
    @State private var showShareSheet = false
    @State private var pdfURL: URL?

    // Collapsible section states
    @State private var loadingExpanded = true
    @State private var fuelExpanded = true
    @State private var resultsExpanded = true

    @Environment(\.modelContext) private var modelContext

    init(aircraft: Aircraft, initialScenario: SavedScenario? = nil) {
        self.aircraft = aircraft
        self.initialScenario = initialScenario
    }

    // MARK: - Computed Loads

    private var stationLoads: [StationLoad] {
        aircraft.stations.map { station in
            StationLoad(
                stationId: station.id,
                weight: stationWeights[station.id] ?? station.defaultWeight ?? 0
            )
        }
    }

    private var fuelLoads: [FuelLoad] {
        aircraft.fuelTanks.map { tank in
            FuelLoad(
                tankId: tank.id,
                gallons: fuelGallons[tank.id] ?? 0
            )
        }
    }

    /// Recalculated every time any state changes.
    private var result: CalculationResult {
        Calculator.calculate(
            aircraft: aircraft,
            stationLoads: stationLoads,
            fuelLoads: fuelLoads
        )
    }

    private var landingResult: LandingResult? {
        Calculator.calculateLanding(
            takeoffResult: result,
            aircraft: aircraft,
            fuelLoads: fuelLoads,
            fuelBurnGallons: fuelBurnGallons
        )
    }

    private var dangerWarnings: [CalculationWarning] {
        var warnings = result.warnings.filter { $0.level == .danger }
        if let landing = landingResult {
            warnings += landing.warnings.filter { $0.level == .danger }
        }
        return warnings
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Danger warnings (pinned top)
            if !dangerWarnings.isEmpty {
                SafetyAlerts(warnings: dangerWarnings)
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.xs)
            }

            // Instrument header (pinned top)
            CompactResultsHeader(result: result, aircraft: aircraft)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)

            // Single scrollable page with collapsible sections
            ScrollView {
                VStack(spacing: Spacing.md) {
                    // LOADING section
                    CollapsibleSection(
                        title: "LOADING",
                        icon: "scalemass",
                        isExpanded: $loadingExpanded
                    ) {
                        stationSection
                    }

                    // FUEL section
                    CollapsibleSection(
                        title: "FUEL",
                        icon: "fuelpump",
                        isExpanded: $fuelExpanded
                    ) {
                        fuelSection
                    }

                    // RESULTS section
                    CollapsibleSection(
                        title: "RESULTS",
                        icon: "chart.bar.doc.horizontal",
                        isExpanded: $resultsExpanded
                    ) {
                        resultsSection
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
            }
        }
        .cockpitEnvironment()
        .navigationTitle(aircraft.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    if let id = loadedScenarioId, let name = loadedScenarioName {
                        saveScenario(name: name, existingId: id)
                    } else {
                        showSaveSheet = true
                    }
                } label: {
                    Image(systemName: loadedScenarioId != nil ? "checkmark.square" : "square.and.arrow.down")
                        .foregroundStyle(Color.readoutBlue)
                }

                NavigationLink {
                    SourcesView(aircraft: aircraft)
                } label: {
                    Image(systemName: "doc.text.magnifyingglass")
                        .foregroundStyle(Color.readoutBlue)
                }
            }
        }
        .sheet(isPresented: $showSaveSheet) {
            SaveScenarioSheet(defaultName: loadedScenarioName ?? "") { name, notes in
                saveScenario(name: name, notes: notes)
                showSaveSheet = false
            }
        }
        .onAppear {
            initializeLoads()
        }
    }

    // MARK: - Station Section (Loading)

    private var stationSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Reset button
            HStack {
                Spacer()
                Button {
                    resetAll()
                    Haptic.medium()
                } label: {
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.caption2.weight(.semibold))
                        Text("Reset All")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(Color.cockpitLabel)
                }
                .buttonStyle(.plain)
            }

            ForEach(aircraft.stations) { station in
                StationInputRow(
                    station: station,
                    weight: stationBinding(for: station)
                )
            }
        }
    }

    // MARK: - Fuel Section

    private var fuelSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            ForEach(aircraft.fuelTanks) { tank in
                FuelInputRow(
                    tank: tank,
                    gallons: fuelBinding(for: tank)
                )
            }

            // Fuel burn input
            fuelBurnSection
        }
    }

    // MARK: - Fuel Burn Section

    private var totalFuelGallons: Double {
        fuelLoads.reduce(0.0) { $0 + max(0, $1.gallons) }
    }

    private var fuelBurnSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Expected Fuel Burn")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.readoutWhite)
                Spacer()
            }

            // Readout row
            HStack {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(Int(fuelBurnGallons))")
                        .font(InstrumentFont.readoutSmall)
                        .monospacedDigit()
                        .glowingReadout(color: .readoutAmber)
                        .contentTransition(.numericText())

                    Text("gal")
                        .font(.caption)
                        .foregroundStyle(Color.cockpitLabel)

                    Text("=")
                        .font(.caption)
                        .foregroundStyle(Color.cockpitLabelDim)

                    Text("\(Int(fuelBurnGallons * 6.0))")
                        .font(.subheadline.weight(.semibold).monospacedDigit())
                        .foregroundStyle(Color.readoutWhite)

                    Text("lbs")
                        .font(.caption)
                        .foregroundStyle(Color.cockpitLabel)
                }

                Spacer()

                // +/- circle buttons
                HStack(spacing: Spacing.xs) {
                    Button {
                        fuelBurnGallons = max(0, fuelBurnGallons - 1)
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
                        fuelBurnGallons = min(totalFuelGallons, fuelBurnGallons + 1)
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

            CockpitSlider(
                value: $fuelBurnGallons,
                range: 0...max(1, totalFuelGallons),
                step: 1,
                accentColor: .readoutAmber
            )

            if let landing = landingResult {
                HStack(spacing: Spacing.sm) {
                    Label(
                        "\(formatted(landing.landingWeight, decimals: 0)) lbs",
                        systemImage: "airplane.arrival"
                    )
                    .font(.caption)
                    .foregroundStyle(landing.isWithinWeightLimit ? Color.readoutGreen : Color.readoutRed)

                    Spacer()

                    Label(
                        "CG \(formatted(landing.landingCG, decimals: 2))\"",
                        systemImage: "scope"
                    )
                    .font(.caption)
                    .foregroundStyle(landing.isWithinCGEnvelope ? Color.readoutGreen : Color.readoutRed)
                }
                .padding(.top, Spacing.xxs)
            }
        }
        .padding(Spacing.md)
        .background(Color.cockpitSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.cockpitBezel, lineWidth: 1)
        )
    }

    // MARK: - Results Section

    private var resultsSection: some View {
        VStack(spacing: Spacing.md) {
            // Full results dashboard
            ResultsDashboard(result: result, aircraft: aircraft, landingResult: landingResult)

            // CG Envelope chart
            CGEnvelopeChart(
                envelope: aircraft.cgEnvelope,
                currentWeight: result.totalWeight,
                currentCG: result.cg,
                isWithinEnvelope: result.isWithinCGEnvelope,
                maxGrossWeight: aircraft.maxGrossWeight.value,
                landingWeight: landingResult?.landingWeight,
                landingCG: landingResult?.landingCG,
                isLandingWithinEnvelope: landingResult?.isWithinCGEnvelope
            )

            // All warnings section
            let allWarnings = result.warnings + (landingResult?.warnings ?? [])
            if !allWarnings.isEmpty {
                SafetyAlerts(warnings: allWarnings)
            }

            // Export PDF button
            Button {
                if let url = PDFExporter.generateLoadSheet(
                    aircraft: aircraft,
                    result: result,
                    landingResult: landingResult,
                    pilotName: nil
                ) {
                    pdfURL = url
                    showShareSheet = true
                }
            } label: {
                Label("Export Load Sheet", systemImage: "square.and.arrow.up")
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                    .foregroundStyle(Color.readoutBlue)
                    .background(Color.cockpitSurface)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.md)
                            .strokeBorder(Color.cockpitBezel, lineWidth: 1)
                    )
            }

            // Loading breakdown table
            breakdownSection

            // Disclaimer
            disclaimerSection
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL {
                ShareSheet(items: [url])
            }
        }
    }

    // MARK: - Disclaimer

    private var disclaimerSection: some View {
        VStack(spacing: Spacing.xxs) {
            Text("For flight planning reference only")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.cockpitLabel)
            Text("Always verify weight and balance calculations using your aircraft's official POH/AFM. This tool does not replace required preflight planning per FAR 91.103.")
                .font(.caption2)
                .foregroundStyle(Color.cockpitLabelDim)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.sm)
        .frame(maxWidth: .infinity)
        .background(Color.cockpitSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    // MARK: - Breakdown Table

    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            VStack(spacing: 0) {
                // Header row
                breakdownHeaderRow

                Divider().opacity(0.3)

                // Empty weight row
                breakdownRow(
                    item: "Empty Weight",
                    weight: aircraft.emptyWeight.value,
                    arm: aircraft.emptyWeightArm.value,
                    moment: aircraft.emptyWeight.value * aircraft.emptyWeightArm.value,
                    weightColor: .readoutWhite,
                    armColor: .readoutWhite
                )

                // Station detail rows
                ForEach(result.stationDetails.filter({ $0.weight > 0 }), id: \.stationId) { detail in
                    Divider().opacity(0.2)
                    breakdownRow(
                        item: detail.name,
                        weight: detail.weight,
                        arm: detail.arm,
                        moment: detail.moment,
                        weightColor: .readoutWhite,
                        armColor: .readoutWhite
                    )
                }

                // Fuel detail rows
                ForEach(result.fuelDetails.filter({ $0.weight > 0 }), id: \.tankId) { detail in
                    Divider().opacity(0.2)
                    breakdownRow(
                        item: "\(detail.name) (\(formatted(detail.gallons, decimals: 0)) gal)",
                        weight: detail.weight,
                        arm: detail.arm,
                        moment: detail.moment,
                        weightColor: .readoutWhite,
                        armColor: .readoutWhite
                    )
                }

                Divider().opacity(0.3)

                // Totals row
                breakdownRow(
                    item: "Total",
                    weight: result.totalWeight,
                    arm: result.cg,
                    moment: result.totalMoment,
                    weightColor: result.isWithinWeightLimit ? .readoutGreen : .readoutRed,
                    armColor: result.isWithinCGEnvelope ? .readoutGreen : .readoutRed,
                    isBold: true
                )
            }
            .background(Color.cockpitSurface)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .strokeBorder(Color.cockpitBezel, lineWidth: 1)
            )
        }
        .padding(.bottom, Spacing.md)
    }

    private var breakdownHeaderRow: some View {
        HStack {
            Text("Item")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Weight")
                .frame(width: 60, alignment: .trailing)
            Text("Arm")
                .frame(width: 50, alignment: .trailing)
            Text("Moment")
                .frame(width: 70, alignment: .trailing)
        }
        .font(.caption)
        .fontWeight(.medium)
        .foregroundStyle(Color.cockpitLabel)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
    }

    private func breakdownRow(
        item: String,
        weight: Double,
        arm: Double,
        moment: Double,
        weightColor: Color,
        armColor: Color,
        isBold: Bool = false
    ) -> some View {
        HStack {
            Text(item)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .foregroundStyle(Color.readoutWhite)
            Text(formatted(weight, decimals: 0))
                .foregroundStyle(weightColor)
                .frame(width: 60, alignment: .trailing)
                .monospacedDigit()
            Text(formatted(arm, decimals: 1))
                .foregroundStyle(armColor)
                .frame(width: 50, alignment: .trailing)
                .monospacedDigit()
            Text(formatted(moment, decimals: 0))
                .foregroundStyle(Color.readoutWhite)
                .frame(width: 70, alignment: .trailing)
                .monospacedDigit()
        }
        .font(.caption)
        .fontWeight(isBold ? .semibold : .regular)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 6)
    }

    // MARK: - Bindings

    private func stationBinding(for station: Station) -> Binding<Double> {
        Binding(
            get: { stationWeights[station.id] ?? station.defaultWeight ?? 0 },
            set: { stationWeights[station.id] = $0 }
        )
    }

    private func fuelBinding(for tank: FuelTank) -> Binding<Double> {
        Binding(
            get: { fuelGallons[tank.id] ?? 0 },
            set: { fuelGallons[tank.id] = $0 }
        )
    }

    // MARK: - Actions

    private func initializeLoads() {
        if let scenario = initialScenario {
            // Pre-populate from saved scenario
            for load in scenario.stationLoads {
                stationWeights[load.stationId] = load.weight
            }
            for load in scenario.fuelLoads {
                fuelGallons[load.tankId] = load.gallons
            }
            loadedScenarioId = scenario.id
            loadedScenarioName = scenario.name
        } else {
            // Initialize from aircraft defaults
            for station in aircraft.stations {
                stationWeights[station.id] = station.defaultWeight ?? 0
            }
            for tank in aircraft.fuelTanks {
                fuelGallons[tank.id] = 0
            }
        }
    }

    private func resetAll() {
        for station in aircraft.stations {
            stationWeights[station.id] = station.defaultWeight ?? 0
        }
        for tank in aircraft.fuelTanks {
            fuelGallons[tank.id] = 0
        }
        fuelBurnGallons = 0
    }

    private func saveScenario(name: String, notes: String? = nil, existingId: String? = nil) {
        if let existingId,
           let existing = try? modelContext.fetch(
               FetchDescriptor<SavedScenario>(
                   predicate: #Predicate { $0.id == existingId }
               )
           ).first {
            // Update existing scenario
            existing.stationLoads = stationLoads
            existing.fuelLoads = fuelLoads
            existing.updatedAt = .now
            existing.dirty = true
            if let notes { existing.notes = notes }
        } else {
            // Create new scenario
            let scenario = SavedScenario(
                aircraftId: aircraft.id,
                name: name,
                stationLoads: stationLoads,
                fuelLoads: fuelLoads,
                notes: notes,
                dirty: true
            )
            modelContext.insert(scenario)
            loadedScenarioId = scenario.id
            loadedScenarioName = name
        }

        try? modelContext.save()
    }

    // MARK: - Formatting

    private func formatted(_ value: Double, decimals: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(decimals)f", value)
    }
}
