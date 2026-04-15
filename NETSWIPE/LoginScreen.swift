//
//  LoginScreen.swift
//  NetSwipe
//
//  Updated for crash-free login with proper async handling
//

import SwiftUI

struct LoginScreen: View {
    @Binding var likedProfiles: [Profile]
    @Binding var isLoggedIn: Bool

    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var error: String?
    @State private var isLoading = false

    var body: some View {
        ZStack {
            // 🔥 Background gradient
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.35, blue: 0.1),
                    Color(red: 0.15, green: 0.0, blue: 0.0)
                ]),
                center: .center,
                startRadius: 80,
                endRadius: 600
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer(minLength: 40)

                Text("Welcome to NetSwipe")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .shadow(radius: 5)

                VStack(spacing: 16) {
                    formField("Email", text: $email)
                    formSecure("Password", text: $password)

                    if let error {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }

                // MARK: - Login Button
                depthButton(isLoading ? "Logging in..." : "Login",
                            colors: [Color.blue, Color.purple]) {
                    handleLogin()
                }
                .disabled(isLoading)

                NavigationLink {
                    RegisterScreen(likedProfiles: $likedProfiles, isLoggedIn: $isLoggedIn)
                } label: {
                    Text("Don’t have an account? Register")
                        .foregroundColor(.white)
                        .underline()
                }
                .padding(.top, 8)

                if !authViewModel.message.isEmpty {
                    Text(authViewModel.message)
                        .foregroundColor(.white.opacity(0.8))
                        .font(.footnote)
                        .padding(.top, 4)
                }

                Spacer()
            }
            .padding()
        }
    }

    // MARK: - Login Logic
    private func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            error = "Please enter your credentials"
            return
        }

        error = nil
        isLoading = true

        // ✅ Clear any old session data first
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userId")

        // ✅ Call the backend login
        authViewModel.login(email: email, password: password)

        // ✅ Wait for ViewModel to update safely using a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isLoading = false

            if authViewModel.isLoggedIn {
                if let userId = UserDefaults.standard.string(forKey: "userId") {
                    print("✅ Logged in as userId:", userId)
                } else {
                    print("⚠️ No userId found in defaults after login.")
                }

                isLoggedIn = true // triggers transition to ProfileSetupScreen
            } else {
                error = authViewModel.message.isEmpty ? "Login failed. Please try again." : authViewModel.message
            }
        }
    }

    // MARK: - Reusable Field UI
    private func formField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .autocapitalization(.none)
            .textInputAutocapitalization(.never)
            .padding()
            .background(Color.white.opacity(0.15))
            .cornerRadius(10)
            .foregroundColor(.white)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.3)))
            .padding(.horizontal)
    }

    private func formSecure(_ placeholder: String, text: Binding<String>) -> some View {
        SecureField(placeholder, text: text)
            .padding()
            .background(Color.white.opacity(0.15))
            .cornerRadius(10)
            .foregroundColor(.white)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.3)))
            .padding(.horizontal)
    }

    // MARK: - Gradient Button
    private func depthButton(_ title: String, colors: [Color], action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: colors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 6)
        }
        .padding(.horizontal)
    }
}
