import SwiftUI

// MARK: - Semantic Colors

extension Color {
    // Surface colors (auto light/dark)
    static let pfBackground = Color(uiColor: .systemGroupedBackground)
    static let pfSurface = Color(uiColor: .secondarySystemGroupedBackground)
    static let pfSurfaceElevated = Color(uiColor: .tertiarySystemBackground)
    static let pfCard = Color(uiColor: .systemBackground)
    static let pfText = Color(uiColor: .label)
    static let pfTextSecondary = Color(uiColor: .secondaryLabel)
    static let pfSeparator = Color(uiColor: .separator)

    // Aviation status colors (FAA standard — same in light/dark)
    static let statusSafe = Color(red: 0.204, green: 0.780, blue: 0.349)     // #34C759
    static let statusCaution = Color(red: 1.0, green: 0.584, blue: 0.0)       // #FF9500
    static let statusDanger = Color(red: 1.0, green: 0.231, blue: 0.188)      // #FF3B30
    static let statusInfo = Color(red: 0.0, green: 0.478, blue: 1.0)          // #007AFF

    // Confidence indicators
    static let confidenceHigh = Color(red: 0.204, green: 0.827, blue: 0.600)
    static let confidenceMedium = Color(red: 0.984, green: 0.749, blue: 0.141)
    static let confidenceLow = Color(red: 0.973, green: 0.443, blue: 0.443)

    // Legacy aliases (keep for backward compatibility during migration)
    static let iosBlue = statusInfo
    static let iosGreen = statusSafe
    static let iosRed = statusDanger
    static let iosOrange = statusCaution
    static let iosYellow = Color(red: 1, green: 0.800, blue: 0)
    static let iosBg = pfBackground
    static let iosCard = pfCard
    static let iosSeparator = pfSeparator
    static let iosTextSecondary = pfTextSecondary
}

// MARK: - Spacing Scale (4pt base)

enum Spacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius Scale

enum CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
}

// MARK: - Shadow Scale

struct AppShadow {
    let color: Color
    let radius: CGFloat
    let y: CGFloat

    static let small = AppShadow(color: .black.opacity(0.06), radius: 4, y: 2)
    static let medium = AppShadow(color: .black.opacity(0.1), radius: 8, y: 4)
    static let large = AppShadow(color: .black.opacity(0.15), radius: 16, y: 8)
}

// MARK: - Haptic Feedback

enum Haptic {
    @MainActor
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    @MainActor
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    @MainActor
    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    @MainActor
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    @MainActor
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    @MainActor
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    @MainActor
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

// MARK: - View Modifiers

extension View {
    func appShadow(_ shadow: AppShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, y: shadow.y)
    }

    func sectionHeaderStyle() -> some View {
        self
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(0.5)
    }
}

// MARK: - Press Button Style

/// Button style that scales down slightly on press for tactile feedback.
struct PressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressButtonStyle {
    static var press: PressButtonStyle { PressButtonStyle() }
}
