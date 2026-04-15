//
//  ProfileView.swift
//  NetSwipe
//
//  Shows the logged-in user's profile with an Edit button
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    // Local copy we can mutate and keep in sync
    @State private var profile: Profile

    @State private var showEdit = false

    // Custom init so we can pass in the current profile
    init(profile: Profile) {
        _profile = State(initialValue: profile)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.6, green: 0.3, blue: 0.8),
                        Color(red: 0.15, green: 0.0, blue: 0.25)
                    ]),
                    center: .center,
                    startRadius: 80,
                    endRadius: 600
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        // Title
                        Text("My Profile")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 8)

                        // Avatar
                        profile.profileImage()
                            .frame(width: 180, height: 180)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 8)

                        // Name + username
                        VStack(spacing: 4) {
                            Text(profile.displayName)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)

                            if let username = profile.username {
                                Text("@\(username)")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.85))
                            }
                        }

                        // Email
                        if let email = profile.email {
                            HStack(spacing: 8) {
                                Image(systemName: "envelope.fill")
                                Text(email)
                            }
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.85))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Location
                        if let location = profile.location,
                           !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "mappin.and.ellipse")
                                Text(location)
                            }
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Interests
                        let interests = (profile.interests ?? [])
                            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

                        if !interests.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Interests")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                // Clean wrapping chips using LazyVGrid
                                let columns = [GridItem(.adaptive(minimum: 110), spacing: 8)]
                                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                                    ForEach(interests, id: \.self) { interest in
                                        Text(interest)
                                            .font(.caption)
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 12)
                                            .background(Color.white.opacity(0.18))
                                            .foregroundColor(.white)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Bio / About
                        if let bio = profile.description,
                           !bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("About")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(bio)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.95))
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Spacer(minLength: 12)

                        // Edit button
                        Button(action: { showEdit = true }) {
                            Text("Edit Profile")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        colors: [Color.purple, Color.blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 6)
                        }
                        .padding(.top, 8)
                    }
                    // Global padding so everything lines up nicely
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    .padding(.top, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showEdit) {
                EditProfileView(profile: profile)
                    .environmentObject(authViewModel)
            }
            // Keep local profile in sync with AuthViewModel
            .onChange(of: authViewModel.profile) { newValue in
                if let latest = newValue {
                    profile = latest
                }
            }
            .onAppear {
                if let latest = authViewModel.profile {
                    profile = latest
                }
            }
        }
    }
}
