////
////  FakeUserLoader.swift
////  NetSwipe
////
////  Reads local FakeUsers.csv and converts into [Profile] for demo swipe cards
////
//
//import Foundation
//
//private extension String {
//    /// Trim spaces, quotes, and newlines around CSV fields
//    var trimmedCSV: String {
//        trimmingCharacters(in: CharacterSet(charactersIn: " \"\n\r\t"))
//    }
//}
//
//struct FakeUserLoader {
//    
//    static func loadCSV() -> [Profile] {
//        // 🔹 CSV file in bundle: FakeUsers.csv
//        guard let url = Bundle.main.url(forResource: "FakeUsers", withExtension: "csv") else {
//            print("❌ CSV file FakeUsers.csv not found in bundle")
//            return []
//        }
//        
//        do {
//            let raw = try String(contentsOf: url)
//            
//            // Split into non-empty lines
//            let lines = raw
//                .components(separatedBy: .newlines)
//                .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
//            
//            guard !lines.isEmpty else { return [] }
//            
//            // Header row: name,username,bio,interests,profilePhoto
//            let headerCols = parseCSVRow(lines[0])
//            let nameIndex       = headerCols.firstIndex(of: "name")         ?? 0
//            let usernameIndex   = headerCols.firstIndex(of: "username")     ?? 1
//            let bioIndex        = headerCols.firstIndex(of: "bio")          ?? 2
//            let interestsIndex  = headerCols.firstIndex(of: "interests")    ?? 3
//            let photoIndex      = headerCols.firstIndex(of: "profilePhoto") ?? 4
//            
//            var profiles: [Profile] = []
//            
//            // Data rows
//            for line in lines.dropFirst() {
//                let cols = parseCSVRow(line)
//                // Expect at least 5 columns
//                guard cols.count > max(nameIndex, usernameIndex, bioIndex, interestsIndex, photoIndex) else {
//                    print("⚠️ Skipping row (not enough columns): \(line)")
//                    continue
//                }
//                
//                let name      = cols[nameIndex].trimmedCSV
//                let username  = cols[usernameIndex].trimmedCSV
//                let bio       = cols[bioIndex].trimmedCSV
//                let interestsRaw = cols[interestsIndex].trimmedCSV   // "UX,Figma,Spotify"
//                let photoURL  = cols[photoIndex].trimmedCSV          // https://...
//                
//                let interests = interestsRaw
//                    .split(separator: ",")
//                    .map { String($0).trimmedCSV }
//                    .filter { !$0.isEmpty }
//                
//                let profile = Profile(
//                    id: "fake-\(UUID().uuidString)",
//                    email: nil,
//                    username: username,
//                    verified: false,
//                    name: name,
//                    description: bio,
//                    interests: interests,
//                    profilePhoto: photoURL,
//                    location: nil,
//                    isProfileComplete: true,
//                    createdAt: nil,
//                    updatedAt: nil,
//                    imageData: nil,
//                    profileCompleted: true
//                )
//                
//                profiles.append(profile)
//            }
//            
//            print("✅ Loaded \(profiles.count) fake profiles from CSV")
//            return profiles
//            
//        } catch {
//            print("❌ CSV read error:", error.localizedDescription)
//            return []
//        }
//    }
//    
//    /// Simple CSV parser that respects quotes like:
//    /// Victoria Lopez,vickyl,Music fan,"UX,Figma,Spotify",https://...
//    private static func parseCSVRow(_ line: String) -> [String] {
//        var result: [String] = []
//        var current = ""
//        var insideQuotes = false
//        
//        for char in line {
//            if char == "\"" {
//                insideQuotes.toggle()
//            } else if char == "," && !insideQuotes {
//                result.append(current)
//                current = ""
//            } else {
//                current.append(char)
//            }
//        }
//        result.append(current)
//        return result
//    }
//}
//
//  FakeUserLoader.swift
//  NetSwipe
//
//  Reads local FakeUsers.csv and converts into [Profile] for demo swipe cards
//

import Foundation

private extension String {
    /// Trim spaces, quotes, and newlines around CSV fields
    var trimmedCSV: String {
        trimmingCharacters(in: CharacterSet(charactersIn: " \"\n\r\t"))
    }
}

struct FakeUserLoader {

    // MARK: - Static cache
    /// We only want to parse CSV once per app run to avoid any strange
    /// re-parsing side-effects (and keep ids stable).
    private static var cachedProfiles: [Profile]? = nil

    // 🔹 Pool of CS-related interests we can use
    private static let csInterestPool: [String] = [
        "Machine Learning",
        "Data Science",
        "Full-Stack Development",
        "iOS / SwiftUI",
        "Backend Engineering",
        "Frontend Engineering",
        "Cloud Computing",
        "Distributed Systems",
        "Computer Vision",
        "AR / VR",
        "Cybersecurity",
        "Algorithms & DS",
        "Databases & SQL",
        "DevOps",
        "UI / UX Design",
        "Product Engineering",
        "Research & Prototyping"
    ]

    /// Keywords that mark an interest as already CS-related
    private static let csKeywordFragments: [String] = [
        "swift", "react", "node", "js", "python", "ai", "ml",
        "data", "cloud", "dev", "engineer", "sql", "database",
        "db", "vr", "ar", "robot", "frontend", "backend",
        "full", "ui", "ux", "security", "network", "ios",
        "android", "web", "software", "coding", "program",
        "algorithm", "system", "cs", "compute"
    ]

    // MARK: - Public API

    static func loadCSV() -> [Profile] {
        // If we already parsed once, just reuse those profiles.
        if let cached = cachedProfiles {
            return cached
        }

        // 🔹 CSV file in bundle: FakeUsers.csv
        guard let url = Bundle.main.url(forResource: "FakeUsers", withExtension: "csv") else {
            print("❌ CSV file FakeUsers.csv not found in bundle")
            cachedProfiles = []
            return []
        }

        do {
            let raw = try String(contentsOf: url)

            // Split into non-empty lines
            let lines = raw
                .components(separatedBy: .newlines)
                .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

            guard !lines.isEmpty else {
                cachedProfiles = []
                return []
            }

            // Header row: name,username,bio,interests,profilePhoto
            let headerCols = parseCSVRow(lines[0])
            let nameIndex       = headerCols.firstIndex(of: "name")         ?? 0
            let usernameIndex   = headerCols.firstIndex(of: "username")     ?? 1
            let bioIndex        = headerCols.firstIndex(of: "bio")          ?? 2
            let interestsIndex  = headerCols.firstIndex(of: "interests")    ?? 3
            let photoIndex      = headerCols.firstIndex(of: "profilePhoto") ?? 4

            var profiles: [Profile] = []

            // Data rows
            for (rowIdx, line) in lines.dropFirst().enumerated() {
                let cols = parseCSVRow(line)

                // Expect at least up to the max header index
                guard cols.count > max(nameIndex, usernameIndex, bioIndex, interestsIndex, photoIndex) else {
                    print("⚠️ Skipping row (not enough columns): \(line)")
                    continue
                }

                let name         = cols[nameIndex].trimmedCSV
                let username     = cols[usernameIndex].trimmedCSV
                let bio          = cols[bioIndex].trimmedCSV
                let interestsRaw = cols[interestsIndex].trimmedCSV   // "UX,Figma,Spotify"
                let photoURL     = cols[photoIndex].trimmedCSV        // https://...

                // Split raw interests, then convert to CS-focused tags
                let rawTokens = interestsRaw
                    .split(separator: ",")
                    .map { String($0).trimmedCSV }
                    .filter { !$0.isEmpty }

                let interests = mapToCSInterests(rawTokens, seed: username.isEmpty ? "row-\(rowIdx)" : username)

                // 🔹 Stable fake id so per-user swipe history behaves nicely
                let stableIdBase = username.isEmpty ? "fake-row-\(rowIdx)" : "fake-\(username.lowercased())"
                let stableId = stableIdBase.replacingOccurrences(of: " ", with: "-")

                let profile = Profile(
                    id: stableId,
                    email: nil,
                    username: username,
                    verified: false,
                    name: name,
                    description: bio,
                    interests: interests,
                    profilePhoto: photoURL,   // full URL or relative path
                    location: nil,
                    isProfileComplete: true,
                    createdAt: nil,
                    updatedAt: nil,
                    imageData: nil,
                    profileCompleted: true,
                    localImageName: nil
                )

                profiles.append(profile)
            }

            print("✅ Loaded \(profiles.count) fake profiles from CSV")
            cachedProfiles = profiles
            return profiles

        } catch {
            print("❌ CSV read error:", error.localizedDescription)
            cachedProfiles = []
            return []
        }
    }

    // MARK: - CSV parsing

    /// Simple CSV parser that respects quotes like:
    /// Victoria Lopez,vickyl,Music fan,"UX,Figma,Spotify",https://...
    private static func parseCSVRow(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var insideQuotes = false

        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                result.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        result.append(current)
        return result
    }

    // MARK: - CS Interest Mapping

    /// Keep any obviously-CS interests from the CSV, and replace the rest
    /// with CS-related tags from `csInterestPool`. Uses a seed so results
    /// are stable for the same username across runs.
    private static func mapToCSInterests(_ raw: [String], seed: String) -> [String] {
        // Keep tokens that already look CS-related
        var result: [String] = raw.filter { isCSInterest($0) }

        // We want at least 2 and at most 4 tags per profile
        let desiredCount = min(4, max(2, raw.count))
        var needed = desiredCount - result.count

        // Deterministic seed per user (so interests don't shuffle randomly)
        var hash = abs(seed.hashValue)

        while needed > 0 {
            let idx = hash % csInterestPool.count
            let candidate = csInterestPool[idx]
            if !result.contains(where: { $0.caseInsensitiveCompare(candidate) == .orderedSame }) {
                result.append(candidate)
                needed -= 1
            }
            hash &+= 1
        }

        return result
    }

    private static func isCSInterest(_ s: String) -> Bool {
        let lower = s.lowercased()
        return csKeywordFragments.contains { lower.contains($0) }
    }
}
