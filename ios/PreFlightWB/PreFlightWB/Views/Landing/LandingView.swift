import SwiftUI

struct LandingView: View {
    @State private var disclaimerExpanded = false
    @State private var floatOffset: CGFloat = 0

    // Feature items matching the React landing page
    private let features: [(icon: String, title: String, desc: String)] = [
        ("scalemass", "Weight & Balance", "Real-time CG calculations with visual envelope chart"),
        ("airplane", "4 Aircraft", "Cessna 172M, Bonanza A36, Cherokee Six, Navajo Chieftain"),
        ("doc.text.magnifyingglass", "Sourced Data", "Every value traced to POH, TCDS, or FAA documents"),
        ("wifi.slash", "Works Offline", "All data bundled locally -- no network required on the ramp"),
    ]

    // MARK: - Gradient colors

    private let navyBlue = Color(red: 0.106, green: 0.157, blue: 0.220)   // #1B2838
    private let aviationBlue = Color(red: 0.145, green: 0.388, blue: 0.922) // #2563EB

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // MARK: - Hero Header
                    heroSection

                    // MARK: - Content
                    VStack(spacing: Spacing.lg) {
                        // Safety Disclaimer
                        disclaimerSection

                        // Features Grid
                        featuresSection

                        // CTA Button
                        ctaSection

                        // Footer
                        footerSection
                    }
                    .padding(.horizontal, Spacing.lg - 4) // 20pt
                    .padding(.bottom, Spacing.xxl - 8) // 40pt
                }
            }
            .background(Color.pfBackground)
            .ignoresSafeArea(edges: .top)
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        ZStack {
            // Deep gradient background
            LinearGradient(
                colors: [navyBlue, aviationBlue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: Spacing.sm) {
                Spacer()
                    .frame(height: 44)

                // Floating scale icon
                Image(systemName: "scalemass")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)
                    .offset(y: floatOffset)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 3.0)
                            .repeatForever(autoreverses: true)
                        ) {
                            floatOffset = -4
                        }
                    }

                // App name
                VStack(spacing: Spacing.xxs) {
                    Text("PreFlight")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                    Text("W&B")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white.opacity(0.8))
                }

                // Tagline
                Text("Weight & Balance with Source Transparency")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)

                // Version badge
                Text("v1.0.0")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.horizontal, 10)
                    .padding(.vertical, Spacing.xxs)
                    .background(.white.opacity(0.15))
                    .clipShape(Capsule())

                Spacer()
                    .frame(height: 30)
            }
            .padding(.horizontal, Spacing.lg - 4)
        }
        .frame(height: 310)
    }

    // MARK: - Disclaimer Section

    private var disclaimerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Tappable header
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    disclaimerExpanded.toggle()
                }
                Haptic.light()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.statusCaution)
                        .font(.body)
                    Text("Safety Disclaimer")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.statusCaution)
                    Spacer()
                    Image(systemName: disclaimerExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(Color.statusCaution.opacity(0.7))
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            // Abbreviated text always shown
            Text("This calculator is a **supplemental planning tool only**. It does not replace the official Pilot\u{2019}s Operating Handbook.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, disclaimerExpanded ? Spacing.xs : 14)

            // Expanded details
            if disclaimerExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Per **14 CFR 91.103**, the pilot in command is solely responsible for determining the aircraft is within approved weight and balance limits before each flight.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("Always verify against your aircraft\u{2019}s actual empty weight, CG, and most recent weight & balance record.")
                        .font(.caption)
                        .foregroundStyle(.secondary.opacity(0.7))
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.statusCaution.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.statusCaution.opacity(0.2), lineWidth: 1)
        )
        .padding(.top, -Spacing.xs)
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
            ForEach(features, id: \.title) { feature in
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Image(systemName: feature.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(Color.statusInfo)

                    Text(feature.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.pfText)

                    Text(feature.desc)
                        .font(.caption)
                        .foregroundStyle(Color.pfTextSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard()
            }
        }
    }

    // MARK: - CTA Section

    private var ctaSection: some View {
        NavigationLink {
            LoginView()
        } label: {
            HStack(spacing: Spacing.xs) {
                Text("Get Started")
                    .font(.headline)
                Image(systemName: "arrow.right")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(Color.statusInfo)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .appShadow(.medium)
        }
        .buttonStyle(.press)
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        VStack(spacing: Spacing.xs) {
            Divider()
                .padding(.bottom, Spacing.xxs)

            Text("Not for flight planning. Always verify with your aircraft\u{2019}s actual W&B records.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
    }
}
