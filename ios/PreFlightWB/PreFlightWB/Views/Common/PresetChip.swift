import SwiftUI

/// A 48pt-tall tappable preset button with two-line layout.
/// Used for passenger weight presets and fuel tank presets.
struct PresetChip: View {
    let label: String
    let sublabel: String?
    let isSelected: Bool
    let action: () -> Void

    init(label: String, sublabel: String? = nil, isSelected: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.sublabel = sublabel
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button {
            action()
            Haptic.light()
        } label: {
            VStack(spacing: 2) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                if let sublabel {
                    Text(sublabel)
                        .font(.caption2)
                        .foregroundStyle(isSelected ? Color.readoutBlue.opacity(0.7) : Color.cockpitLabel)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: Spacing.touchPreferred)
            .background(isSelected ? Color.readoutBlue.opacity(0.15) : Color.cockpitBezel.opacity(0.6))
            .foregroundStyle(isSelected ? Color.readoutBlue : Color.readoutWhite)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .strokeBorder(isSelected ? Color.readoutBlue.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.press)
    }
}
