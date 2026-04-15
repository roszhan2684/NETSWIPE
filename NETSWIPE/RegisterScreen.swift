////
////  RegisterScreen.swift
////  NETSWIPE_1.0
////
////  Created by ROSZHAN RAJ on 22/09/25.
////
//
//import SwiftUI
//
//struct RegisterScreen: View {
//    @Binding var likedProfiles: [Profile]
//    @Binding var isLoggedIn: Bool
//
//    @State private var email = ""
//    @State private var username = ""
//    @State private var password = ""
//    @State private var confirm = ""
//    @State private var otp = ""
//    @State private var error: String?
//
//    @State private var step: Int = 1   // 1=form, 2=otp, 3=login
//    @State private var canResend = true
//    @State private var resendCountdown = 60
//    @State private var timer: Timer?
//
//    @StateObject private var viewModel = AuthViewModel()
//
//    var body: some View {
//        ZStack {
//            RadialGradient(
//                gradient: Gradient(colors: [
//                    Color(red: 0.95, green: 0.35, blue: 0.1),
//                    Color(red: 0.2, green: 0.0, blue: 0.0)
//                ]),
//                center: .center,
//                startRadius: 80,
//                endRadius: 600
//            )
//            .ignoresSafeArea()
//
//            VStack(spacing: 24) {
//                Spacer(minLength: 40)
//
//                Text(step == 1 ? "Create an Account" :
//                     step == 2 ? "Verify OTP" : "Login")
//                    .font(.largeTitle.bold())
//                    .foregroundColor(.white)
//                    .shadow(radius: 5)
//
//                // ----------------------------------------------------
//                // STEP 1 – Registration
//                // ----------------------------------------------------
//                if step == 1 {
//                    formField("Email", text: $email)
//                    formField("Username", text: $username)
//                    formSecure("Password", text: $password)
//                    formSecure("Confirm Password", text: $confirm)
//
//                    if let error { Text(error).foregroundColor(.red).font(.footnote) }
//
//                    depthButton("Submit", colors: [Color.purple, Color.blue]) {
//                        guard !email.isEmpty, !username.isEmpty,
//                              !password.isEmpty, !confirm.isEmpty else {
//                            error = "Please fill all fields"; return
//                        }
//                        guard password == confirm else {
//                            error = "Passwords do not match"; return
//                        }
//                        error = nil
//
//                        viewModel.register(email: email, username: username, password: password) { success, message in
//                            if success {
//                                step = 2
//                            } else {
//                                error = message // "Email already registered" etc.
//                            }
//                        }
//                    }
//
//                // ----------------------------------------------------
//                // STEP 2 – OTP Verification
//                // ----------------------------------------------------
//                } else if step == 2 {
//                    VStack(spacing: 12) {
//                        Text("Enter the 6-digit code sent to your email")
//                            .foregroundColor(.white.opacity(0.8))
//                            .font(.subheadline)
//
//                        TextField("123456", text: $otp)
//                            .textFieldStyle(.roundedBorder)
//                            .multilineTextAlignment(.center)
//                            .keyboardType(.numberPad)
//                            .padding(.horizontal)
//                    }
//
//                    if let error { Text(error).foregroundColor(.red).font(.footnote) }
//
//                    // Verify button
//                    depthButton("Verify & Continue", colors: [Color.green, Color.teal]) {
//                        guard otp.count == 6 else {
//                            error = "OTP must be 6 digits"; return
//                        }
//                        error = nil
//                        viewModel.verify(email: email, otp: otp)
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                            if viewModel.isVerified { step = 3 }
//                            else { error = viewModel.message }
//                        }
//                    }
//
//                    // Resend-OTP section
//                    if !canResend {
//                        Text("Resend available in \(resendCountdown)s")
//                            .font(.caption)
//                            .foregroundColor(.white.opacity(0.7))
//                    } else {
//                        Button("Resend OTP") {
//                            canResend = false
//                            viewModel.resendOtp(email: email)
//                            startCountdown()
//                        }
//                        .font(.callout.bold())
//                        .padding(.top, 6)
//                        .disabled(!canResend)
//                    }
//
//                // ----------------------------------------------------
//                // STEP 3 – Login
//                // ----------------------------------------------------
//                } else if step == 3 {
//                    LoginScreen(likedProfiles: $likedProfiles, isLoggedIn: $isLoggedIn)
//                }
//
//                if !viewModel.message.isEmpty {
//                    Text(viewModel.message)
//                        .foregroundColor(.white)
//                        .font(.footnote)
//                        .padding(.top, 8)
//                }
//
//                Spacer()
//            }
//            .padding()
//        }
//        .animation(.easeInOut, value: step)
//    }
//
//    // ----------------------------------------------------
//    // Helper UI
//    // ----------------------------------------------------
//    private func formField(_ placeholder: String, text: Binding<String>) -> some View {
//        TextField(placeholder, text: text)
//            .padding()
//            .background(Color.white.opacity(0.15))
//            .cornerRadius(10)
//            .foregroundColor(.white)
//            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.3)))
//            .padding(.horizontal)
//    }
//
//    private func formSecure(_ placeholder: String, text: Binding<String>) -> some View {
//        SecureField(placeholder, text: text)
//            .padding()
//            .background(Color.white.opacity(0.15))
//            .cornerRadius(10)
//            .foregroundColor(.white)
//            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.3)))
//            .padding(.horizontal)
//    }
//
//    private func depthButton(_ title: String, colors: [Color], action: @escaping () -> Void) -> some View {
//        Button(action: action) {
//            Text(title)
//                .foregroundColor(.white)
//                .fontWeight(.semibold)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(
//                    LinearGradient(
//                        gradient: Gradient(colors: colors),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//                .cornerRadius(14)
//                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 6)
//        }
//        .padding(.horizontal)
//    }
//
//    // ----------------------------------------------------
//    // Countdown logic
//    // ----------------------------------------------------
//    private func startCountdown() {
//        resendCountdown = 60
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            if resendCountdown > 0 {
//                resendCountdown -= 1
//            } else {
//                canResend = true
//                timer?.invalidate()
//            }
//        }
//    }
//}
//
//  RegisterScreen.swift
//  NETSWIPE_1.0
//
//  Created by ROSZHAN RAJ on 22/09/25.
//

import SwiftUI

struct RegisterScreen: View {
    @Binding var likedProfiles: [Profile]
    @Binding var isLoggedIn: Bool

    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirm = ""
    @State private var otp = ""
    @State private var error: String?

    @State private var step: Int = 1   // 1 = Register, 2 = OTP Verify, 3 = Login
    @State private var canResend = true
    @State private var resendCountdown = 60
    @State private var timer: Timer?

    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.35, blue: 0.1),
                    Color(red: 0.2, green: 0.0, blue: 0.0)
                ]),
                center: .center,
                startRadius: 80,
                endRadius: 600
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer(minLength: 40)

                Text(step == 1 ? "Create an Account" :
                     step == 2 ? "Verify OTP" :
                     "Login")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .shadow(radius: 5)

                // ----------------------------------------------------
                // STEP 1 – Registration
                // ----------------------------------------------------
                if step == 1 {
                    formField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    formField("Username", text: $username)
                    formSecure("Password", text: $password)
                    formSecure("Confirm Password", text: $confirm)

                    if let error { Text(error).foregroundColor(.red).font(.footnote) }

                    depthButton("Submit", colors: [Color.purple, Color.blue]) {
                        guard !email.isEmpty, !username.isEmpty,
                              !password.isEmpty, !confirm.isEmpty else {
                            error = "Please fill all fields"
                            return
                        }
                        guard password == confirm else {
                            error = "Passwords do not match"
                            return
                        }

                        // ✅ Normalize email
                        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

                        error = nil
                        viewModel.register(email: normalizedEmail, username: username, password: password) { success, message in
                            if success {
                                step = 2
                            } else {
                                error = message // "Email already registered", etc.
                            }
                        }
                    }

                // ----------------------------------------------------
                // STEP 2 – OTP Verification
                // ----------------------------------------------------
                } else if step == 2 {
                    VStack(spacing: 12) {
                        Text("Enter the 6-digit code sent to your email")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.subheadline)
                            .multilineTextAlignment(.center)

                        TextField("123456", text: $otp)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .padding(.horizontal)
                            .onChange(of: otp) { newValue in
                                // limit OTP length
                                if newValue.count > 6 {
                                    otp = String(newValue.prefix(6))
                                }
                            }
                    }

                    if let error { Text(error).foregroundColor(.red).font(.footnote) }

                    // ✅ Verify OTP
                    depthButton("Verify & Continue", colors: [Color.green, Color.teal]) {
                        guard otp.count == 6 else {
                            error = "OTP must be 6 digits"
                            return
                        }
                        error = nil
                        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                        viewModel.verify(email: normalizedEmail, otp: otp)

                        // Slight delay for backend response
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            if viewModel.isVerified {
                                step = 3
                            } else {
                                error = viewModel.message
                            }
                        }
                    }

                    // ✅ Resend OTP section
                    if !canResend {
                        Text("Resend available in \(resendCountdown)s")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        Button("Resend OTP") {
                            canResend = false
                            let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                            viewModel.resendOtp(email: normalizedEmail)
                            startCountdown()
                        }
                        .font(.callout.bold())
                        .padding(.top, 6)
                        .disabled(!canResend)
                    }

                // ----------------------------------------------------
                // STEP 3 – Login
                // ----------------------------------------------------
                } else if step == 3 {
                    LoginScreen(likedProfiles: $likedProfiles, isLoggedIn: $isLoggedIn)
                }

                if !viewModel.message.isEmpty {
                    Text(viewModel.message)
                        .foregroundColor(.white)
                        .font(.footnote)
                        .padding(.top, 8)
                }

                Spacer()
            }
            .padding()
        }
        .animation(.easeInOut, value: step)
    }

    // ----------------------------------------------------
    // MARK: - Helper UI
    // ----------------------------------------------------
    private func formField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
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

    // ----------------------------------------------------
    // MARK: - Resend OTP Countdown Logic
    // ----------------------------------------------------
    private func startCountdown() {
        resendCountdown = 60
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if resendCountdown > 0 {
                resendCountdown -= 1
            } else {
                canResend = true
                timer?.invalidate()
            }
        }
    }
}
