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
            Color.statusInfo.ignoresSafeArea()

            VStack(spacing: Spacing.md) {
                Image(systemName: "scalemass")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)

                VStack(spacing: Spacing.xxs) {
                    Text("PreFlight")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    Text("W&B")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.8))
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
