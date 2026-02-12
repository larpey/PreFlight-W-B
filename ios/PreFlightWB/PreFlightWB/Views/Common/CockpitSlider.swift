import SwiftUI

/// A visually rich slider styled like a cockpit instrument control.
/// Features a 28pt thumb with inner accent dot, filled track with glow shadow,
/// and a value callout popup visible while dragging.
struct CockpitSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 1
    var accentColor: Color = .readoutBlue
    var showValueCallout: Bool = true

    @State private var isDragging = false
    @State private var lastHapticTime: Date = .distantPast
    @State private var wasAtBound = false

    private let trackHeight: CGFloat = 6
    private let thumbSize: CGFloat = 28

    private var fraction: Double {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        return (value - range.lowerBound) / span
    }

    var body: some View {
        GeometryReader { geo in
            let trackWidth = geo.size.width - thumbSize
            let thumbX = thumbSize / 2 + trackWidth * CGFloat(min(max(fraction, 0), 1))
            let centerY = geo.size.height / 2

            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.cockpitBezel)
                    .frame(height: trackHeight)
                    .padding(.horizontal, thumbSize / 2)

                // Filled track with glow
                Capsule()
                    .fill(accentColor)
                    .frame(width: max(0, thumbX), height: trackHeight)
                    .padding(.leading, thumbSize / 2)
                    .shadow(color: accentColor.opacity(0.4), radius: 4)

                // Thumb
                Circle()
                    .fill(Color.cockpitSurfaceElevated)
                    .frame(width: thumbSize, height: thumbSize)
                    .overlay(
                        Circle()
                            .fill(accentColor)
                            .frame(width: 12, height: 12)
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(accentColor.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: accentColor.opacity(isDragging ? 0.5 : 0.2), radius: isDragging ? 8 : 4)
                    .scaleEffect(isDragging ? 1.15 : 1.0)
                    .position(x: thumbX, y: centerY)

                // Value callout (visible while dragging)
                if showValueCallout && isDragging {
                    Text("\(Int(value))")
                        .font(.caption.bold())
                        .monospacedDigit()
                        .foregroundStyle(accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.cockpitSurface)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xs))
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.xs)
                                .strokeBorder(accentColor.opacity(0.3), lineWidth: 1)
                        )
                        .position(x: thumbX, y: centerY - thumbSize - 4)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .frame(height: max(thumbSize, trackHeight))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        isDragging = true
                        let newFraction = max(0, min(1, Double((gesture.location.x - thumbSize / 2) / trackWidth)))
                        let rawValue = range.lowerBound + newFraction * (range.upperBound - range.lowerBound)
                        let stepped = (rawValue / step).rounded() * step
                        let clamped = min(range.upperBound, max(range.lowerBound, stepped))
                        if clamped != value {
                            value = clamped
                            // Throttle haptics to avoid over-feedback
                            let now = Date()
                            if now.timeIntervalSince(lastHapticTime) > 0.05 {
                                Haptic.light()
                                lastHapticTime = now
                            }
                        }
                        // Boundary haptic
                        let isAtBound = clamped == range.lowerBound || clamped == range.upperBound
                        if isAtBound && !wasAtBound {
                            Haptic.medium()
                        }
                        wasAtBound = isAtBound
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
            .animation(.spring(response: 0.2), value: isDragging)
        }
        .frame(height: thumbSize + (showValueCallout ? 28 : 0))
    }
}
