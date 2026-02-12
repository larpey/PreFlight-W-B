import SwiftUI

/// A slider that provides haptic feedback on value changes and boundary hits.
struct HapticSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 1
    var accentColor: Color = .statusInfo

    @State private var lastHapticTime: Date = .distantPast
    @State private var wasAtBound = false

    private let hapticThrottle: TimeInterval = 0.05 // 50ms

    var body: some View {
        Slider(
            value: $value,
            in: range,
            step: step
        )
        .tint(accentColor)
        .onChange(of: value) { oldValue, newValue in
            let now = Date()

            // Check if we hit a boundary
            let isAtBound = newValue == range.lowerBound || newValue == range.upperBound
            if isAtBound && !wasAtBound {
                Haptic.medium()
                wasAtBound = true
                lastHapticTime = now
                return
            }
            wasAtBound = isAtBound

            // Throttled light haptic for value changes
            if now.timeIntervalSince(lastHapticTime) >= hapticThrottle {
                Haptic.light()
                lastHapticTime = now
            }
        }
    }
}
