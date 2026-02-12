import SwiftUI

/// A glassmorphism card modifier using ultraThinMaterial background.
struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = CornerRadius.md
    var padding: CGFloat = Spacing.md

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .appShadow(.medium)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = CornerRadius.md, padding: CGFloat = Spacing.md) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, padding: padding))
    }
}
