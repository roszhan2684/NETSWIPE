////
////  ProfileAPI.swift
////  NetSwipe
////
////  Created by ROSZHAN RAJ
////
////  ✅ Swift 6-safe networking & decoding
////  ✅ Matches backend routes: /profile & /profile/update
////  ✅ Works with UpdateProfileResponse & ProfileResponse
////  ✅ Fixes decoding errors and endpoint mismatches
////
//
//import Foundation
//import UIKit
//
//@MainActor
//final class ProfileAPI {
//    static let shared = ProfileAPI()
//    private init() {}
//
//    // ⚙️ For simulator: localhost works; for iPhone use your Mac’s LAN IP (e.g., 192.168.x.x)
//    private let baseURL = "http://localhost:8000"
//
//    // MARK: - 🟢 Update or Complete Profile Setup
//    func updateProfile(_ profile: Profile, completion: @escaping (Profile?) -> Void) {
//        guard let url = URL(string: "\(baseURL)/profile/update") else {
//            print("❌ Invalid URL for /profile/update")
//            completion(nil)
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // Build body dictionary
//        var dict: [String: Any] = [
//            "userId": profile.id,
//            "name": profile.name ?? "",
//            "interests": profile.interests ?? [],
//            "bio": profile.description ?? "",
//            "location": profile.location ?? "",
//            "profilePhoto": profile.profilePhoto ?? ""
//        ]
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: dict, options: [])
//        } catch {
//            print("⚠️ JSON encoding error:", error.localizedDescription)
//            completion(nil)
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("❌ Network error:", error.localizedDescription)
//                DispatchQueue.main.async { completion(nil) }
//                return
//            }
//
//            guard let data = data else {
//                print("⚠️ Empty response from server")
//                DispatchQueue.main.async { completion(nil) }
//                return
//            }
//
//            do {
//                let decoded = try JSONDecoder().decode(UpdateProfileResponse.self, from: data)
//                if decoded.success, let user = decoded.user {
//                    print("✅ Profile updated successfully:", user.displayName)
//                    DispatchQueue.main.async { completion(user) }
//                } else {
//                    print("⚠️ Update failed:", decoded.message ?? "Unknown error")
//                    DispatchQueue.main.async { completion(nil) }
//                }
//            } catch {
//                print("❌ POST Decoding Error:", error.localizedDescription)
//                if let raw = String(data: data, encoding: .utf8) {
//                    print("🧾 Raw response:", raw)
//                }
//                DispatchQueue.main.async { completion(nil) }
//            }
//        }.resume()
//    }
//
//    // MARK: - 🟣 Fetch All Profiles
//    func fetchProfiles(completion: @escaping ([Profile]) -> Void) {
//        guard let url = URL(string: "\(baseURL)/profile") else {
//            print("❌ Invalid URL for /profile")
//            completion([])
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            if let error = error {
//                print("❌ Network error:", error.localizedDescription)
//                DispatchQueue.main.async { completion([]) }
//                return
//            }
//
//            guard let data = data else {
//                print("⚠️ Empty response from server")
//                DispatchQueue.main.async { completion([]) }
//                return
//            }
//
//            do {
//                let decoded = try JSONDecoder().decode(ProfileResponse.self, from: data)
//                if decoded.success, let users = decoded.users {
//                    print("✅ Loaded profiles:", users.count)
//                    DispatchQueue.main.async { completion(users) }
//                } else {
//                    print("⚠️ No users found or success=false")
//                    DispatchQueue.main.async { completion([]) }
//                }
//            } catch {
//                print("❌ GET Decoding Error:", error.localizedDescription)
//                if let raw = String(data: data, encoding: .utf8) {
//                    print("🧾 Raw response:", raw)
//                }
//                DispatchQueue.main.async { completion([]) }
//            }
//        }.resume()
//    }
//
//    // MARK: - 🟠 Optional: Create Profile (Unused in your flow)
//    func createProfile(_ profile: Profile, completion: @escaping (Profile?) -> Void) {
//        guard let url = URL(string: "\(baseURL)/profile/create") else {
//            print("❌ Invalid URL for /profile/create")
//            completion(nil)
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        var dict: [String: Any] = [
//            "name": profile.name ?? "",
//            "bio": profile.description ?? "",
//            "interests": profile.interests ?? [],
//            "profilePhoto": profile.profilePhoto ?? ""
//        ]
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: dict, options: [])
//        } catch {
//            print("⚠️ JSON encoding error:", error.localizedDescription)
//            completion(nil)
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("❌ Network error:", error.localizedDescription)
//                DispatchQueue.main.async { completion(nil) }
//                return
//            }
//
//            guard let data = data else {
//                print("⚠️ Empty response from server")
//                DispatchQueue.main.async { completion(nil) }
//                return
//            }
//
//            do {
//                let decoded = try JSONDecoder().decode(UpdateProfileResponse.self, from: data)
//                if decoded.success, let user = decoded.user {
//                    print("✅ Created new profile:", user.displayName)
//                    DispatchQueue.main.async { completion(user) }
//                } else {
//                    print("⚠️ Creation failed:", decoded.message ?? "Unknown error")
//                    DispatchQueue.main.async { completion(nil) }
//                }
//            } catch {
//                print("❌ POST Decoding Error:", error.localizedDescription)
//                DispatchQueue.main.async { completion(nil) }
//            }
//        }.resume()
//    }
//}
//
//  ProfileAPI.swift
//  NetSwipe
//
//  Created by ROSZHAN RAJ
//
//  ✅ JSON-only backend (no Cloudinary)
//  ✅ Sends simulator photo as base64 in `profilePhoto`
//  ✅ Matches backend routes: /profile & /profile/update
//  ✅ Uses UpdateProfileResponse & ProfileResponse
//

import Foundation
import UIKit

@MainActor
final class ProfileAPI {
    static let shared = ProfileAPI()
    private init() {}

    // ⚙️ For simulator: localhost works; for real device use your Mac’s LAN IP
    private let baseURL = "http://192.168.1.23:5001"

    // MARK: - 🟢 Update or Complete Profile Setup
    func updateProfile(_ profile: Profile, completion: @escaping (Profile?) -> Void) {
        guard let url = URL(string: "\(baseURL)/profile/update") else {
            print("❌ Invalid URL for /profile/update")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // ---- 📸 Decide what to send in profilePhoto ----
        // 1. If we have local imageData (chosen from Photos), encode as base64.
        // 2. Else fall back to any existing profilePhoto string (URL or base64).
        var profilePhotoString = profile.profilePhoto ?? ""
        if let data = profile.imageData, !data.isEmpty {
            profilePhotoString = data.base64EncodedString()
        }

        // Build body dictionary (backend accepts CSV string OR array for interests)
        let body: [String: Any] = [
            "userId": profile.id,
            "name": profile.name ?? "",
            "interests": profile.interests ?? [],
            "bio": profile.description ?? "",
            "location": profile.location ?? "",
            "profilePhoto": profilePhotoString
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("⚠️ JSON encoding error:", error.localizedDescription)
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                completion(nil)
                return
            }

            guard let data = data else {
                print("⚠️ Empty response from server")
                completion(nil)
                return
            }

            do {
                let decoded = try JSONDecoder().decode(UpdateProfileResponse.self, from: data)
                if decoded.success, var user = decoded.user {
                    // If server echoed back the same base64 string, also keep it in imageData
                    if let photo = user.profilePhoto,
                       let imgData = Data(base64Encoded: photo) {
                        user.imageData = imgData
                    }
                    print("✅ Profile updated successfully:", user.displayName)
                    completion(user)
                } else {
                    print("⚠️ Update failed:", decoded.message ?? "Unknown error")
                    completion(nil)
                }
            } catch {
                print("❌ POST Decoding Error:", error.localizedDescription)
                if let raw = String(data: data, encoding: .utf8) {
                    print("🧾 Raw response:", raw)
                }
                completion(nil)
            }
        }.resume()
    }

    // MARK: - 🟣 Fetch All Profiles
    func fetchProfiles(completion: @escaping ([Profile]) -> Void) {
        guard let url = URL(string: "\(baseURL)/profile") else {
            print("❌ Invalid URL for /profile")
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                completion([])
                return
            }

            guard let data = data else {
                print("⚠️ Empty response from server")
                completion([])
                return
            }

            do {
                let decoded = try JSONDecoder().decode(ProfileResponse.self, from: data)
                if decoded.success, let users = decoded.users {
                    // Try to hydrate imageData from base64 if present
                    let hydrated = users.map { profile -> Profile in
                        var p = profile
                        if let photo = p.profilePhoto,
                           let imgData = Data(base64Encoded: photo) {
                            p.imageData = imgData
                        }
                        return p
                    }

                    print("✅ Loaded profiles:", hydrated.count)
                    completion(hydrated)
                } else {
                    print("⚠️ No users found or success=false")
                    completion([])
                }
            } catch {
                print("❌ GET Decoding Error:", error.localizedDescription)
                if let raw = String(data: data, encoding: .utf8) {
                    print("🧾 Raw response:", raw)
                }
                completion([])
            }
        }.resume()
    }

    // MARK: - 🟠 Optional: Create Profile (if you ever add /profile/create)
    func createProfile(_ profile: Profile, completion: @escaping (Profile?) -> Void) {
        guard let url = URL(string: "\(baseURL)/profile/create") else {
            print("❌ Invalid URL for /profile/create")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var profilePhotoString = profile.profilePhoto ?? ""
        if let data = profile.imageData, !data.isEmpty {
            profilePhotoString = data.base64EncodedString()
        }

        let body: [String: Any] = [
            "name": profile.name ?? "",
            "bio": profile.description ?? "",
            "interests": profile.interests ?? [],
            "profilePhoto": profilePhotoString
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("⚠️ JSON encoding error:", error.localizedDescription)
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                completion(nil)
                return
            }

            guard let data = data else {
                print("⚠️ Empty response from server")
                completion(nil)
                return
            }

            do {
                let decoded = try JSONDecoder().decode(UpdateProfileResponse.self, from: data)
                if decoded.success, var user = decoded.user {
                    if let photo = user.profilePhoto,
                       let imgData = Data(base64Encoded: photo) {
                        user.imageData = imgData
                    }
                    print("✅ Created new profile:", user.displayName)
                    completion(user)
                } else {
                    print("⚠️ Creation failed:", decoded.message ?? "Unknown error")
                    completion(nil)
                }
            } catch {
                print("❌ POST Decoding Error:", error.localizedDescription)
                completion(nil)
            }
        }.resume()
    }
}
