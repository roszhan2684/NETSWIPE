//
//  NetSwipeApp.swift
//  NetSwipe
//
//  Created by ROSZHAN RAJ on 05/09/25.
//

import SwiftUI

@main
struct NetSwipeApp: App {
    // ❗ We do NOT persist login – every fresh run starts at Welcome
    @State private var isLoggedIn: Bool = false

    // Local flag for the current session’s profile-setup flow
    @State private var hasSetupProfile: Bool = false

    // MARK: - Shared States
    @State private var likedProfiles: [Profile] = []
    @State private var profiles: [Profile] = sampleProfiles
    @State private var swipeTrigger: SwipeDirection = .none
    @State private var showCompletion: Bool = false
    @State private var matchedProfile: Profile? = nil

    // Shared AuthViewModel (available app-wide)
    @StateObject private var authViewModel = AuthViewModel()

    // Track app lifecycle
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                // 🟢 STEP 1: Not logged in → Welcome / Login / Register
                if !isLoggedIn {
                    NavigationStack {
                        WelcomeScreen(
                            likedProfiles: $likedProfiles,
                            isLoggedIn: $isLoggedIn
                        )
                    }

                // 🟠 STEP 2: Logged in, BUT backend says profile is NOT complete
                //           AND we haven’t finished the local setup flow yet
                } else if !(authViewModel.profile?.hasProfile ?? false) && !hasSetupProfile {
                    NavigationStack {
                        ProfileSetupScreen(
                            profiles: $profiles,
                            likedProfiles: $likedProfiles,
                            swipeTrigger: $swipeTrigger,
                            matchedProfile: $matchedProfile,
                            showCompletion: $showCompletion,
                            hasSetupProfile: $hasSetupProfile   // set true when setup finished
                        )
                    }

                // 🔵 STEP 3: Logged in & profile complete → Main tabs
                } else {
                    MainTabView(
                        likedProfiles: $likedProfiles,
                        isLoggedIn: $isLoggedIn
                    )
                }
            }
            // Make AuthViewModel available everywhere
            .environmentObject(authViewModel)
            // 🔐 Auto-logout when app goes to background
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .background {
                    // End current session locally
                    isLoggedIn = false
                    hasSetupProfile = false   // reset local setup for next login

                    // Clear stored tokens / IDs
                    UserDefaults.standard.removeObject(forKey: "authToken")
                    UserDefaults.standard.removeObject(forKey: "userId")
                }
            }
        }
    }
}
