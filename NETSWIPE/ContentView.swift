////
////  ContentView.swift
////  NetSwipe
////
////  Final version — with fixed initializer and profile setup flow
////
//
//import SwiftUI
//
//struct ContentView: View {
//    @StateObject private var authViewModel = AuthViewModel()
//    @State private var likedProfiles: [Profile] = []
//    @State private var profiles: [Profile] = sampleProfiles
//
//    var body: some View {
//        NavigationStack {
//            if authViewModel.isLoggedIn {
//                // ✅ After login — choose between setup or main view
//                if let profile = authViewModel.profile {
//                    if profile.hasProfile {
//                        // 🟣 Main app (tabs after profile setup)
//                        MainTabView(
//                            likedProfiles: $likedProfiles,
//                            isLoggedIn: $authViewModel.isLoggedIn
//                        )
//                        .environmentObject(authViewModel)
//                    } else {
//                        // 🟠 Go to Profile Setup
//                        ProfileSetupScreen(
//                            profiles: $profiles,
//                            likedProfiles: $likedProfiles,
//                            swipeTrigger: .constant(.none),
//                            matchedProfile: .constant(nil),
//                            showCompletion: .constant(false),
//                            hasSetupProfile: .constant(false)
//                        )
//                        .environmentObject(authViewModel)
//                    }
//                } else {
//                    ProgressView("Loading profile...")
//                        .foregroundColor(.white)
//                }
//            } else {
//                // ==============================
//                // 🔹 Welcome / Landing Screen
//                // ==============================
//                ZStack {
//                    Image("nn")
//                        .resizable()
//                        .scaledToFill()
//                        .ignoresSafeArea()
//
//                    VStack(spacing: 40) {
//                        Spacer()
//
//                        // Logo
//                        Image("group-icon")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 180, height: 180)
//                            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 6)
//
//                        // Title
//                        Text("NetSwipe")
//                            .font(.custom("GCsaphoneDEMO-Regular", size: 54))
//                            .foregroundStyle(
//                                LinearGradient(
//                                    colors: [
//                                        Color(red: 0.95, green: 0.75, blue: 0.2),
//                                        Color(red: 0.8, green: 0.2, blue: 0.2),
//                                        Color(red: 1.0, green: 0.5, blue: 0.1)
//                                    ],
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                )
//                            )
//                            .shadow(color: .black.opacity(0.9), radius: 14, x: 0, y: 6)
//                            .tracking(3)
//
//                        Text("SWIPE   •   CONNECT   •   GROW")
//                            .font(.headline)
//                            .foregroundColor(.white.opacity(0.9))
//
//                        Spacer().frame(height: 40)
//
//                        // Login Button
//                        NavigationLink(
//                            destination: LoginScreen(
//                                likedProfiles: $likedProfiles,
//                                isLoggedIn: $authViewModel.isLoggedIn
//                            )
//                            .environmentObject(authViewModel)
//                        ) {
//                            Text("Login")
//                                .font(.headline)
//                                .foregroundColor(.white)
//                                .padding()
//                                .frame(width: 300)
//                                .background(
//                                    LinearGradient(
//                                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]),
//                                        startPoint: .top,
//                                        endPoint: .bottom
//                                    )
//                                )
//                                .cornerRadius(14)
//                                .shadow(radius: 6)
//                        }
//
//                        // Register Button
//                        NavigationLink(
//                            destination: RegisterScreen(
//                                likedProfiles: $likedProfiles,
//                                isLoggedIn: $authViewModel.isLoggedIn
//                            )
//                            .environmentObject(authViewModel)
//                        ) {
//                            Text("Register")
//                                .font(.headline)
//                                .foregroundColor(.white)
//                                .padding()
//                                .frame(width: 300)
//                                .background(
//                                    LinearGradient(
//                                        gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green]),
//                                        startPoint: .top,
//                                        endPoint: .bottom
//                                    )
//                                )
//                                .cornerRadius(14)
//                                .shadow(radius: 6)
//                        }
//
//                        Spacer()
//                    }
//                    .padding(.bottom, 40)
//                }
//            }
//        }
//        .environmentObject(authViewModel)
//    }
//}
//
//#Preview {
//    ContentView()
//}
//
//  ContentView.swift
//  NetSwipe
//
//  Root view that manages authentication, profile setup, and the main tab experience.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var likedProfiles: [Profile] = []
    @State private var profiles: [Profile] = sampleProfiles

    var body: some View {
        NavigationStack {
            if authViewModel.isLoggedIn {
                // After login, either show the main app or the profile setup flow.
                if let profile = authViewModel.profile {
                    if profile.hasProfile {
                        // Main application with tab navigation after profile setup.
                        MainTabView(
                            likedProfiles: $likedProfiles,
                            isLoggedIn: $authViewModel.isLoggedIn
                        )
                        .environmentObject(authViewModel)
                    } else {
                        // Profile setup flow for first-time users.
                        ProfileSetupScreen(
                            profiles: $profiles,
                            likedProfiles: $likedProfiles,
                            swipeTrigger: .constant(.none),
                            matchedProfile: .constant(nil),
                            showCompletion: .constant(false),
                            hasSetupProfile: .constant(false)
                        )
                        .environmentObject(authViewModel)
                    }
                } else {
                    ProgressView("Loading profile...")
                        .foregroundColor(.white)
                }
            } else {
                // Welcome / landing screen shown before authentication.
                ZStack {
                    Image("nn")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()

                    VStack(spacing: 40) {
                        Spacer()

                        // App logo
                        Image("group-icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 6)

                        // App title
                        Text("NetSwipe")
                            .font(.custom("GCsaphoneDEMO-Regular", size: 54))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.95, green: 0.75, blue: 0.2),
                                        Color(red: 0.8, green: 0.2, blue: 0.2),
                                        Color(red: 1.0, green: 0.5, blue: 0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .black.opacity(0.9), radius: 14, x: 0, y: 6)
                            .tracking(3)

                        Text("SWIPE   •   CONNECT   •   GROW")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))

                        Spacer().frame(height: 40)

                        // Login button
                        NavigationLink(
                            destination: LoginScreen(
                                likedProfiles: $likedProfiles,
                                isLoggedIn: $authViewModel.isLoggedIn
                            )
                            .environmentObject(authViewModel)
                        ) {
                            Text("Login")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 300)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(14)
                                .shadow(radius: 6)
                        }

                        // Register button
                        NavigationLink(
                            destination: RegisterScreen(
                                likedProfiles: $likedProfiles,
                                isLoggedIn: $authViewModel.isLoggedIn
                            )
                            .environmentObject(authViewModel)
                        ) {
                            Text("Register")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 300)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(14)
                                .shadow(radius: 6)
                        }

                        Spacer()
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .environmentObject(authViewModel)
    }
}

#Preview {
    ContentView()
}
