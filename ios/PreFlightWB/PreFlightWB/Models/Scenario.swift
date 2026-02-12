import Foundation
import SwiftData

// MARK: - Saved Scenario

@Model
final class SavedScenario {
    @Attribute(.unique) var id: String
    var aircraftId: String
    var name: String
    var stationLoadsData: Data
    var fuelLoadsData: Data
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    var dirty: Bool

    /// Decoded station loads from the stored JSON data.
    @Transient var stationLoads: [StationLoad] {
        get {
            (try? JSONDecoder().decode([StationLoad].self, from: stationLoadsData)) ?? []
        }
        set {
            stationLoadsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    /// Decoded fuel loads from the stored JSON data.
    @Transient var fuelLoads: [FuelLoad] {
        get {
            (try? JSONDecoder().decode([FuelLoad].self, from: fuelLoadsData)) ?? []
        }
        set {
            fuelLoadsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    init(
        id: String = UUID().uuidString,
        aircraftId: String,
        name: String,
        stationLoads: [StationLoad] = [],
        fuelLoads: [FuelLoad] = [],
        notes: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        deletedAt: Date? = nil,
        dirty: Bool = false
    ) {
        self.id = id
        self.aircraftId = aircraftId
        self.name = name
        self.stationLoadsData = (try? JSONEncoder().encode(stationLoads)) ?? Data()
        self.fuelLoadsData = (try? JSONEncoder().encode(fuelLoads)) ?? Data()
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.dirty = dirty
    }
}

// MARK: - Sync Meta

@Model
final class SyncMeta {
    @Attribute(.unique) var key: String
    var lastSyncAt: String?

    init(key: String, lastSyncAt: String? = nil) {
        self.key = key
        self.lastSyncAt = lastSyncAt
    }
}
