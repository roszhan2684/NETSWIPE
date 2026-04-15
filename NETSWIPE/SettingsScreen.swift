//
//  SettingsScreen.swift
//  NETSWIPE
//
//  Created by ROSZHAN RAJ on 22/11/25.
//

//
//  SettingsScreen.swift
//  NetSwipe
//
//  Settings page:
//  1) About NETSWIPE
//  2) Logout
//  3) Delete Profile (2-step confirm + backend delete + full local reset)
//  4) Privacy Policy (industry-standard)
//
//  NOTE: Logout does NOT clear swipe history.
//        Delete Profile clears EVERYTHING.
//

import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var isLoggedIn: Bool

    @AppStorage("hasSetupProfile") private var hasSetupProfile: Bool = false

    // Alert controls
    @State private var showAbout = false
    @State private var showPrivacy = false

    @State private var showDeleteStep1 = false
    @State private var showDeleteStep2 = false
    @State private var isDeleting = false
    @State private var deleteError: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                background

                VStack(spacing: 18) {
                    header

                    VStack(spacing: 12) {

                        // ABOUT
                        settingsRow(
                            icon: "info.circle.fill",
                            title: "About NETSWIPE",
                            subtitle: "What we do and why we built it"
                        ) {
                            showAbout = true
                        }

                        // PRIVACY POLICY
                        settingsRow(
                            icon: "hand.raised.fill",
                            title: "Privacy Policy",
                            subtitle: "How NETSWIPE handles your data"
                        ) {
                            showPrivacy = true
                        }

                        // LOGOUT
                        settingsRow(
                            icon: "arrowshape.turn.up.left.fill",
                            title: "Logout",
                            subtitle: "Sign out of this device",
                            tint: .red
                        ) {
                            logoutOnly()
                        }

                        // DELETE PROFILE
                        settingsRow(
                            icon: "trash.fill",
                            title: "Delete Profile",
                            subtitle: "Permanently remove account & data",
                            tint: .red
                        ) {
                            showDeleteStep1 = true
                        }
                    }
                    .padding(.horizontal, 16)

                    if isDeleting {
                        ProgressView("Deleting your profile…")
                            .foregroundColor(.white)
                            .padding(.top, 6)
                    }

                    if let deleteError {
                        Text(deleteError)
                            .foregroundColor(.white.opacity(0.9))
                            .font(.footnote)
                            .padding(.top, 4)
                    }

                    Spacer()
                }
                .padding(.top, 8)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAbout) { aboutSheet }
            .sheet(isPresented: $showPrivacy) { privacySheet }
            .alert("Delete your NETSWIPE profile?", isPresented: $showDeleteStep1) {
                Button("Cancel", role: .cancel) {}
                Button("Continue", role: .destructive) {
                    showDeleteStep2 = true
                }
            } message: {
                Text("This will remove your account from NETSWIPE. You can’t undo this.")
            }
            .alert("Final confirmation", isPresented: $showDeleteStep2) {
                Button("Cancel", role: .cancel) {}
                Button("Delete Forever", role: .destructive) {
                    deleteProfileForever()
                }
            } message: {
                Text("All your likes, matches, chats, and swipe history will be deleted.")
            }
        }
    }
}

// MARK: - UI
private extension SettingsScreen {

    var background: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.purple.opacity(0.95), Color.black]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Settings")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)

            Text("NETSWIPE")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 28)
    }

    func settingsRow(
        icon: String,
        title: String,
        subtitle: String,
        tint: Color = .white,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(tint)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.65))
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(14)
            .background(Color.white.opacity(0.08))
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Actions
private extension SettingsScreen {

    /// Logout should NOT clear swipe/match history.
    func logoutOnly() {
        withAnimation {
            isLoggedIn = false
            hasSetupProfile = false

            // clear auth only
            UserDefaults.standard.removeObject(forKey: "authToken")
            UserDefaults.standard.removeObject(forKey: "userId")

            // keep swipedProfileIds / likedProfileIds / restartSwipingNonce
        }
    }

    /// Delete profile on backend + wipe ALL local data.
    func deleteProfileForever() {
        guard let userId = authViewModel.profile?.id ?? UserDefaults.standard.string(forKey: "userId") else {
            deleteError = "No user ID found."
            return
        }

        isDeleting = true
        deleteError = nil

        authViewModel.deleteProfile(userId: userId) { success, msg in
            DispatchQueue.main.async {
                isDeleting = false
                if success {
                    withAnimation {
                        // Full nuke of local + persisted swipe state
                        authViewModel.fullLocalResetAfterDelete()

                        // drop session flags
                        isLoggedIn = false
                        hasSetupProfile = false
                    }
                } else {
                    deleteError = msg ?? "Delete failed."
                }
            }
        }
    }
}

// MARK: - About Sheet
private extension SettingsScreen {
    var aboutSheet: some View {
        ZStack {
            background.opacity(0.98)
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("About NETSWIPE")
                        .font(.title.bold())
                        .foregroundColor(.white)

                    Text("""
NETSWIPE is a swipe-based professional and personal networking platform designed to help people discover meaningful connections.

We combine:
• Fast onboarding and profile setup  
• Interest-based recommendations  
• Mutual-match chat access  
• A clean, gamified experience

Our goal is simple: help you connect with people you genuinely want to know.
""")
                    .foregroundColor(.white.opacity(0.9))
                    .font(.body)

                    Spacer(minLength: 30)
                }
                .padding(22)
            }
        }
    }
}

// MARK: - Privacy Policy Sheet
private extension SettingsScreen {
    var privacySheet: some View {
        ZStack {
            background.opacity(0.98)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Privacy Policy")
                        .font(.title.bold())
                        .foregroundColor(.white)

                    Text("Last updated: \(Date().formatted(date: .abbreviated, time: .omitted))")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.caption)

                    Text("""
NETSWIPE (“we”, “our”, or “us”) respects your privacy. This Privacy Policy describes how NETSWIPE collects, uses, shares, and protects your information when you use the NETSWIPE mobile application and related services (the “Service”).

1. Information We Collect
• Account Information: email, username, password (stored securely as a hash), verification status.
• Profile Information: name, bio, interests, location, and profile photo.
• Usage Data: swipes (likes/dislikes), matches, chat metadata, and app interactions to improve recommendations and performance.
• Device/Log Data: IP address, device type, OS version, crash logs, and diagnostics.

2. How We Use Your Information
We use your information to:
• Create and manage your account.
• Display your profile to other users.
• Power matching and interest-based recommendations.
• Enable chat between mutual matches.
• Improve safety, quality, and user experience.
• Communicate important updates about the Service.

3. How We Share Information
We do not sell your personal data.
We may share:
• With other users: your profile information you choose to provide (name, bio, interests, photo, location).
• With service providers: hosting, analytics, email/OTP delivery, and infrastructure providers who help run NETSWIPE.
• For legal/safety reasons: if required to comply with law or protect users and the platform.

4. Data Retention
We retain data while your account is active. If you delete your account, we delete your profile, swipe history, likes, matches, and chats from our active systems within a reasonable period, unless required to keep certain records by law.

5. Security
We use industry-standard measures to protect your data, including secure transport (HTTPS), access controls, and password hashing. No method of electronic storage is 100% secure, but we work hard to safeguard your information.

6. Your Choices
• You may edit your profile at any time.
• You may log out of the Service.
• You may permanently delete your account from Settings. This removes your profile and associated data.

7. Children’s Privacy
NETSWIPE is not intended for users under 13 (or the minimum age required in your jurisdiction). We do not knowingly collect data from children.

8. Changes to This Policy
We may update this Privacy Policy from time to time. Continued use of the Service after changes means you accept the updated policy.

9. Contact Us
If you have questions about privacy or data, contact:
NETSWIPE Support
Email: netswipe.app@gmail.com
""")
                    .foregroundColor(.white.opacity(0.9))
                    .font(.body)

                    Spacer(minLength: 30)
                }
                .padding(22)
            }
        }
    }
}

#Preview {
    SettingsScreen(isLoggedIn: .constant(true))
        .environmentObject(AuthViewModel())
        .preferredColorScheme(.dark)
}
