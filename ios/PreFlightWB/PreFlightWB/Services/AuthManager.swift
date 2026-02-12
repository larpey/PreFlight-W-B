import Foundation
import Observation
import AuthenticationServices

// MARK: - User

struct AppUser: Codable, Sendable {
    let id: String
    let email: String
    let name: String
    let avatarUrl: String?
}

// MARK: - Auth Manager

/// Central auth state, shared via @Environment. Uses iOS 17 @Observable.
@MainActor @Observable
final class AuthManager {

    // MARK: - Published State

    private(set) var currentUser: AppUser?
    private(set) var isAuthenticated = false
    private(set) var isGuest = false
    private(set) var isLoading = true

    /// Non-nil when the most recent auth action failed.
    var error: String?

    /// Called after successful authentication to trigger sync.
    var onAuthenticated: (() async -> Void)?

    // MARK: - Keys

    private static let guestKey = "preflight_guest_mode"
    private static let userKey = "preflight_user"
    private static let appleAuthKey = "preflight_apple_auth"
    private static let appleUserIdKey = "preflight_apple_user_id"

    // MARK: - Session Restore

    /// Called once from ContentView.task to check for a persisted session.
    func restoreSession() async {
        defer { isLoading = false }

        // Check for guest mode first
        if UserDefaults.standard.bool(forKey: Self.guestKey) {
            isGuest = true
            return
        }

        // Check for a stored token and user
        guard KeychainHelper.loadToken() != nil,
              let userData = UserDefaults.standard.data(forKey: Self.userKey),
              let user = try? JSONDecoder().decode(AppUser.self, from: userData)
        else {
            return
        }

        currentUser = user
        isAuthenticated = true
        await onAuthenticated?()

        // Check Apple credential state if session was established via Apple Sign-In
        if UserDefaults.standard.bool(forKey: Self.appleAuthKey),
           let appleUserId = UserDefaults.standard.string(forKey: Self.appleUserIdKey) {
            let provider = ASAuthorizationAppleIDProvider()
            let state = try? await provider.credentialState(forUserID: appleUserId)
            if state == .revoked {
                signOut()
                return
            }
        }
    }

    // MARK: - Google Sign-In

    /// Exchange a Google id-token for an app session.
    func loginWithGoogle(idToken: String) async {
        error = nil
        do {
            struct GoogleAuthRequest: Encodable {
                let idToken: String
            }
            struct AuthResponse: Decodable {
                let token: String
                let user: AppUser
            }

            let response: AuthResponse = try await APIClient.shared.fetch(
                "/auth/google",
                method: "POST",
                body: GoogleAuthRequest(idToken: idToken)
            )

            try KeychainHelper.saveToken(response.token)
            persistUser(response.user)
            currentUser = response.user
            isAuthenticated = true
            isGuest = false
            await onAuthenticated?()
        } catch {
            self.error = "Google sign-in failed. Please try again."
        }
    }

    // MARK: - Apple Sign-In

    /// Exchange an Apple identity token for an app session.
    func loginWithApple(identityToken: String, appleUserId: String, fullName: PersonNameComponents?) async {
        error = nil
        do {
            struct AppleAuthRequest: Encodable {
                let identityToken: String
                let fullName: FullName?
                struct FullName: Encodable {
                    let givenName: String?
                    let familyName: String?
                }
            }
            struct AuthResponse: Decodable {
                let token: String
                let user: AppUser
            }

            let namePayload: AppleAuthRequest.FullName? = fullName.map {
                .init(givenName: $0.givenName, familyName: $0.familyName)
            }

            let response: AuthResponse = try await APIClient.shared.fetch(
                "/auth/apple",
                method: "POST",
                body: AppleAuthRequest(identityToken: identityToken, fullName: namePayload)
            )

            try KeychainHelper.saveToken(response.token)
            persistUser(response.user)
            currentUser = response.user
            isAuthenticated = true
            isGuest = false
            UserDefaults.standard.set(true, forKey: Self.appleAuthKey)
            UserDefaults.standard.set(appleUserId, forKey: Self.appleUserIdKey)
            await onAuthenticated?()
        } catch {
            self.error = "Apple sign-in failed. Please try again."
        }
    }

    // MARK: - Email + Code

    /// Request a 6-digit sign-in code for the given email address.
    func sendEmailCode(email: String) async throws {
        error = nil
        struct EmailRequest: Encodable {
            let email: String
        }
        do {
            try await APIClient.shared.send(
                "/auth/magic-link",
                method: "POST",
                body: EmailRequest(email: email)
            )
        } catch {
            self.error = "Failed to send code. Please try again."
            throw error
        }
    }

    /// Verify the 6-digit code and establish a session.
    func verifyEmailCode(email: String, code: String) async throws {
        error = nil
        struct VerifyRequest: Encodable {
            let email: String
            let code: String
        }
        struct AuthResponse: Decodable {
            let token: String
            let user: AppUser
        }
        do {
            let response: AuthResponse = try await APIClient.shared.fetch(
                "/auth/verify",
                method: "POST",
                body: VerifyRequest(email: email, code: code)
            )

            try KeychainHelper.saveToken(response.token)
            persistUser(response.user)
            currentUser = response.user
            isAuthenticated = true
            isGuest = false
            await onAuthenticated?()
        } catch {
            self.error = "Invalid or expired code. Please try again."
            throw error
        }
    }

    // MARK: - Guest

    /// Enter the app without an account.
    func continueAsGuest() {
        error = nil
        UserDefaults.standard.set(true, forKey: Self.guestKey)
        isGuest = true
        isAuthenticated = false
        currentUser = nil
    }

    // MARK: - Sign Out

    func signOut() {
        KeychainHelper.deleteToken()
        UserDefaults.standard.removeObject(forKey: Self.userKey)
        UserDefaults.standard.removeObject(forKey: Self.guestKey)
        UserDefaults.standard.removeObject(forKey: Self.appleAuthKey)
        UserDefaults.standard.removeObject(forKey: Self.appleUserIdKey)
        currentUser = nil
        isAuthenticated = false
        isGuest = false
        error = nil
    }

    // MARK: - Apple Credential Revocation

    /// Listen for Apple credential revocation.
    func observeAppleRevocation() {
        NotificationCenter.default.addObserver(
            forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.signOut()
        }
    }

    // MARK: - Helpers

    private func persistUser(_ user: AppUser) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: Self.userKey)
        }
    }
}
