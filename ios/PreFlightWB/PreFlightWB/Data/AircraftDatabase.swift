import Foundation

enum AircraftDatabase {
    static let all: [Aircraft] = [
        .cessna172m,
        .bonanzaA36,
        .cherokee6,
        .navajoChieftain,
    ]

    static func aircraft(for id: String) -> Aircraft? {
        all.first { $0.id == id }
    }
}
