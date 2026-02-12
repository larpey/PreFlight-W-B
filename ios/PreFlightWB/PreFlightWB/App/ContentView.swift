import SwiftUI

struct ContentView: View {
    @Environment(AuthManager.self) private var authManager

    // MARK: - Splash Animation State

    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var textOpacity: Double = 0

    var body: some View {
        Group {
            if authManager.isLoading {
                splashScreen
            } else if authManager.isAuthenticated || authManager.isGuest {
                NavigationStack {
                    AircraftSelectView()
                }
                .transition(.opacity)
            } else {
                LandingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: authManager.isLoading)
        .animation(.easeInOut(duration: 0.35), value: authManager.isAuthenticated)
        .animation(.easeInOut(duration: 0.35), value: authManager.isGuest)
        .task {
            await authManager.restoreSession()
        }
        .task {
            authManager.observeAppleRevocation()
        }
    }

    // MARK: - Splash Screen

    private var splashScreen: some View {
        ZStack {
            // Cockpit dark background
            Color.cockpitBackground.ignoresSafeArea()

            // Radial readoutBlue glow behind the icon
            RadialGradient(
                colors: [
                    Color.readoutBlue.opacity(0.3),
                    Color.readoutBlue.opacity(0.08),
                    Color.clear
                ],
                center: .center,
                startRadius: 10,
                endRadius: 180
            )
            .ignoresSafeArea()

            VStack(spacing: Spacing.md) {
                // Icon: 72pt scalemass with readoutBlue and glow shadow
                Image(systemName: "scalemass")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.readoutBlue)
                    .shadow(color: Color.readoutBlue.opacity(0.5), radius: 12, y: 0)
                    .shadow(color: Color.readoutBlue.opacity(0.25), radius: 24, y: 0)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)

                VStack(spacing: Spacing.xxs) {
                    // "PreFlight" in readoutWhite
                    Text("PreFlight")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.readoutWhite)

                    // "W&B" in readoutBlue
                    Text("W&B")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.readoutBlue)
                }
                .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                textOpacity = 1.0
            }
        }
    }
}
