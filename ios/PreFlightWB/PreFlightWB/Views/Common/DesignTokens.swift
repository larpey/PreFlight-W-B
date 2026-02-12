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

    // MARK: - Cockpit Instrument Panel Colors (always dark, do not adapt)

    /// Deep dark background for operational screens
    static let cockpitBackground = Color(red: 0.067, green: 0.078, blue: 0.102)           // #111420
    /// Card/surface background on cockpit screens
    static let cockpitSurface = Color(red: 0.098, green: 0.114, blue: 0.145)              // #191D25
    /// Elevated surface on cockpit screens
    static let cockpitSurfaceElevated = Color(red: 0.133, green: 0.153, blue: 0.192)      // #222731
    /// Borders, slider tracks, dividers on cockpit screens
    static let cockpitBezel = Color(red: 0.176, green: 0.196, blue: 0.243)                // #2D323E

    /// Glowing readout for safe/within limits
    static let readoutGreen = Color(red: 0.0, green: 1.0, blue: 0.65)                     // #00FFA6
    /// Glowing readout for caution/approaching limits
    static let readoutAmber = Color(red: 1.0, green: 0.749, blue: 0.0)                    // #FFBF00
    /// Glowing readout for danger/exceeds limits
    static let readoutRed = Color(red: 1.0, green: 0.318, blue: 0.318)                    // #FF5151
    /// Neutral data readout on cockpit screens
    static let readoutWhite = Color(red: 0.878, green: 0.910, blue: 0.965)                // #E0E8F6
    /// Interactive/accent color on cockpit screens
    static let readoutBlue = Color(red: 0.314, green: 0.620, blue: 1.0)                   // #509EFF

    /// Secondary labels on cockpit screens
    static let cockpitLabel = Color(red: 0.502, green: 0.549, blue: 0.639)                // #808CA3
    /// Tertiary/dimmed labels on cockpit screens
    static let cockpitLabelDim = Color(red: 0.337, green: 0.376, blue: 0.463)             // #566076
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
    static let xxxl: CGFloat = 64

    // Touch target minimums (aviation/glove-safe)
    static let touchMinimum: CGFloat = 44
    static let touchPreferred: CGFloat = 48
    static let touchLarge: CGFloat = 56
}

// MARK: - Corner Radius Scale

enum CornerRadius {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
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

// MARK: - Instrument Font Presets

enum InstrumentFont {
    /// Primary data readout (total weight, CG position) — 42pt
    static let readoutLarge: Font = .system(size: 42, weight: .bold, design: .rounded)
    /// Gauge center readout — 28pt
    static let readoutMedium: Font = .system(size: 28, weight: .semibold, design: .rounded)
    /// Station/fuel weight values — 20pt
    static let readoutSmall: Font = .system(size: 20, weight: .semibold, design: .monospaced)
    /// Labels above readouts (WEIGHT, CG) — 11pt
    static let readoutLabel: Font = .system(size: 11, weight: .medium)
    /// Unit suffixes (lbs, in) — 14pt
    static let readoutUnit: Font = .system(size: 14, weight: .regular)
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

    /// Cockpit instrument card: dark surface bg with bezel border.
    func instrumentCard() -> some View {
        self
            .padding(Spacing.md)
            .background(Color.cockpitSurface)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .strokeBorder(Color.cockpitBezel, lineWidth: 1)
            )
            .appShadow(.medium)
    }

    /// Glowing text effect for critical instrument readout values.
    func glowingReadout(color: Color) -> some View {
        self
            .foregroundStyle(color)
            .shadow(color: color.opacity(0.5), radius: 8, y: 0)
            .shadow(color: color.opacity(0.25), radius: 16, y: 0)
    }

    /// Forces dark color scheme with cockpit background on operational screens.
    func cockpitEnvironment() -> some View {
        self
            .preferredColorScheme(.dark)
            .background(Color.cockpitBackground.ignoresSafeArea())
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
