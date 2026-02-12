import Foundation
import SwiftData

// MARK: - Sync DTOs

/// Outbound change sent to the server during sync.
private struct SyncChange: Encodable {
    let id: String
    let aircraftId: String
    let name: String
    let stationLoads: [StationLoad]
    let fuelLoads: [FuelLoad]
    let notes: String?
    let updatedAt: String
    let deletedAt: String?
}

/// Request body for POST /scenarios/sync.
private struct SyncRequest: Encodable {
    let lastSyncAt: String?
    let changes: [SyncChange]
}

/// A single scenario returned by the server.
private struct ServerScenario: Decodable {
    let id: String
    let aircraftId: String
    let name: String
    let stationLoads: [StationLoad]
    let fuelLoads: [FuelLoad]
    let notes: String?
    let updatedAt: String
    let deletedAt: String?
}

/// Response from POST /scenarios/sync.
private struct SyncResponse: Decodable {
    let serverChanges: [ServerScenario]
    let syncedAt: String
}

// MARK: - Sync Service

/// Orchestrates scenario synchronization between SwiftData and the remote API.
/// Mirrors the TypeScript `syncScenarios()` function.
@MainActor
final class SyncService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Perform a full sync cycle: push dirty → pull server changes → update timestamps.
    /// Returns the total number of scenarios synced (pushed + pulled).
    func syncScenarios() async throws -> Int {
        // 1. Fetch dirty local scenarios
        let dirtyDescriptor = FetchDescriptor<SavedScenario>(
            predicate: #Predicate { $0.dirty == true && $0.deletedAt == nil }
        )
        let dirtyScenarios = (try? modelContext.fetch(dirtyDescriptor)) ?? []

        // Also include soft-deleted dirty scenarios (need to tell server about deletions)
        let dirtyDeletedDescriptor = FetchDescriptor<SavedScenario>(
            predicate: #Predicate { $0.dirty == true && $0.deletedAt != nil }
        )
        let dirtyDeleted = (try? modelContext.fetch(dirtyDeletedDescriptor)) ?? []
        let allDirty = dirtyScenarios + dirtyDeleted

        // 2. Get last sync timestamp
        let lastSyncAt = getLastSyncAt()

        // 3. Build outbound changes
        let iso = ISO8601DateFormatter()
        let changes: [SyncChange] = allDirty.map { scenario in
            SyncChange(
                id: scenario.id,
                aircraftId: scenario.aircraftId,
                name: scenario.name,
                stationLoads: scenario.stationLoads,
                fuelLoads: scenario.fuelLoads,
                notes: scenario.notes,
                updatedAt: iso.string(from: scenario.updatedAt),
                deletedAt: scenario.deletedAt.map { iso.string(from: $0) }
            )
        }

        // 4. POST to /scenarios/sync
        let response: SyncResponse = try await APIClient.shared.fetch(
            "/scenarios/sync",
            method: "POST",
            body: SyncRequest(lastSyncAt: lastSyncAt, changes: changes)
        )

        // 5. Mark pushed scenarios as clean
        for scenario in allDirty {
            scenario.dirty = false
        }

        // 6. Apply server changes locally
        for serverScenario in response.serverChanges {
            applyServerScenario(serverScenario, iso: iso)
        }

        // 7. Update lastSyncAt
        setLastSyncAt(response.syncedAt)

        // 8. Save
        try modelContext.save()

        return allDirty.count + response.serverChanges.count
    }

    // MARK: - Private Helpers

    /// Apply a single server scenario to the local store.
    /// Server wins if the local copy is not dirty.
    private func applyServerScenario(_ server: ServerScenario, iso: ISO8601DateFormatter) {
        let serverId = server.id
        let existingDescriptor = FetchDescriptor<SavedScenario>(
            predicate: #Predicate { scenario in scenario.id == serverId }
        )

        let existing = try? modelContext.fetch(existingDescriptor).first

        if let existing {
            // Only overwrite if local is not dirty (server wins for clean records)
            if !existing.dirty {
                existing.aircraftId = server.aircraftId
                existing.name = server.name
                existing.stationLoads = server.stationLoads
                existing.fuelLoads = server.fuelLoads
                existing.notes = server.notes
                existing.updatedAt = iso.date(from: server.updatedAt) ?? .now
                existing.deletedAt = server.deletedAt.flatMap { iso.date(from: $0) }
            }
        } else {
            // New scenario from server — insert it
            let scenario = SavedScenario(
                id: server.id,
                aircraftId: server.aircraftId,
                name: server.name,
                stationLoads: server.stationLoads,
                fuelLoads: server.fuelLoads,
                notes: server.notes,
                createdAt: iso.date(from: server.updatedAt) ?? .now,
                updatedAt: iso.date(from: server.updatedAt) ?? .now,
                deletedAt: server.deletedAt.flatMap { iso.date(from: $0) },
                dirty: false
            )
            modelContext.insert(scenario)
        }
    }

    /// Read the lastSyncAt timestamp from SyncMeta.
    private func getLastSyncAt() -> String? {
        let descriptor = FetchDescriptor<SyncMeta>(
            predicate: #Predicate { $0.key == "lastSyncAt" }
        )
        return (try? modelContext.fetch(descriptor).first)?.lastSyncAt
    }

    /// Write the lastSyncAt timestamp to SyncMeta.
    private func setLastSyncAt(_ value: String) {
        let descriptor = FetchDescriptor<SyncMeta>(
            predicate: #Predicate { $0.key == "lastSyncAt" }
        )
        if let existing = try? modelContext.fetch(descriptor).first {
            existing.lastSyncAt = value
        } else {
            let meta = SyncMeta(key: "lastSyncAt", lastSyncAt: value)
            modelContext.insert(meta)
        }
    }
}
