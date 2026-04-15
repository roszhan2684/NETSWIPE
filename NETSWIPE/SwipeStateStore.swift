//
//  SwipeStateStore.swift
//  NETSWIPE
//
//  Created by ROSZHAN RAJ on 21/11/25.
//

import Foundation

// Stores only SMALL data (ids + light profile cache)
// ✅ Avoids storing imageData/base64 in UserDefaults.
final class SwipeStateStore {
    static let shared = SwipeStateStore()
    private init() {}

    private let rightKey = "swipedRightIds"
    private let leftKey  = "swipedLeftIds"
    private let likedKey = "likedProfilesLite"
    private let matchKey = "matchedProfilesLite"

    // MARK: - IDs
    var swipedRightIds: Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: rightKey) ?? [])
    }
    var swipedLeftIds: Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: leftKey) ?? [])
    }

    func addRight(_ id: String) {
        var set = swipedRightIds
        set.insert(id)
        UserDefaults.standard.set(Array(set), forKey: rightKey)
    }

    func addLeft(_ id: String) {
        var set = swipedLeftIds
        set.insert(id)
        UserDefaults.standard.set(Array(set), forKey: leftKey)
    }

    // MARK: - Lite profile caching (for Liked/Matched tabs)
    struct ProfileLite: Codable, Hashable, Identifiable {
        let id: String
        let name: String
        let bio: String
        let interests: [String]
        let profilePhoto: String
    }

    private func saveLite(_ arr: [ProfileLite], key: String) {
        if let data = try? JSONEncoder().encode(arr) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func loadLite(key: String) -> [ProfileLite] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([ProfileLite].self, from: data)
        else { return [] }
        return decoded
    }

    var likedLite: [ProfileLite] {
        get { loadLite(key: likedKey) }
        set { saveLite(newValue, key: likedKey) }
    }

    var matchedLite: [ProfileLite] {
        get { loadLite(key: matchKey) }
        set { saveLite(newValue, key: matchKey) }
    }

    func addLiked(profile: Profile) {
        var arr = likedLite
        let lite = ProfileLite(
            id: profile.id,
            name: profile.displayName,
            bio: profile.description ?? "",
            interests: profile.interests ?? [],
            profilePhoto: profile.profilePhoto ?? ""
        )
        if !arr.contains(lite) {
            arr.append(lite)
        }
        likedLite = arr
    }

    func addMatched(profile: Profile) {
        var arr = matchedLite
        let lite = ProfileLite(
            id: profile.id,
            name: profile.displayName,
            bio: profile.description ?? "",
            interests: profile.interests ?? [],
            profilePhoto: profile.profilePhoto ?? ""
        )
        if !arr.contains(lite) {
            arr.append(lite)
        }
        matchedLite = arr
    }

    // MARK: - Reset everything
    func resetAll() {
        UserDefaults.standard.removeObject(forKey: rightKey)
        UserDefaults.standard.removeObject(forKey: leftKey)
        UserDefaults.standard.removeObject(forKey: likedKey)
        UserDefaults.standard.removeObject(forKey: matchKey)
    }
}

// Notification for reset from any tab
extension Notification.Name {
    static let restartSwiping = Notification.Name("restartSwiping")
}
