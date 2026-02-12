import SwiftUI

/// A collapsible section with icon, title, horizontal rule, and chevron.
/// Used in the calculator view to replace segmented tabs with expandable sections.
struct CollapsibleSection<Content: View>: View {
    let title: String
    let icon: String
    @Binding var isExpanded: Bool
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            // Header bar
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
                Haptic.light()
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(Color.readoutBlue)
                        .frame(width: 20)

                    Text(title)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.cockpitLabel)
                        .tracking(1.5)

                    Rectangle()
                        .fill(Color.cockpitBezel)
                        .frame(height: 1)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.cockpitLabel)
                }
                .padding(.vertical, Spacing.sm)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                content()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
