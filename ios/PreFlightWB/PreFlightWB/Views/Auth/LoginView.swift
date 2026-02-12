import SwiftUI
import AuthenticationServices
import GoogleSignIn

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss

    // MARK: - Email Flow State Machine

    enum EmailState: Equatable {
        case idle
        case enterEmail
        case enterCode
    }

    @State private var emailState: EmailState = .idle
    @State private var email = ""
    @State private var code = ""
    @State private var isLoading = false

    // Hidden text field backing for digit boxes
    @FocusState private var codeFieldFocused: Bool

    // MARK: - Gradient colors

    private let navyBlue = Color(red: 0.106, green: 0.157, blue: 0.220)   // #1B2838
    private let aviationBlue = Color(red: 0.145, green: 0.388, blue: 0.922) // #2563EB

    var body: some View {
        ZStack {
            // Gradient background matching landing page
            LinearGradient(
                colors: [navyBlue, aviationBlue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 60)

                    // MARK: - Header Icon
                    Image(systemName: "scalemass")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.bottom, Spacing.md)

                    // MARK: - Title
                    Text("Sign In")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.bottom, Spacing.xs)

                    // MARK: - Subtitle
                    Text("Sign in to save scenarios and sync across your devices.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300)
                        .padding(.bottom, Spacing.xl)

                    // MARK: - Auth Card
                    VStack(spacing: Spacing.lg) {
                        // Apple Sign-In
                        appleSignInButton

                        // Google Sign-In (only if configured)
                        if isGoogleConfigured {
                            googleSignInButton
                        }

                        // Divider
                        orDivider

                        // Email / Code Section
                        emailSection

                        // Error display
                        if let errorText = authManager.error {
                            Text(errorText)
                                .font(.caption)
                                .foregroundStyle(Color.statusDanger)
                                .multilineTextAlignment(.center)
                                .transition(.opacity)
                        }
                    }
                    .padding(Spacing.lg)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
                    .padding(.horizontal, Spacing.lg)

                    // MARK: - Guest Button
                    guestButton
                        .padding(.top, Spacing.xl)

                    // MARK: - Guest Disclaimer
                    Text("Guest mode works fully offline but scenarios won\u{2019}t be saved or synced across devices.")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.2))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 280)
                        .padding(.top, Spacing.md)

                    Spacer()
                        .frame(height: Spacing.xxl)
                }
                .frame(maxWidth: 400)
                .padding(.horizontal, Spacing.lg)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarBackButtonHidden(false)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Apple Sign-In Button

    @State private var appleSignInDelegate: AppleSignInDelegate?

    private var appleSignInButton: some View {
        Button {
            performAppleSignIn()
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "apple.logo")
                    .font(.title3)
                Text("Sign in with Apple")
                    .font(.body)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1)
    }

    private func performAppleSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        let delegate = AppleSignInDelegate { result in
            handleAppleSignIn(result)
        }
        appleSignInDelegate = delegate
        controller.delegate = delegate
        controller.performRequests()
    }

    // MARK: - Google Sign-In Button

    private var googleSignInButton: some View {
        Button {
            handleGoogleSignIn()
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "g.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.statusInfo, Color.statusInfo.opacity(0.2))

                Text("Sign in with Google")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1)
    }

    // MARK: - Or Divider

    private var orDivider: some View {
        HStack(spacing: Spacing.sm) {
            Rectangle()
                .fill(.white.opacity(0.4))
                .frame(height: 1)
            Text("or")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
            Rectangle()
                .fill(.white.opacity(0.4))
                .frame(height: 1)
        }
    }

    // MARK: - Email Section

    private var emailSection: some View {
        VStack(spacing: Spacing.sm) {
            switch emailState {
            case .idle:
                // Show "Sign in with Email" button
                Button {
                    withAnimation(.spring()) {
                        emailState = .enterEmail
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "envelope")
                            .font(.body)
                        Text("Sign in with Email")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.md)
                            .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

            case .enterEmail:
                emailInputView
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity.combined(with: .move(edge: .leading))
                    ))

            case .enterCode:
                codeInputView
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity.combined(with: .move(edge: .leading))
                    ))
            }
        }
        .animation(.spring(), value: emailState)
    }

    // MARK: - Email Input

    private var emailInputView: some View {
        VStack(spacing: Spacing.sm) {
            TextField("Email address", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.body)
                .foregroundStyle(.white)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 14)
                .background(.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                )
                .disabled(isLoading)

            Button {
                Task { await handleSendCode() }
            } label: {
                Group {
                    if isLoading {
                        HStack(spacing: Spacing.xs) {
                            ProgressView()
                                .tint(.white)
                            Text("Sending...")
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                    } else {
                        Text("Send Sign-In Code")
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(email.trimmingCharacters(in: .whitespaces).isEmpty || isLoading
                            ? Color.statusInfo.opacity(0.4)
                            : Color.statusInfo)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            }
            .buttonStyle(.press)
            .disabled(email.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
        }
    }

    // MARK: - Code Input (Individual Digit Boxes)

    private var codeInputView: some View {
        VStack(spacing: Spacing.sm) {
            Text("We sent a 6-digit code to ")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
            + Text(email)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.7))

            // Individual digit boxes
            ZStack {
                // Hidden TextField that captures input
                TextField("", text: $code)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .focused($codeFieldFocused)
                    .opacity(0.01) // Nearly invisible but still functional
                    .frame(width: 1, height: 1)
                    .onChange(of: code) { _, newValue in
                        let filtered = newValue.filter(\.isNumber)
                        if filtered.count > 6 {
                            code = String(filtered.prefix(6))
                        } else if filtered != newValue {
                            code = filtered
                        }
                    }

                // Digit display boxes
                HStack(spacing: Spacing.xs) {
                    ForEach(0..<6, id: \.self) { index in
                        digitBox(at: index)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    codeFieldFocused = true
                }
            }
            .onAppear {
                codeFieldFocused = true
            }

            Button {
                Task { await handleVerifyCode() }
            } label: {
                Group {
                    if isLoading {
                        HStack(spacing: Spacing.xs) {
                            ProgressView()
                                .tint(.white)
                            Text("Verifying...")
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                    } else {
                        Text("Verify Code")
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(code.count != 6 || isLoading
                            ? Color.statusInfo.opacity(0.4)
                            : Color.statusInfo)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            }
            .buttonStyle(.press)
            .disabled(code.count != 6 || isLoading)

            Button {
                withAnimation(.spring()) {
                    emailState = .enterEmail
                    code = ""
                }
            } label: {
                Text("Use a different email")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.3))
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
        }
    }

    // MARK: - Digit Box

    private func digitBox(at index: Int) -> some View {
        let characters = Array(code)
        let character = index < characters.count ? String(characters[index]) : ""

        return Text(character)
            .font(.system(size: 22, weight: .bold, design: .monospaced))
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .strokeBorder(
                        index == characters.count
                            ? Color.statusInfo.opacity(0.8)
                            : .white.opacity(0.15),
                        lineWidth: index == characters.count ? 2 : 1
                    )
            )
    }

    // MARK: - Guest Button

    private var guestButton: some View {
        Button {
            authManager.continueAsGuest()
        } label: {
            Text("Continue without account")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }

    // MARK: - Actions

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityTokenData = credential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                return
            }
            Task {
                await authManager.loginWithApple(
                    identityToken: identityToken,
                    appleUserId: credential.user,
                    fullName: credential.fullName
                )
            }
        case .failure(let error):
            let asError = error as? ASAuthorizationError
            // Silently ignore canceled, unknown (1000), and not-available errors
            // to prevent render loops when Sign in with Apple isn't configured.
            let silentCodes: [ASAuthorizationError.Code] = [.canceled, .unknown, .notHandled]
            if let code = asError?.code, silentCodes.contains(code) {
                return
            }
            authManager.error = "Apple sign-in failed. Please try again."
        }
    }

    /// Whether Google Sign-In is configured with a client ID in Info.plist.
    private var isGoogleConfigured: Bool {
        Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String != nil
    }

    private func handleGoogleSignIn() {
        guard isGoogleConfigured else {
            authManager.error = "Google sign-in is not configured."
            return
        }
        Task {
            isLoading = true
            defer { isLoading = false }

            guard let windowScene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene }).first,
                  let rootVC = windowScene.windows.first?.rootViewController else {
                authManager.error = "Unable to present Google sign-in."
                return
            }

            do {
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
                guard let idToken = result.user.idToken?.tokenString else {
                    authManager.error = "Google sign-in failed. No ID token received."
                    return
                }
                await authManager.loginWithGoogle(idToken: idToken)
            } catch {
                if (error as NSError).code != GIDSignInError.canceled.rawValue {
                    authManager.error = "Google sign-in failed. Please try again."
                }
            }
        }
    }

    private func handleSendCode() async {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            try await authManager.sendEmailCode(email: email.trimmingCharacters(in: .whitespaces))
            withAnimation(.spring()) {
                emailState = .enterCode
            }
        } catch {
            // Error is already set on authManager
        }
    }

    private func handleVerifyCode() async {
        guard code.count == 6 else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            try await authManager.verifyEmailCode(
                email: email.trimmingCharacters(in: .whitespaces),
                code: code
            )
            // Auth state change will trigger ContentView to show the main app
        } catch {
            // Error is already set on authManager
        }
    }
}

// MARK: - Apple Sign-In Delegate

/// Bridges ASAuthorizationController delegate callbacks to a closure,
/// avoiding the SwiftUI SignInWithAppleButton which triggers auth checks on render.
private final class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate {
    private let completion: (Result<ASAuthorization, Error>) -> Void

    init(completion: @escaping (Result<ASAuthorization, Error>) -> Void) {
        self.completion = completion
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        completion(.success(authorization))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion(.failure(error))
    }
}
