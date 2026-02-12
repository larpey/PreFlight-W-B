import SwiftUI
import SwiftData

@main
struct PreFlightWBApp: App {
    @State private var authManager = AuthManager()
    @Environment(\.scenePhase) private var scenePhase

    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([SavedScenario.self, SyncMeta.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .onAppear {
                    let container = modelContainer
                    authManager.onAuthenticated = {
                        await syncQuietly(container: container)
                    }
                }
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active, authManager.isAuthenticated {
                Task { @MainActor in
                    await syncQuietly(container: modelContainer)
                }
            }
        }
    }

    @MainActor
    private func syncQuietly(container: ModelContainer) async {
        let context = container.mainContext
        let syncService = SyncService(modelContext: context)
        _ = try? await syncService.syncScenarios()
    }
}
