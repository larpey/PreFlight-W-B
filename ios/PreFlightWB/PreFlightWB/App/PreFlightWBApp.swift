import SwiftUI
import SwiftData

@main
struct PreFlightWBApp: App {
    @State private var authManager = AuthManager()

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
        }
        .modelContainer(modelContainer)
    }
}
