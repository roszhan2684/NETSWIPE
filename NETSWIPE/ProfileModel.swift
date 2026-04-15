//
//  ProfileModel.swift
//  NetSwipe
//
//  ✅ Backend-compatible Profile model
//  ✅ Safe decoding (bio/name optional, id from `_id` or `id`)
//  ✅ Smart image loader (Data, base64, remote URL, or local asset)
//  ✅ Matches both /profile and /profile/update responses
//

import Foundation
import SwiftUI

// MARK: - Helpers
private extension String {
    var isRemoteURL: Bool {
        let s = self.lowercased()
        return s.hasPrefix("http://") || s.hasPrefix("https://")
    }
}

// MARK: - Profile Model (Backend-Compatible)
struct Profile: Identifiable, Hashable, Codable {
    // 🔹 Backend fields
    var id: String
    var email: String?
    var username: String?
    var verified: Bool?
    var name: String?
    var description: String?   // backend uses "bio"
    var interests: [String]?
    var profilePhoto: String?
    var location: String?
    var isProfileComplete: Bool?
    var createdAt: String?
    var updatedAt: String?

    // 🔹 Local-only (not required from backend, but useful for cache/UI)
    var imageData: Data?
    var profileCompleted: Bool?
    var localImageName: String?    // for CSV / asset-based fake users

    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id = "_id"            // primary (Mongo _id)
        case plainId = "id"        // fallback if backend sends "id"
        case email
        case username
        case verified
        case name
        case description = "bio"
        case interests
        case profilePhoto
        case location
        case isProfileComplete
        case createdAt
        case updatedAt
        case imageData
        case profileCompleted
        case localImageName
    }

    // MARK: - Custom Decoding (handles `id` OR `_id`)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let mongoId = try container.decodeIfPresent(String.self, forKey: .id)
        let plainId = try container.decodeIfPresent(String.self, forKey: .plainId)
        self.id = mongoId ?? plainId ?? ""

        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.verified = try container.decodeIfPresent(Bool.self, forKey: .verified)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.interests = try container.decodeIfPresent([String].self, forKey: .interests)
        self.profilePhoto = try container.decodeIfPresent(String.self, forKey: .profilePhoto)
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.isProfileComplete = try container.decodeIfPresent(Bool.self, forKey: .isProfileComplete)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)

        self.imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        self.profileCompleted = try container.decodeIfPresent(Bool.self, forKey: .profileCompleted)
        self.localImageName = try container.decodeIfPresent(String.self, forKey: .localImageName)
    }

    // MARK: - Custom Encoding (needed because we overrode init(from:))
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Encode id as `_id`
        try container.encode(id, forKey: .id)

        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(verified, forKey: .verified)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(interests, forKey: .interests)
        try container.encodeIfPresent(profilePhoto, forKey: .profilePhoto)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(isProfileComplete, forKey: .isProfileComplete)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(imageData, forKey: .imageData)
        try container.encodeIfPresent(profileCompleted, forKey: .profileCompleted)
        try container.encodeIfPresent(localImageName, forKey: .localImageName)
    }

    // MARK: - Manual memberwise init (for sampleProfiles & custom creation)
    init(
        id: String,
        email: String? = nil,
        username: String? = nil,
        verified: Bool? = nil,
        name: String? = nil,
        description: String? = nil,
        interests: [String]? = nil,
        profilePhoto: String? = nil,
        location: String? = nil,
        isProfileComplete: Bool? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        imageData: Data? = nil,
        profileCompleted: Bool? = nil,
        localImageName: String? = nil
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.verified = verified
        self.name = name
        self.description = description
        self.interests = interests
        self.profilePhoto = profilePhoto
        self.location = location
        self.isProfileComplete = isProfileComplete
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.imageData = imageData
        self.profileCompleted = profileCompleted
        self.localImageName = localImageName
    }

    // MARK: - Computed Helpers

    /// Whether the profile is complete (checks both backend + local flags)
    var hasProfile: Bool {
        (isProfileComplete ?? profileCompleted) ?? false
    }

    /// Nice display name fallback logic
    var displayName: String {
        let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? (username ?? "User") : trimmed
    }

    /// Comma-separated interests string, with a friendly fallback
    var interestsLine: String {
        let arr = (interests ?? [])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return arr.isEmpty ? "New here • Say hi!" : arr.joined(separator: ", ")
    }

    // MARK: - SwiftUI Image Loader
    @ViewBuilder
    func profileImage() -> some View {
        // 1️⃣ Raw Data (picked from Photos or decoded from base64)
        if let data = imageData, let ui = UIImage(data: data) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()

        // 2️⃣ profilePhoto string present
        } else if let src = profilePhoto, !src.isEmpty {

            // Remote URL (http/https)
            if src.isRemoteURL, let url = URL(string: src) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_):
                        placeholderImage
                    default:
                        ZStack {
                            Color.black.opacity(0.08)
                            ProgressView()
                        }
                    }
                }

            // Base64 stored in MongoDB
            } else if let data = Data(base64Encoded: src),
                      let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()

            // Fallback
            } else {
                placeholderImage
            }

        // 3️⃣ Local asset (for CSV fake profiles)
        } else if let asset = localImageName, !asset.isEmpty {
            Image(asset)
                .resizable()
                .scaledToFill()

        // 4️⃣ Totally missing photo
        } else {
            placeholderImage
        }
    }

    private var placeholderImage: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .padding(24)
    }
}

// MARK: - Response Wrappers

/// ✅ GET /profile → { success, count, users: [...] }
struct ProfileResponse: Codable {
    let success: Bool
    let count: Int?
    let users: [Profile]?
}

/// ✅ POST /profile/update → { success, message, user: {...} }
struct UpdateProfileResponse: Codable {
    let success: Bool
    let message: String?
    let user: Profile?
}

// MARK: - Sample Data (for previews)

let sampleProfiles: [Profile] = [
    Profile(
        id: UUID().uuidString,
        email: "roszhanraj@example.com",
        username: "roszhanraj",
        verified: true,
        name: "Roszhan Raj",
        description: "AI • SwiftUI • Design",
        interests: ["UI/UX", "AI", "Swift"],
        profilePhoto: "https://cdn-icons-png.flaticon.com/512/1077/1077012.png",
        location: "Fullerton, CA",
        isProfileComplete: true
    )
]

// MARK: - Swipe Direction Enum

enum SwipeDirection {
    case left, right, none
}
