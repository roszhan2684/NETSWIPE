//  AuthViewModel.swift
//  NetSwipe
//

import Foundation
import SwiftUI
import Combine

// MARK: - Profile Update Request
struct UpdateProfileRequest: Codable {
    let userId: String
    let name: String
    let interests: [String]
    let profilePhoto: String    // Base64-encoded string or URL
}

// MARK: - Swipe Request
struct SwipeRequest: Codable {
    let fromUserId: String
    let toUserId: String
    let direction: String       // "like" or "dislike"
}

class AuthViewModel: ObservableObject {
    @Published var message: String = ""
    @Published var isRegistered = false
    @Published var isVerified = false
    @Published var isLoggedIn = false
    @Published var profile: Profile? = nil

    // List of mutual matches used by Chats / Matches UI
    @Published var matches: [Profile] = []

    // Profile to optionally restore to the top of the deck after an unmatch
    @Published var resurrectProfileAfterUnmatch: Profile? = nil

    // Convenience accessor for the current user's identifier
    var userId: String? { profile?.id }

    // After a "Restart Swiping" action, previous matches are ignored until the next swipe
    private var suppressMatchesUntilNextSwipe: Bool = false

    // MARK: - Registration
    func register(email: String,
                  username: String,
                  password: String,
                  completion: @escaping (Bool, String?) -> Void) {

        let body = RegisterRequest(email: email, username: username, password: password)

        NetworkManager.shared.postRequest(endpoint: "/auth/register", body: body) {
            (result: Result<RegisterResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    self.message = res.message
                    self.isRegistered = true
                    completion(true, nil)
                    print("✅ Registered user:", res.email ?? "unknown")

                case .failure(let err):
                    let msg: String
                    if err.localizedDescription.contains("409") {
                        msg = "Email already registered"
                    } else {
                        msg = "Error: \(err.localizedDescription)"
                    }
                    self.message = msg
                    self.isRegistered = false
                    completion(false, msg)
                    print("❌ Register error:", msg)
                }
            }
        }
    }

    // MARK: - OTP Verification
    func verify(email: String, otp: String) {
        let body = VerifyRequest(email: email, otp: otp)

        NetworkManager.shared.postRequest(endpoint: "/auth/verify-otp", body: body) {
            (result: Result<VerifyResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    self.message = res.message
                    self.isVerified = res.message.lowercased().contains("success")
                    print("✅ OTP verification:", self.isVerified)

                case .failure(let err):
                    self.message = "Error: \(err.localizedDescription)"
                    self.isVerified = false
                    print("❌ OTP verification error:", err.localizedDescription)
                }
            }
        }
    }

    // MARK: - Resend OTP
    func resendOtp(email: String) {
        let body = ["email": email]

        NetworkManager.shared.postRequest(endpoint: "/auth/resend-otp", body: body) {
            (result: Result<MessageResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    self.message = res.message
                    print("📩 \(res.message)")

                case .failure(let err):
                    self.message = "Error: \(err.localizedDescription)"
                    print("❌ Resend OTP error:", err.localizedDescription)
                }
            }
        }
    }

    // MARK: - Login
    func login(email: String, password: String) {
        let body = LoginRequest(email: email, password: password)

        NetworkManager.shared.postRequest(endpoint: "/auth/login", body: body) {
            (result: Result<LoginResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    self.message = "✅ Login successful"
                    self.isLoggedIn = true

                    // New session: clear any existing chat-related state
                    ChatStore.shared.reset()
                    SocketService.shared.removeAllNewMessageHandlers()
                    self.suppressMatchesUntilNextSwipe = false

                    // Persist authentication for subsequent API calls
                    UserDefaults.standard.set(res.token, forKey: "authToken")
                    UserDefaults.standard.set(res.userId, forKey: "userId")

                    print("🟢 Logged in as:", res.email)

                    // Temporary profile until the full profile is fetched
                    self.profile = Profile(
                        id: res.userId,
                        email: res.email,
                        username: res.username,
                        verified: true,
                        name: res.username,
                        description: "",
                        interests: [],
                        profilePhoto: "",
                        location: nil,
                        isProfileComplete: false,
                        createdAt: nil,
                        updatedAt: nil,
                        imageData: nil,
                        profileCompleted: false,
                        localImageName: nil
                    )

                    // Fetch full profile for the logged-in user
                    self.fetchProfile()

                case .failure(let err):
                    self.message = "Error: \(err.localizedDescription)"
                    self.isLoggedIn = false
                    print("❌ Login error:", err.localizedDescription)
                }
            }
        }
    }

    // MARK: - Fetch Current User Profile
    /// Fetches the currently authenticated user's profile using `/profile/me?userId=...`.
    func fetchProfile() {
        guard let userId = UserDefaults.standard.string(forKey: "userId"),
              !userId.isEmpty else {
            print("⚠️ fetchProfile: no userId in UserDefaults")
            return
        }

        let endpoint = "/profile/me?userId=\(userId)"

        NetworkManager.shared.getRequest(endpoint: endpoint) {
            (result: Result<MyProfileResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let user = response.user {
                        self.profile = user
                        print("✅ My profile fetched for:", user.name ?? "Unknown")

                        // Refresh matches whenever the profile is loaded
                        self.fetchMatches()
                    } else {
                        print("⚠️ /profile/me returned success but no user object")
                    }

                case .failure(let err):
                    print("❌ Fetch my profile error:", err.localizedDescription)
                }
            }
        }
    }

    // MARK: - Complete Profile Setup
    func completeProfile(userId: String,
                         name: String,
                         interests: [String],
                         imageUrl: String) {

        let endpoint = "/profile/update"

        let body = UpdateProfileRequest(
            userId: userId,
            name: name,
            interests: interests,
            profilePhoto: imageUrl
        )

        NetworkManager.shared.postRequest(endpoint: endpoint, body: body) {
            (result: Result<UpdateProfileResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let updated = response.user {
                        self.profile = updated
                        print("✅ Profile setup completed for:", updated.name ?? "Unknown")

                        // Refresh matches after profile completion
                        self.fetchMatches()
                    } else {
                        print("⚠️ completeProfile: success but no user in response")
                    }

                case .failure(let err):
                    print("❌ Profile setup error:", err.localizedDescription)
                }
            }
        }
    }

    // MARK: - Send Swipe (Like / Dislike)
    func sendSwipe(to otherUserId: String, like: Bool, completion: @escaping (Bool) -> Void) {
        guard let currentId = userId else {
            completion(false)
            return
        }

        // Any new swipe after a restart re-enables match retrieval
        suppressMatchesUntilNextSwipe = false

        let body = SwipeRequest(
            fromUserId: currentId,
            toUserId: otherUserId,
            direction: like ? "like" : "dislike"
        )

        NetworkManager.shared.postRequest(endpoint: "/match/swipe", body: body) {
            (result: Result<SwipeResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let resp):
                    if resp.success, resp.matched == true {
                        // New mutual match: refresh from backend
                        self.fetchMatches()
                    }
                    completion(resp.matched ?? false)

                case .failure(let err):
                    print("❌ Swipe error:", err.localizedDescription)
                    completion(false)
                }
            }
        }
    }

    // MARK: - Unmatch Single User
    /// Unmatches a single user on the backend and updates local state accordingly.
    func unmatch(otherUserId: String, completion: @escaping (Bool) -> Void) {
        guard let currentId = userId else {
            print("⚠️ unmatch: no current userId")
            completion(false)
            return
        }

        // Capture the existing profile to optionally restore it in the deck
        let resurrectProfile = matches.first(where: { $0.id == otherUserId })

        let endpoint = "/match/unmatch/\(otherUserId)?me=\(currentId)"

        NetworkManager.shared.deleteRequest(endpoint: endpoint) {
            (result: Result<MessageResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    print("🧹 Unmatched with \(otherUserId): \(res.message)")

                    // Remove from local matches
                    self.matches.removeAll { $0.id == otherUserId }

                    // Clear local swipe / like state for this profile
                    self.clearLocalSwipeFor(profileId: otherUserId)

                    // Optionally request the UI to bring the profile back into the deck
                    if let resurrect = resurrectProfile {
                        self.resurrectProfileAfterUnmatch = resurrect
                        print("🃏 Will resurrect profile \(resurrect.id) on top of deck (if observed)")
                    }

                    // Optionally refresh matches from the backend
                    self.fetchMatches(force: true)

                    completion(true)

                case .failure(let err):
                    print("❌ Unmatch error:", err.localizedDescription)
                    completion(false)
                }
            }
        }
    }

    // MARK: - Fetch Matches
    func fetchMatches(force: Bool = false) {
        guard let currentId = userId else { return }

        // After a restart, skip loading existing matches until a new swipe occurs
        if suppressMatchesUntilNextSwipe && !force {
            print("⚠️ fetchMatches() suppressed due to local restart")
            return
        }

        NetworkManager.shared.getRequest(endpoint: "/match/matches/\(currentId)") {
            (result: Result<MatchesResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let resp):
                    self.matches = resp.matches ?? []
                    print("✅ Matches fetched:", self.matches.count)

                case .failure(let err):
                    print("❌ Fetch matches error:", err.localizedDescription)
                }
            }
        }
    }

    // MARK: - Per-user Swipe Keys (UserDefaults)
    private func swipedKey(for userId: String) -> String {
        "swipedProfileIds_\(userId)"
    }

    private func likedKey(for userId: String) -> String {
        "likedProfileIds_\(userId)"
    }

    // MARK: - Clear Local Swipe / Like State for One Profile
    /// Removes a single profile identifier from the current user's local swiped and liked sets.
    private func clearLocalSwipeFor(profileId: String) {
        guard let uid = userId else { return }
        let defaults = UserDefaults.standard

        // Swiped identifiers
        if let data = defaults.data(forKey: swipedKey(for: uid)),
           let arr = try? JSONDecoder().decode([String].self, from: data) {
            var set = Set(arr)
            if set.remove(profileId) != nil,
               let newData = try? JSONEncoder().encode(Array(set)) {
                defaults.set(newData, forKey: swipedKey(for: uid))
            }
        }

        // Liked identifiers
        if let data = defaults.data(forKey: likedKey(for: uid)),
           let arr = try? JSONDecoder().decode([String].self, from: data) {
            var set = Set(arr)
            if set.remove(profileId) != nil,
               let newData = try? JSONEncoder().encode(Array(set)) {
                defaults.set(newData, forKey: likedKey(for: uid))
            }
        }
    }

    // MARK: - Restart Swiping (Local + Backend Reset)
    /// Invoked by the UI when "Restart Swiping" is selected.
    /// Clears local matches, chat state, swipes/likes, and resets matches/chats on the backend.
    func applyLocalRestartFromUI() {
        print("♻️ AuthViewModel.applyLocalRestartFromUI()")

        let currentId = self.userId

        // Local matches and suppression flag
        matches.removeAll()
        suppressMatchesUntilNextSwipe = true

        // Reset chat store and socket handlers so the Chats tab is cleared
        ChatStore.shared.reset()
        SocketService.shared.removeAllNewMessageHandlers()

        // Clear local swiped/liked identifiers for this user
        let defaults = UserDefaults.standard
        if let uid = currentId {
            defaults.removeObject(forKey: swipedKey(for: uid))
            defaults.removeObject(forKey: likedKey(for: uid))
        }

        // Remove legacy global keys from earlier versions
        defaults.removeObject(forKey: "swipedProfileIds")
        defaults.removeObject(forKey: "likedProfileIds")

        // Reset matches and chats on the backend
        clearMatchesOnBackend()
        clearChatsOnBackend()
    }

    /// Backwards-compatible alias retained for older call sites.
    func handleRestartSwiping() {
        applyLocalRestartFromUI()
    }

    /// Clears all matches for the current user on the backend using `DELETE /match/reset/:userId`.
    private func clearMatchesOnBackend() {
        guard let currentId = userId else { return }

        NetworkManager.shared.deleteRequest(endpoint: "/match/reset/\(currentId)") {
            (result: Result<MessageResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    print("🧹 Backend matches reset:", res.message)
                case .failure(let err):
                    print("⚠️ Backend match reset failed:", err.localizedDescription)
                }
            }
        }
    }

    /// Clears all chats for the current user on the backend using `DELETE /chat/reset/:userId`.
    private func clearChatsOnBackend() {
        guard let currentId = userId else { return }

        NetworkManager.shared.deleteRequest(endpoint: "/chat/reset/\(currentId)") {
            (result: Result<MessageResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    print("🧹 Backend chats reset:", res.message)
                case .failure(let err):
                    print("⚠️ Backend chat reset failed:", err.localizedDescription)
                }
            }
        }
    }

    // MARK: - Logout
    /// Logs out the current user locally without resetting backend swipe/match state.
    func logout() {
        isLoggedIn = false
        isRegistered = false
        isVerified = false
        profile = nil
        matches.removeAll()
        suppressMatchesUntilNextSwipe = false

        // Clear authentication data
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userId")

        // Clear chat UI state and socket listeners
        ChatStore.shared.reset()
        SocketService.shared.removeAllNewMessageHandlers()

        message = "Logged out"
    }

    // MARK: - Delete Profile (Backend) + Full Local Reset
    func deleteProfile(userId: String, completion: @escaping (Bool, String?) -> Void) {
        NetworkManager.shared.deleteRequest(endpoint: "/profile/delete/\(userId)") {
            (result: Result<MessageResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    print("✅ Delete profile backend:", res.message)
                    completion(true, res.message)

                case .failure(let err):
                    print("❌ Delete profile backend error:", err.localizedDescription)
                    completion(false, err.localizedDescription)
                }
            }
        }
    }

    /// Clears all local state and persisted data after a profile deletion.
    func fullLocalResetAfterDelete() {
        let lastId = self.userId

        // In-memory state
        self.profile = nil
        self.matches = []
        self.isLoggedIn = false
        self.isVerified = false
        self.isRegistered = false
        self.message = ""
        self.suppressMatchesUntilNextSwipe = false

        // Authentication tokens
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userId")

        // Legacy swipe keys (backward compatibility)
        UserDefaults.standard.removeObject(forKey: "swipedProfileIds")
        UserDefaults.standard.removeObject(forKey: "likedProfileIds")

        // Per-user swipe keys
        if let uid = lastId {
            UserDefaults.standard.removeObject(forKey: swipedKey(for: uid))
            UserDefaults.standard.removeObject(forKey: likedKey(for: uid))
        }

        // Restart flag
        UserDefaults.standard.removeObject(forKey: "restartSwipingNonce")

        // Chat state
        ChatStore.shared.reset()
        SocketService.shared.removeAllNewMessageHandlers()
    }
}

// MARK: - Simple Message Response
struct MessageResponse: Codable {
    let message: String
}

// MARK: - Response for /profile/me
struct MyProfileResponse: Codable {
    let success: Bool
    let user: Profile?
}

// MARK: - Matching DTOs
struct SwipeResponse: Codable {
    let success: Bool
    let matched: Bool?
    let matchUserId: String?
    let alreadyMatched: Bool?
}

struct MatchesResponse: Codable {
    let success: Bool
    let count: Int?
    let matches: [Profile]?
}
