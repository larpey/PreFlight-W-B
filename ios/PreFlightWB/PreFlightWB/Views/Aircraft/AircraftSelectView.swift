import SwiftUI
import SwiftData

struct AircraftSelectView: View {
    @Environment(AuthManager.self) private var authManager
    @Query(filter: #Predicate<SavedScenario> { $0.deletedAt == nil })
    private var scenarios: [SavedScenario]

    @State private var searchText = ""

    private let columns = [
        GridItem(.flexible()),
    ]

    /// All aircraft, optionally filtered by search text.
    private var filteredAircraft: [Aircraft] {
        let all = AircraftDatabase.all
        guard !searchText.isEmpty else { return all }
        let query = searchText.lowercased()
        return all.filter { aircraft in
            aircraft.name.lowercased().contains(query)
            || aircraft.manufacturer.lowercased().contains(query)
            || aircraft.model.lowercased().contains(query)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                // MARK: - Saved Scenarios Link
                if !scenarios.isEmpty {
                    savedScenariosCard
                }

                // MARK: - Aircraft Grid
                if filteredAircraft.isEmpty && !searchText.isEmpty {
                    emptyState
                } else {
                    LazyVGrid(columns: columns, spacing: Spacing.sm) {
                        ForEach(filteredAircraft) { aircraft in
                            NavigationLink(value: aircraft.id) {
                                AircraftCard(aircraft: aircraft)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // MARK: - Disclaimer
                Text("Not for flight planning. Always verify with your aircraft\u{2019}s actual W&B records.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.top, Spacing.xs)
                    .padding(.bottom, Spacing.xxl)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.xs)
        }
        .background(Color.pfBackground)
        .searchable(text: $searchText, prompt: "Search aircraft")
        .navigationTitle("Select Aircraft")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: String.self) { aircraftId in
            if let aircraft = AircraftDatabase.aircraft(for: aircraftId) {
                CalculatorView(aircraft: aircraft)
            }
        }
        .toolbar {
            // Scenarios toolbar button
            ToolbarItem(placement: .topBarTrailing) {
                if !scenarios.isEmpty {
                    NavigationLink {
                        ScenariosView()
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.body)
                    }
                }
            }

            // User info toolbar button
            ToolbarItem(placement: .topBarLeading) {
                userBadge
            }
        }
    }

    // MARK: - Saved Scenarios Card

    private var savedScenariosCard: some View {
        NavigationLink {
            ScenariosView()
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "doc.on.doc")
                    .font(.title3)
                    .foregroundStyle(Color.statusInfo)

                Text("Saved Scenarios")
                    .font(.body)
                    .foregroundStyle(Color.pfText)

                Spacer()

                Text("\(scenarios.count)")
                    .font(.subheadline)
                    .foregroundStyle(Color.pfTextSecondary)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .glassCard(cornerRadius: CornerRadius.md, padding: Spacing.md)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            Haptic.selection()
        })
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: "airplane")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
                .padding(.bottom, Spacing.xs)

            Text("No aircraft match")
                .font(.headline)
                .foregroundStyle(Color.pfText)

            Text("Try a different search")
                .font(.subheadline)
                .foregroundStyle(Color.pfTextSecondary)

            Button {
                searchText = ""
            } label: {
                Text("Clear Search")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.statusInfo)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.statusInfo.opacity(0.12))
                    .clipShape(Capsule())
            }
            .padding(.top, Spacing.xs)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }

    // MARK: - User Badge

    @ViewBuilder
    private var userBadge: some View {
        if authManager.isAuthenticated, let user = authManager.currentUser {
            let firstName = user.name.components(separatedBy: " ").first ?? user.name
            Menu {
                Text(user.email)
                Button("Sign Out", role: .destructive) {
                    authManager.signOut()
                }
            } label: {
                HStack(spacing: Spacing.xs) {
                    ZStack {
                        Circle()
                            .fill(Color.statusInfo.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Text(String(firstName.prefix(1)).uppercased())
                            .font(.caption.bold())
                            .foregroundStyle(Color.statusInfo)
                    }
                    Text(firstName)
                        .font(.subheadline)
                        .foregroundStyle(Color.pfText)
                }
            }
        } else if authManager.isGuest {
            Menu {
                Button("Sign In") {
                    authManager.signOut()
                }
            } label: {
                HStack(spacing: Spacing.xs) {
                    ZStack {
                        Circle()
                            .fill(Color.pfTextSecondary.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Text("G")
                            .font(.caption.bold())
                            .foregroundStyle(Color.pfTextSecondary)
                    }
                    Text("Guest")
                        .font(.subheadline)
                        .foregroundStyle(Color.pfTextSecondary)
                }
            }
        }
    }
}

// MARK: - Placeholder Views
// These will be replaced with real implementations in later screens.

struct CalculatorPlaceholderView: View {
    let aircraft: Aircraft

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "scalemass")
                .font(.system(size: 48))
                .foregroundStyle(Color.statusInfo)
            Text(aircraft.name)
                .font(.title2)
                .fontWeight(.bold)
            Text("Calculator view coming soon")
                .font(.subheadline)
                .foregroundStyle(Color.pfTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pfBackground)
        .navigationTitle(aircraft.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ScenariosPlaceholderView: View {
    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "doc.on.doc")
                .font(.system(size: 48))
                .foregroundStyle(Color.statusInfo)
            Text("Saved Scenarios")
                .font(.title2)
                .fontWeight(.bold)
            Text("Scenarios view coming soon")
                .font(.subheadline)
                .foregroundStyle(Color.pfTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pfBackground)
        .navigationTitle("Scenarios")
        .navigationBarTitleDisplayMode(.inline)
    }
}
