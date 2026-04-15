//////
//////  LikedUsersView.swift
//////  NetSwipe
//////
//////  Swift 6–safe version
//////  Fixes optional unwrapping for name & description
//////
////
////import SwiftUI
////import UIKit
////
////struct LikedUsersView: View {
////    @Binding var likedProfiles: [Profile]
////    @State private var selectedProfile: Profile? = nil
////
////    var body: some View {
////        ZStack {
////            // MARK: - Background
////            LinearGradient(
////                gradient: Gradient(colors: [Color.purple.opacity(0.9), Color.black]),
////                startPoint: .topLeading,
////                endPoint: .bottomTrailing
////            )
////            .ignoresSafeArea()
////
////            VStack(alignment: .leading) {
////                // MARK: - Header
////                Text("People You Liked")
////                    .font(.title)
////                    .bold()
////                    .foregroundColor(.white)
////                    .padding(.top, 40)
////                    .padding(.horizontal)
////
////                // MARK: - Empty State
////                if likedProfiles.isEmpty {
////                    Spacer()
////                    Text("No liked profiles yet.")
////                        .foregroundColor(.white.opacity(0.6))
////                        .frame(maxWidth: .infinity, alignment: .center)
////                    Spacer()
////                } else {
////                    // MARK: - List of Liked Profiles
////                    ScrollView {
////                        VStack(spacing: 16) {
////                            ForEach(likedProfiles) { profile in
////                                Button {
////                                    selectedProfile = profile
////                                } label: {
////                                    profileRow(profile)
////                                }
////                                .buttonStyle(.plain)
////                            }
////                        }
////                        .padding(.top)
////                    }
////                }
////
////                Spacer()
////            }
////
////            // MARK: - Popup when tapped
////            if let profile = selectedProfile {
////                ZStack {
////                    Color.black.opacity(0.6)
////                        .ignoresSafeArea()
////                        .onTapGesture { selectedProfile = nil }
////
////                    VStack(spacing: 16) {
////                        avatarView(profilePhoto: profile.profilePhoto, imageData: profile.imageData)
////                            .frame(width: 120, height: 120)
////
////                        // ✅ Safe unwraps for optionals
////                        Text((profile.name ?? "").isEmpty ? "Unknown User" : (profile.name ?? "Unknown User"))
////                            .font(.title2)
////                            .bold()
////                            .foregroundColor(.white)
////
////                        Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
////                            .font(.subheadline)
////                            .foregroundColor(.white.opacity(0.8))
////                            .multilineTextAlignment(.center)
////                            .padding(.horizontal, 12)
////
////                        Button("Close") {
////                            withAnimation { selectedProfile = nil }
////                        }
////                        .foregroundColor(.white)
////                        .padding(.vertical, 8)
////                        .padding(.horizontal, 24)
////                        .background(Color.red)
////                        .cornerRadius(10)
////                    }
////                    .padding()
////                    .frame(maxWidth: 300)
////                    .background(Color.black.opacity(0.85))
////                    .cornerRadius(16)
////                    .shadow(radius: 10)
////                }
////                .transition(.opacity.combined(with: .scale))
////                .animation(.easeInOut, value: selectedProfile)
////            }
////        }
////    }
////
////    // MARK: - Row
////    @ViewBuilder
////    private func profileRow(_ profile: Profile) -> some View {
////        HStack(spacing: 12) {
////            avatarView(profilePhoto: profile.profilePhoto, imageData: profile.imageData)
////                .frame(width: 60, height: 60)
////
////            VStack(alignment: .leading, spacing: 4) {
////                // ✅ Safe unwrap
////                Text((profile.name ?? "").isEmpty ? "Unknown User" : (profile.name ?? "Unknown User"))
////                    .font(.headline)
////                    .foregroundColor(.black)
////
////                Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
////                    .font(.subheadline)
////                    .foregroundColor(.gray)
////                    .lineLimit(2)
////            }
////            Spacer()
////        }
////        .padding()
////        .background(Color.white)
////        .cornerRadius(12)
////        .shadow(radius: 3)
////        .padding(.horizontal)
////    }
////
////    // MARK: - Avatar View
////    @ViewBuilder
////    private func avatarView(profilePhoto: String?, imageData: Data?) -> some View {
////        if let data = imageData, let ui = UIImage(data: data) {
////            Image(uiImage: ui)
////                .resizable()
////                .scaledToFill()
////                .clipShape(Circle())
////                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
////        }
////        else if let urlString = profilePhoto, let url = URL(string: urlString) {
////            AsyncImage(url: url) { phase in
////                switch phase {
////                case .success(let image):
////                    image
////                        .resizable()
////                        .scaledToFill()
////                case .failure(_):
////                    Circle()
////                        .fill(Color.gray.opacity(0.3))
////                        .overlay(
////                            Image(systemName: "person.fill")
////                                .foregroundColor(.white)
////                        )
////                default:
////                    ZStack {
////                        Circle().fill(Color.gray.opacity(0.3))
////                        ProgressView()
////                    }
////                }
////            }
////            .clipShape(Circle())
////            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
////        }
////        else {
////            Circle()
////                .fill(Color.gray.opacity(0.3))
////                .overlay(
////                    Image(systemName: "person.fill")
////                        .foregroundColor(.white)
////                )
////        }
////    }
////}
////
////// MARK: - Preview
////#Preview {
////    LikedUsersView(likedProfiles: .constant(sampleProfiles))
////}
//////
//////  LikedUsersView.swift
//////  NetSwipe
//////
//////  Swift 6–safe version
//////  ✅ Two top tabs: Liked / Matched
//////  ✅ Restart Swiping button clears local swipe state + likes + matches UI
//////
////
////import SwiftUI
////import UIKit
////
////struct LikedUsersView: View {
////    @EnvironmentObject var authViewModel: AuthViewModel
////
////    @Binding var likedProfiles: [Profile]
////    @State private var selectedProfile: Profile? = nil
////
////    // ✅ top tab selector
////    private enum TopTab: String, CaseIterable {
////        case liked = "Liked"
////        case matched = "Matched"
////    }
////    @State private var selectedTab: TopTab = .liked
////
////    // ✅ restart nonce shared with SwipeScreen
////    @AppStorage("restartSwipingNonce") private var restartSwipingNonce: Int = 0
////
////    var body: some View {
////        ZStack {
////            backgroundView
////
////            VStack(alignment: .leading, spacing: 12) {
////
////                // MARK: - Header Row + Restart Button
////                HStack {
////                    Text(selectedTab == .liked ? "People You Liked" : "People You Matched")
////                        .font(.title)
////                        .bold()
////                        .foregroundColor(.white)
////
////                    Spacer()
////
////                    Button {
////                        restartAllSwiping()
////                    } label: {
////                        HStack(spacing: 6) {
////                            Image(systemName: "arrow.counterclockwise")
////                            Text("Restart Swiping")
////                        }
////                        .font(.subheadline.bold())
////                        .foregroundColor(.white)
////                        .padding(.vertical, 6)
////                        .padding(.horizontal, 10)
////                        .background(Color.red.opacity(0.9))
////                        .cornerRadius(10)
////                    }
////                }
////                .padding(.top, 40)
////                .padding(.horizontal)
////
////                // MARK: - Segmented Tabs
////                Picker("", selection: $selectedTab) {
////                    ForEach(TopTab.allCases, id: \.self) { tab in
////                        Text(tab.rawValue).tag(tab)
////                    }
////                }
////                .pickerStyle(.segmented)
////                .padding(.horizontal)
////
////                // MARK: - Content
////                Group {
////                    if selectedTab == .liked {
////                        likedSection
////                    } else {
////                        matchedSection
////                    }
////                }
////
////                Spacer()
////            }
////
////            // MARK: - Popup when tapped
////            if let profile = selectedProfile {
////                popup(profile)
////            }
////        }
////    }
////}
////
////// MARK: - Sections
////private extension LikedUsersView {
////
////    var likedSection: some View {
////        Group {
////            if likedProfiles.isEmpty {
////                Spacer()
////                Text("No liked profiles yet.")
////                    .foregroundColor(.white.opacity(0.6))
////                    .frame(maxWidth: .infinity, alignment: .center)
////                Spacer()
////            } else {
////                ScrollView {
////                    VStack(spacing: 16) {
////                        ForEach(likedProfiles) { profile in
////                            Button {
////                                selectedProfile = profile
////                            } label: {
////                                profileRow(profile)
////                            }
////                            .buttonStyle(.plain)
////                        }
////                    }
////                    .padding(.top)
////                }
////            }
////        }
////    }
////
////    var matchedSection: some View {
////        let matches = authViewModel.matches   // assumes you added matches in AuthViewModel
////        return Group {
////            if matches.isEmpty {
////                Spacer()
////                Text("No matches yet.")
////                    .foregroundColor(.white.opacity(0.6))
////                    .frame(maxWidth: .infinity, alignment: .center)
////                Spacer()
////            } else {
////                ScrollView {
////                    VStack(spacing: 16) {
////                        ForEach(matches) { profile in
////                            Button {
////                                selectedProfile = profile
////                            } label: {
////                                profileRow(profile)
////                            }
////                            .buttonStyle(.plain)
////                        }
////                    }
////                    .padding(.top)
////                }
////            }
////        }
////    }
////}
////
////// MARK: - UI pieces
////private extension LikedUsersView {
////
////    var backgroundView: some View {
////        LinearGradient(
////            gradient: Gradient(colors: [Color.purple.opacity(0.9), Color.black]),
////            startPoint: .topLeading,
////            endPoint: .bottomTrailing
////        )
////        .ignoresSafeArea()
////    }
////
////    @ViewBuilder
////    func popup(_ profile: Profile) -> some View {
////        ZStack {
////            Color.black.opacity(0.6)
////                .ignoresSafeArea()
////                .onTapGesture { selectedProfile = nil }
////
////            VStack(spacing: 16) {
////                avatarView(profilePhoto: profile.profilePhoto, imageData: profile.imageData)
////                    .frame(width: 120, height: 120)
////
////                Text((profile.name ?? "").isEmpty ? "Unknown User" : (profile.name ?? "Unknown User"))
////                    .font(.title2)
////                    .bold()
////                    .foregroundColor(.white)
////
////                Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
////                    .font(.subheadline)
////                    .foregroundColor(.white.opacity(0.8))
////                    .multilineTextAlignment(.center)
////                    .padding(.horizontal, 12)
////
////                Button("Close") {
////                    withAnimation { selectedProfile = nil }
////                }
////                .foregroundColor(.white)
////                .padding(.vertical, 8)
////                .padding(.horizontal, 24)
////                .background(Color.red)
////                .cornerRadius(10)
////            }
////            .padding()
////            .frame(maxWidth: 300)
////            .background(Color.black.opacity(0.85))
////            .cornerRadius(16)
////            .shadow(radius: 10)
////        }
////        .transition(.opacity.combined(with: .scale))
////        .animation(.easeInOut, value: selectedProfile)
////    }
////
////    @ViewBuilder
////    func profileRow(_ profile: Profile) -> some View {
////        HStack(spacing: 12) {
////            avatarView(profilePhoto: profile.profilePhoto, imageData: profile.imageData)
////                .frame(width: 60, height: 60)
////
////            VStack(alignment: .leading, spacing: 4) {
////                Text((profile.name ?? "").isEmpty ? "Unknown User" : (profile.name ?? "Unknown User"))
////                    .font(.headline)
////                    .foregroundColor(.black)
////
////                Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
////                    .font(.subheadline)
////                    .foregroundColor(.gray)
////                    .lineLimit(2)
////            }
////            Spacer()
////        }
////        .padding()
////        .background(Color.white)
////        .cornerRadius(12)
////        .shadow(radius: 3)
////        .padding(.horizontal)
////    }
////
////    @ViewBuilder
////    func avatarView(profilePhoto: String?, imageData: Data?) -> some View {
////        if let data = imageData, let ui = UIImage(data: data) {
////            Image(uiImage: ui)
////                .resizable()
////                .scaledToFill()
////                .clipShape(Circle())
////                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
////        }
////        else if let urlString = profilePhoto, let url = URL(string: urlString) {
////            AsyncImage(url: url) { phase in
////                switch phase {
////                case .success(let image):
////                    image.resizable().scaledToFill()
////                case .failure(_):
////                    Circle().fill(Color.gray.opacity(0.3))
////                        .overlay(Image(systemName: "person.fill").foregroundColor(.white))
////                default:
////                    ZStack {
////                        Circle().fill(Color.gray.opacity(0.3))
////                        ProgressView()
////                    }
////                }
////            }
////            .clipShape(Circle())
////            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
////        }
////        else {
////            Circle()
////                .fill(Color.gray.opacity(0.3))
////                .overlay(Image(systemName: "person.fill").foregroundColor(.white))
////        }
////    }
////
////    // MARK: - Restart logic
////    func restartAllSwiping() {
////        // Clear lightweight persisted swipe state
////        UserDefaults.standard.removeObject(forKey: "swipedProfileIds")
////        UserDefaults.standard.removeObject(forKey: "likedProfileIds")
////
////        // Reset UI lists
////        likedProfiles.removeAll()
////        selectedProfile = nil
////
////        // If you have matches in AuthViewModel, clear UI too
////        authViewModel.matches.removeAll()
////
////        // Bump nonce so SwipeScreen reloads a fresh deck
////        restartSwipingNonce += 1
////    }
////}
////
////// MARK: - Preview
////#Preview {
////    LikedUsersView(likedProfiles: .constant(sampleProfiles))
////        .environmentObject(AuthViewModel())
////}
////
//////  LikedUsersView.swift
//////  NetSwipe
//////
//////  Swift 6–safe version
//////  ✅ Two top tabs: Liked / Matched
//////  ✅ Restart Swiping clears local swipe state + likes + matches UI
//////  ✅ FIX: avatarView supports imageData, base64/dataURL, relative URLs, normal URLs
//////
////
////import SwiftUI
////import UIKit
////
////struct LikedUsersView: View {
////    @EnvironmentObject var authViewModel: AuthViewModel
////
////    @Binding var likedProfiles: [Profile]
////    @State private var selectedProfile: Profile? = nil
////
////    // ✅ top tab selector
////    private enum TopTab: String, CaseIterable {
////        case liked = "Liked"
////        case matched = "Matched"
////    }
////    @State private var selectedTab: TopTab = .liked
////
////    // ✅ restart nonce shared with SwipeScreen
////    @AppStorage("restartSwipingNonce") private var restartSwipingNonce: Int = 0
////
////    var body: some View {
////        ZStack {
////            backgroundView
////
////            VStack(alignment: .leading, spacing: 12) {
////
////                // MARK: - Header Row + Restart Button
////                HStack {
////                    Text(selectedTab == .liked ? "People You Liked" : "People You Matched")
////                        .font(.title)
////                        .bold()
////                        .foregroundColor(.white)
////
////                    Spacer()
////
////                    Button {
////                        restartAllSwiping()
////                    } label: {
////                        HStack(spacing: 6) {
////                            Image(systemName: "arrow.counterclockwise")
////                            Text("Restart Swiping")
////                        }
////                        .font(.subheadline.bold())
////                        .foregroundColor(.white)
////                        .padding(.vertical, 6)
////                        .padding(.horizontal, 10)
////                        .background(Color.red.opacity(0.9))
////                        .cornerRadius(10)
////                    }
////                }
////                .padding(.top, 40)
////                .padding(.horizontal)
////
////                // MARK: - Segmented Tabs
////                Picker("", selection: $selectedTab) {
////                    ForEach(TopTab.allCases, id: \.self) { tab in
////                        Text(tab.rawValue).tag(tab)
////                    }
////                }
////                .pickerStyle(.segmented)
////                .padding(.horizontal)
////
////                // MARK: - Content
////                Group {
////                    if selectedTab == .liked {
////                        likedSection
////                    } else {
////                        matchedSection
////                    }
////                }
////
////                Spacer()
////            }
////
////            // MARK: - Popup when tapped
////            if let profile = selectedProfile {
////                popup(profile)
////            }
////        }
////    }
////}
////
////// MARK: - Sections
////private extension LikedUsersView {
////
////    var likedSection: some View {
////        Group {
////            if likedProfiles.isEmpty {
////                Spacer()
////                Text("No liked profiles yet.")
////                    .foregroundColor(.white.opacity(0.6))
////                    .frame(maxWidth: .infinity, alignment: .center)
////                Spacer()
////            } else {
////                ScrollView {
////                    VStack(spacing: 16) {
////                        ForEach(likedProfiles) { profile in
////                            Button {
////                                selectedProfile = profile
////                            } label: {
////                                profileRow(profile)
////                            }
////                            .buttonStyle(.plain)
////                        }
////                    }
////                    .padding(.top)
////                }
////            }
////        }
////    }
////
////    var matchedSection: some View {
////        let matches = authViewModel.matches
////
////        return Group {
////            if matches.isEmpty {
////                Spacer()
////                Text("No matches yet.")
////                    .foregroundColor(.white.opacity(0.6))
////                    .frame(maxWidth: .infinity, alignment: .center)
////                Spacer()
////            } else {
////                ScrollView {
////                    VStack(spacing: 16) {
////                        ForEach(matches) { profile in
////                            Button {
////                                selectedProfile = profile
////                            } label: {
////                                profileRow(profile)
////                            }
////                            .buttonStyle(.plain)
////                        }
////                    }
////                    .padding(.top)
////                }
////            }
////        }
////    }
////}
////
////// MARK: - UI pieces
////private extension LikedUsersView {
////
////    var backgroundView: some View {
////        LinearGradient(
////            gradient: Gradient(colors: [Color.purple.opacity(0.9), Color.black]),
////            startPoint: .topLeading,
////            endPoint: .bottomTrailing
////        )
////        .ignoresSafeArea()
////    }
////
////    @ViewBuilder
////    func popup(_ profile: Profile) -> some View {
////        ZStack {
////            Color.black.opacity(0.6)
////                .ignoresSafeArea()
////                .onTapGesture { selectedProfile = nil }
////
////            VStack(spacing: 16) {
////                avatarView(profilePhoto: profile.profilePhoto, imageData: profile.imageData)
////                    .frame(width: 120, height: 120)
////
////                Text((profile.name ?? "").isEmpty ? "Unknown User" : (profile.name ?? "Unknown User"))
////                    .font(.title2)
////                    .bold()
////                    .foregroundColor(.white)
////
////                Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
////                    .font(.subheadline)
////                    .foregroundColor(.white.opacity(0.8))
////                    .multilineTextAlignment(.center)
////                    .padding(.horizontal, 12)
////
////                Button("Close") {
////                    withAnimation { selectedProfile = nil }
////                }
////                .foregroundColor(.white)
////                .padding(.vertical, 8)
////                .padding(.horizontal, 24)
////                .background(Color.red)
////                .cornerRadius(10)
////            }
////            .padding()
////            .frame(maxWidth: 300)
////            .background(Color.black.opacity(0.85))
////            .cornerRadius(16)
////            .shadow(radius: 10)
////        }
////        .transition(.opacity.combined(with: .scale))
////        .animation(.easeInOut, value: selectedProfile)
////    }
////
////    @ViewBuilder
////    func profileRow(_ profile: Profile) -> some View {
////        HStack(spacing: 12) {
////            avatarView(profilePhoto: profile.profilePhoto, imageData: profile.imageData)
////                .frame(width: 60, height: 60)
////
////            VStack(alignment: .leading, spacing: 4) {
////                Text((profile.name ?? "").isEmpty ? "Unknown User" : (profile.name ?? "Unknown User"))
////                    .font(.headline)
////                    .foregroundColor(.black)
////
////                Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
////                    .font(.subheadline)
////                    .foregroundColor(.gray)
////                    .lineLimit(2)
////            }
////            Spacer()
////        }
////        .padding()
////        .background(Color.white)
////        .cornerRadius(12)
////        .shadow(radius: 3)
////        .padding(.horizontal)
////    }
////
////    // ✅ FIXED Avatar View (NO explicit returns)
////    @ViewBuilder
////    func avatarView(profilePhoto: String?, imageData: Data?) -> some View {
////
////        // 1) Local imageData
////        if let data = imageData, let ui = UIImage(data: data) {
////            Image(uiImage: ui)
////                .resizable()
////                .scaledToFill()
////                .clipShape(Circle())
////                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
////
////        // 2) base64/dataURL from backend
////        } else if let photo = profilePhoto,
////                  let base64Img = decodeBase64Image(photo) {
////            Image(uiImage: base64Img)
////                .resizable()
////                .scaledToFill()
////                .clipShape(Circle())
////                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
////
////        // 3) URL / relative path
////        } else if let photo = profilePhoto,
////                  let url = normalizedPhotoURL(photo) {
////            AsyncImage(url: url) { phase in
////                switch phase {
////                case .success(let image):
////                    image.resizable().scaledToFill()
////
////                case .failure(_):
////                    Circle()
////                        .fill(Color.gray.opacity(0.3))
////                        .overlay(
////                            Image(systemName: "person.fill")
////                                .foregroundColor(.white)
////                        )
////
////                default:
////                    ZStack {
////                        Circle().fill(Color.gray.opacity(0.3))
////                        ProgressView()
////                    }
////                }
////            }
////            .clipShape(Circle())
////            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
////
////        // 4) fallback
////        } else {
////            Circle()
////                .fill(Color.gray.opacity(0.3))
////                .overlay(
////                    Image(systemName: "person.fill")
////                        .foregroundColor(.white)
////                )
////        }
////    }
////
////    // MARK: - Helpers
////
////    /// Decode "data:image/...;base64,XXXX" or raw base64 into UIImage
////    func decodeBase64Image(_ input: String) -> UIImage? {
////        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
////        guard !trimmed.isEmpty else { return nil }
////
////        let base64String: String
////        if let range = trimmed.range(of: "base64,") {
////            base64String = String(trimmed[range.upperBound...])
////        } else {
////            base64String = trimmed
////        }
////
////        guard let data = Data(base64Encoded: base64String),
////              let img = UIImage(data: data) else {
////            return nil
////        }
////        return img
////    }
////
////    /// Convert relative paths to absolute URLs
////    func normalizedPhotoURL(_ input: String) -> URL? {
////        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
////        guard !trimmed.isEmpty else { return nil }
////
////        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
////            return URL(string: trimmed)
////        }
////
////        let serverBase = "http://192.168.1.23:5001"
////        let fixed = trimmed.hasPrefix("/") ? "\(serverBase)\(trimmed)" : "\(serverBase)/\(trimmed)"
////        return URL(string: fixed)
////    }
////
////    // MARK: - Restart logic
////    func restartAllSwiping() {
////        UserDefaults.standard.removeObject(forKey: "swipedProfileIds")
////        UserDefaults.standard.removeObject(forKey: "likedProfileIds")
////
////        likedProfiles.removeAll()
////        selectedProfile = nil
////        authViewModel.matches.removeAll()
////
////        restartSwipingNonce += 1
////    }
////}
////
////// MARK: - Preview
////#Preview {
////    LikedUsersView(likedProfiles: .constant(sampleProfiles))
////        .environmentObject(AuthViewModel())
////}
////  LikedUsersView.swift
////  NetSwipe
////
////  Swift 6–safe version
////  ✅ Two top tabs: Liked / Matched
////  ✅ Restart Swiping clears local swipe state + likes + matches UI
////  ✅ Also calls AuthViewModel.restartSwipingLocalReset() to clear matches + chats
////
//
//import SwiftUI
//import UIKit
//
//struct LikedUsersView: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//
//    @Binding var likedProfiles: [Profile]
//    @State private var selectedProfile: Profile? = nil
//
//    // ✅ top tab selector
//    private enum TopTab: String, CaseIterable {
//        case liked = "Liked"
//        case matched = "Matched"
//    }
//    @State private var selectedTab: TopTab = .liked
//
//    // ✅ restart nonce shared with SwipeScreen
//    @AppStorage("restartSwipingNonce") private var restartSwipingNonce: Int = 0
//
//    var body: some View {
//        ZStack {
//            backgroundView
//
//            VStack(alignment: .leading, spacing: 12) {
//
//                // MARK: - Header Row + Restart Button
//                HStack {
//                    Text(selectedTab == .liked ? "People You Liked" : "People You Matched")
//                        .font(.title)
//                        .bold()
//                        .foregroundColor(.white)
//
//                    Spacer()
//
//                    Button {
//                        restartAllSwiping()
//                    } label: {
//                        HStack(spacing: 6) {
//                            Image(systemName: "arrow.counterclockwise")
//                            Text("Restart Swiping")
//                        }
//                        .font(.subheadline.bold())
//                        .foregroundColor(.white)
//                        .padding(.vertical, 6)
//                        .padding(.horizontal, 10)
//                        .background(Color.red.opacity(0.9))
//                        .cornerRadius(10)
//                    }
//                }
//                .padding(.top, 40)
//                .padding(.horizontal)
//
//                // MARK: - Segmented Tabs
//                Picker("", selection: $selectedTab) {
//                    ForEach(TopTab.allCases, id: \.self) { tab in
//                        Text(tab.rawValue).tag(tab)
//                    }
//                }
//                .pickerStyle(.segmented)
//                .padding(.horizontal)
//
//                // MARK: - Content
//                Group {
//                    if selectedTab == .liked {
//                        likedSection
//                    } else {
//                        matchedSection
//                    }
//                }
//
//                Spacer()
//            }
//
//            // MARK: - Popup when tapped
//            if let profile = selectedProfile {
//                popup(profile)
//            }
//        }
//    }
//}
//
//// MARK: - Sections
//private extension LikedUsersView {
//
//    var likedSection: some View {
//        Group {
//            if likedProfiles.isEmpty {
//                Spacer()
//                Text("No liked profiles yet.")
//                    .foregroundColor(.white.opacity(0.6))
//                    .frame(maxWidth: .infinity, alignment: .center)
//                Spacer()
//            } else {
//                ScrollView {
//                    VStack(spacing: 16) {
//                        ForEach(likedProfiles) { profile in
//                            Button {
//                                selectedProfile = profile
//                            } label: {
//                                profileRow(profile)
//                            }
//                            .buttonStyle(.plain)
//                        }
//                    }
//                    .padding(.top)
//                }
//            }
//        }
//    }
//
//    var matchedSection: some View {
//        let matches = authViewModel.matches
//
//        return Group {
//            if matches.isEmpty {
//                Spacer()
//                Text("No matches yet.")
//                    .foregroundColor(.white.opacity(0.6))
//                    .frame(maxWidth: .infinity, alignment: .center)
//                Spacer()
//            } else {
//                ScrollView {
//                    VStack(spacing: 16) {
//                        ForEach(matches) { profile in
//                            Button {
//                                selectedProfile = profile
//                            } label: {
//                                profileRow(profile)
//                            }
//                            .buttonStyle(.plain)
//                        }
//                    }
//                    .padding(.top)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - UI pieces
//private extension LikedUsersView {
//
//    var backgroundView: some View {
//        LinearGradient(
//            gradient: Gradient(colors: [Color.purple.opacity(0.9), Color.black]),
//            startPoint: .topLeading,
//            endPoint: .bottomTrailing
//        )
//        .ignoresSafeArea()
//    }
//
//    @ViewBuilder
//    func popup(_ profile: Profile) -> some View {
//        ZStack {
//            Color.black.opacity(0.6)
//                .ignoresSafeArea()
//                .onTapGesture { selectedProfile = nil }
//
//            VStack(spacing: 16) {
//                avatarView(profilePhoto: profile.profilePhoto, imageData: profile.imageData)
//                    .frame(width: 120, height: 120)
//
//                Text((profile.name ?? "").isEmpty ? "Unknown User" : (profile.name ?? "Unknown User"))
//                    .font(.title2)
//                    .bold()
//                    .foregroundColor(.white)
//
//                Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
//                    .font(.subheadline)
//                    .foregroundColor(.white.opacity(0.8))
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 12)
//
//                Button("Close") {
//                    withAnimation { selectedProfile = nil }
//                }
//                .foregroundColor(.white)
//                .padding(.vertical, 8)
//                .padding(.horizontal, 24)
//                .background(Color.red)
//                .cornerRadius(10)
//            }
//            .padding()
//            .frame(maxWidth: 300)
//            .background(Color.black.opacity(0.85))
//            .cornerRadius(16)
//            .shadow(radius: 10)
//        }
//        .transition(.opacity.combined(with: .scale))
//        .animation(.easeInOut, value: selectedProfile)
//    }
//
//    @ViewBuilder
//    func profileRow(_ profile: Profile) -> some View {
//        HStack(spacing: 12) {
//            avatarView(profilePhoto: profile.profilePhoto, imageData: profile.imageData)
//                .frame(width: 60, height: 60)
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text((profile.name ?? "").isEmpty ? "Unknown User" : (profile.name ?? "Unknown User"))
//                    .font(.headline)
//                    .foregroundColor(.black)
//
//                Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .lineLimit(2)
//            }
//            Spacer()
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(radius: 3)
//        .padding(.horizontal)
//    }
//
//    // ✅ Avatar View
//    @ViewBuilder
//    func avatarView(profilePhoto: String?, imageData: Data?) -> some View {
//
//        if let data = imageData, let ui = UIImage(data: data) {
//            Image(uiImage: ui)
//                .resizable()
//                .scaledToFill()
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
//
//        } else if let photo = profilePhoto,
//                  let base64Img = decodeBase64Image(photo) {
//            Image(uiImage: base64Img)
//                .resizable()
//                .scaledToFill()
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
//
//        } else if let photo = profilePhoto,
//                  let url = normalizedPhotoURL(photo) {
//            AsyncImage(url: url) { phase in
//                switch phase {
//                case .success(let image):
//                    image.resizable().scaledToFill()
//
//                case .failure(_):
//                    Circle()
//                        .fill(Color.gray.opacity(0.3))
//                        .overlay(
//                            Image(systemName: "person.fill")
//                                .foregroundColor(.white)
//                        )
//
//                default:
//                    ZStack {
//                        Circle().fill(Color.gray.opacity(0.3))
//                        ProgressView()
//                    }
//                }
//            }
//            .clipShape(Circle())
//            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
//
//        } else {
//            Circle()
//                .fill(Color.gray.opacity(0.3))
//                .overlay(
//                    Image(systemName: "person.fill")
//                        .foregroundColor(.white)
//                )
//        }
//    }
//
//    // MARK: - Helpers
//
//    func decodeBase64Image(_ input: String) -> UIImage? {
//        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else { return nil }
//
//        let base64String: String
//        if let range = trimmed.range(of: "base64,") {
//            base64String = String(trimmed[range.upperBound...])
//        } else {
//            base64String = trimmed
//        }
//
//        guard let data = Data(base64Encoded: base64String),
//              let img = UIImage(data: data) else {
//            return nil
//        }
//        return img
//    }
//
//    func normalizedPhotoURL(_ input: String) -> URL? {
//        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else { return nil }
//
//        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
//            return URL(string: trimmed)
//        }
//
//        let serverBase = "http://127.0.0.1:8000"
//        let fixed = trimmed.hasPrefix("/") ? "\(serverBase)\(trimmed)" : "\(serverBase)/\(trimmed)"
//        return URL(string: fixed)
//    }
//
//    // MARK: - Per-user keys (for older swipe persistence)
//    func swipedKey() -> String {
//        let uid = authViewModel.userId ?? "guest"
//        return "swipedProfileIds_\(uid)"
//    }
//
//    func likedKey() -> String {
//        let uid = authViewModel.userId ?? "guest"
//        return "likedProfileIds_\(uid)"
//    }
//
//    // MARK: - Restart logic
//    func restartAllSwiping() {
//        // 1) Ask AuthViewModel to reset matches + chat store + generic swipe keys
//        authViewModel.restartSwipingLocalReset()
//
//        // 2) Clear any per-user swipe keys (if used elsewhere)
//        UserDefaults.standard.removeObject(forKey: swipedKey())
//        UserDefaults.standard.removeObject(forKey: likedKey())
//
//        // 3) Reset local UI
//        likedProfiles.removeAll()
//        selectedProfile = nil
//        selectedTab = .liked    // jump back to Liked tab
//        restartSwipingNonce += 1
//
//        print("🔁 Restart swiping from LikedUsersView: UI + local keys cleared")
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    LikedUsersView(likedProfiles: .constant(sampleProfiles))
//        .environmentObject(AuthViewModel())
//}
////  LikedUsersView.swift
////  NetSwipe
////
////  Swift 6–safe version
////  ✅ Two top tabs: Liked / Matched
////  ✅ Restart Swiping clears local swipe state + likes + matches UI (PER USER)
////  ✅ ALSO clears ChatStore (no chats / badges) + tells AuthViewModel about restart
////
//
//import SwiftUI
//import UIKit
//
//struct LikedUsersView: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//
//    @Binding var likedProfiles: [Profile]
//    @State private var selectedProfile: Profile? = nil
//
//    // top tab selector
//    private enum TopTab: String, CaseIterable {
//        case liked = "Liked"
//        case matched = "Matched"
//    }
//    @State private var selectedTab: TopTab = .liked
//
//    // restart nonce shared with SwipeScreen
//    @AppStorage("restartSwipingNonce") private var restartSwipingNonce: Int = 0
//
//    var body: some View {
//        ZStack {
//            backgroundView
//
//            VStack(alignment: .leading, spacing: 12) {
//
//                // Header Row + Restart Button
//                HStack {
//                    Text(selectedTab == .liked ? "People You Liked" : "People You Matched")
//                        .font(.title)
//                        .bold()
//                        .foregroundColor(.white)
//
//                    Spacer()
//
//                    Button {
//                        restartAllSwiping()
//                    } label: {
//                        HStack(spacing: 6) {
//                            Image(systemName: "arrow.counterclockwise")
//                            Text("Restart Swiping")
//                        }
//                        .font(.subheadline.bold())
//                        .foregroundColor(.white)
//                        .padding(.vertical, 6)
//                        .padding(.horizontal, 10)
//                        .background(Color.red.opacity(0.9))
//                        .cornerRadius(10)
//                    }
//                }
//                .padding(.top, 40)
//                .padding(.horizontal)
//
//                // Segmented Tabs
//                Picker("", selection: $selectedTab) {
//                    ForEach(TopTab.allCases, id: \.self) { tab in
//                        Text(tab.rawValue).tag(tab)
//                    }
//                }
//                .pickerStyle(.segmented)
//                .padding(.horizontal)
//
//                // Content
//                Group {
//                    if selectedTab == .liked {
//                        likedSection
//                    } else {
//                        matchedSection
//                    }
//                }
//
//                Spacer()
//            }
//
//            // Popup when tapped
//            if let profile = selectedProfile {
//                popup(profile)
//            }
//        }
//    }
//}
//
//// MARK: - Sections
//private extension LikedUsersView {
//
//    var likedSection: some View {
//        Group {
//            if likedProfiles.isEmpty {
//                Spacer()
//                Text("No liked profiles yet.")
//                    .foregroundColor(.white.opacity(0.6))
//                    .frame(maxWidth: .infinity, alignment: .center)
//                Spacer()
//            } else {
//                ScrollView {
//                    VStack(spacing: 16) {
//                        ForEach(likedProfiles) { profile in
//                            Button {
//                                selectedProfile = profile
//                            } label: {
//                                profileRow(profile)
//                            }
//                            .buttonStyle(.plain)
//                        }
//                    }
//                    .padding(.top)
//                }
//            }
//        }
//    }
//
//    var matchedSection: some View {
//        let matches = authViewModel.matches
//
//        return Group {
//            if matches.isEmpty {
//                Spacer()
//                Text("No matches yet.")
//                    .foregroundColor(.white.opacity(0.6))
//                    .frame(maxWidth: .infinity, alignment: .center)
//                Spacer()
//            } else {
//                ScrollView {
//                    VStack(spacing: 16) {
//                        ForEach(matches) { profile in
//                            Button {
//                                selectedProfile = profile
//                            } label: {
//                                profileRow(profile)
//                            }
//                            .buttonStyle(.plain)
//                        }
//                    }
//                    .padding(.top)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - UI pieces
//private extension LikedUsersView {
//
//    var backgroundView: some View {
//        LinearGradient(
//            gradient: Gradient(colors: [Color.purple.opacity(0.9), Color.black]),
//            startPoint: .topLeading,
//            endPoint: .bottomTrailing
//        )
//        .ignoresSafeArea()
//    }
//
//    @ViewBuilder
//    func popup(_ profile: Profile) -> some View {
//        ZStack {
//            Color.black.opacity(0.6)
//                .ignoresSafeArea()
//                .onTapGesture { selectedProfile = nil }
//
//            VStack(spacing: 16) {
//                avatarView(profilePhoto: profile.profilePhoto, imageData: profile.imageData)
//                    .frame(width: 120, height: 120)
//
//                Text((profile.name ?? "").isEmpty ? "Unknown User" : (profile.name ?? "Unknown User"))
//                    .font(.title2)
//                    .bold()
//                    .foregroundColor(.white)
//
//                Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
//                    .font(.subheadline)
//                    .foregroundColor(.white.opacity(0.8))
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 12)
//
//                Button("Close") {
//                    withAnimation { selectedProfile = nil }
//                }
//                .foregroundColor(.white)
//                .padding(.vertical, 8)
//                .padding(.horizontal, 24)
//                .background(Color.red)
//                .cornerRadius(10)
//            }
//            .padding()
//            .frame(maxWidth: 300)
//            .background(Color.black.opacity(0.85))
//            .cornerRadius(16)
//            .shadow(radius: 10)
//        }
//        .transition(.opacity.combined(with: .scale))
//        .animation(.easeInOut, value: selectedProfile)
//    }
//
//    @ViewBuilder
//    func profileRow(_ profile: Profile) -> some View {
//        HStack(spacing: 12) {
//            avatarView(profilePhoto: profile.profilePhoto, imageData: profile.imageData)
//                .frame(width: 60, height: 60)
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text((profile.name ?? "").isEmpty ? "Unknown User" : (profile.name ?? "Unknown User"))
//                    .font(.headline)
//                    .foregroundColor(.black)
//
//                Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .lineLimit(2)
//            }
//            Spacer()
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(radius: 3)
//        .padding(.horizontal)
//    }
//
//    // Avatar View
//    @ViewBuilder
//    func avatarView(profilePhoto: String?, imageData: Data?) -> some View {
//
//        if let data = imageData, let ui = UIImage(data: data) {
//            Image(uiImage: ui)
//                .resizable()
//                .scaledToFill()
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
//
//        } else if let photo = profilePhoto,
//                  let base64Img = decodeBase64Image(photo) {
//            Image(uiImage: base64Img)
//                .resizable()
//                .scaledToFill()
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
//
//        } else if let photo = profilePhoto,
//                  let url = normalizedPhotoURL(photo) {
//            AsyncImage(url: url) { phase in
//                switch phase {
//                case .success(let image):
//                    image.resizable().scaledToFill()
//
//                case .failure(_):
//                    Circle()
//                        .fill(Color.gray.opacity(0.3))
//                        .overlay(
//                            Image(systemName: "person.fill")
//                                .foregroundColor(.white)
//                        )
//
//                default:
//                    ZStack {
//                        Circle().fill(Color.gray.opacity(0.3))
//                        ProgressView()
//                    }
//                }
//            }
//            .clipShape(Circle())
//            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
//
//        } else {
//            Circle()
//                .fill(Color.gray.opacity(0.3))
//                .overlay(
//                    Image(systemName: "person.fill")
//                        .foregroundColor(.white)
//                )
//        }
//    }
//
//    // MARK: - Helpers
//
//    func decodeBase64Image(_ input: String) -> UIImage? {
//        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else { return nil }
//
//        let base64String: String
//        if let range = trimmed.range(of: "base64,") {
//            base64String = String(trimmed[range.upperBound...])
//        } else {
//            base64String = trimmed
//        }
//
//        guard let data = Data(base64Encoded: base64String),
//              let img = UIImage(data: data) else {
//            return nil
//        }
//        return img
//    }
//
//    func normalizedPhotoURL(_ input: String) -> URL? {
//        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else { return nil }
//
//        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
//            return URL(string: trimmed)
//        }
//
//        let serverBase = "http://127.0.0.1:8000"
//        let fixed = trimmed.hasPrefix("/") ? "\(serverBase)\(trimmed)" : "\(serverBase)/\(trimmed)"
//        return URL(string: fixed)
//    }
//
//    // MARK: - Per-user keys (match SwipeScreen)
//    func swipedKey() -> String {
//        let uid = authViewModel.userId ?? "guest"
//        return "swipedProfileIds_\(uid)"
//    }
//
//    func likedKey() -> String {
//        let uid = authViewModel.userId ?? "guest"
//        return "likedProfileIds_\(uid)"
//    }
//
//    // MARK: - Restart logic (PER USER)
//    func restartAllSwiping() {
//        // clear only this user's swipe history
//        UserDefaults.standard.removeObject(forKey: swipedKey())
//        UserDefaults.standard.removeObject(forKey: likedKey())
//
//        // reset UI lists
//        likedProfiles.removeAll()
//        selectedProfile = nil
//
//        // tell view model to nuke matches + chat store + set restart flag
//        authViewModel.applyLocalRestartFromUI()
//
//        // bump nonce so SwipeScreen reloads fresh deck
//        restartSwipingNonce += 1
//
//        print("♻️ Restart Swiping tapped: likes, matches, chats cleared for this user.")
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    LikedUsersView(likedProfiles: .constant(sampleProfiles))
//        .environmentObject(AuthViewModel())
//}
////  LikedUsersView.swift
////  NetSwipe
////
////  Swift 6–safe version
////  ✅ Two top tabs: Liked / Matched
////  ✅ Restart Swiping clears local swipe state + likes + matches UI (PER USER)
////  ✅ ALSO clears ChatStore (no chats / badges) + tells AuthViewModel about restart
////
//
//import SwiftUI
//import UIKit
//
//struct LikedUsersView: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//
//    @Binding var likedProfiles: [Profile]
//    @State private var selectedProfile: Profile? = nil
//
//    // top tab selector
//    private enum TopTab: String, CaseIterable {
//        case liked = "Liked"
//        case matched = "Matched"
//    }
//    @State private var selectedTab: TopTab = .liked
//
//    // restart nonce shared with SwipeScreen
//    @AppStorage("restartSwipingNonce") private var restartSwipingNonce: Int = 0
//
//    var body: some View {
//        ZStack {
//            backgroundView
//
//            VStack(alignment: .leading, spacing: 12) {
//
//                // Header Row + Restart Button
//                HStack {
//                    Text(selectedTab == .liked ? "People You Liked" : "People You Matched")
//                        .font(.title)
//                        .bold()
//                        .foregroundColor(.white)
//
//                    Spacer()
//
//                    Button {
//                        restartAllSwiping()
//                    } label: {
//                        HStack(spacing: 6) {
//                            Image(systemName: "arrow.counterclockwise")
//                            Text("Restart Swiping")
//                        }
//                        .font(.subheadline.bold())
//                        .foregroundColor(.white)
//                        .padding(.vertical, 6)
//                        .padding(.horizontal, 10)
//                        .background(Color.red.opacity(0.9))
//                        .cornerRadius(10)
//                    }
//                }
//                .padding(.top, 40)
//                .padding(.horizontal)
//
//                // Segmented Tabs
//                Picker("", selection: $selectedTab) {
//                    ForEach(TopTab.allCases, id: \.self) { tab in
//                        Text(tab.rawValue).tag(tab)
//                    }
//                }
//                .pickerStyle(.segmented)
//                .padding(.horizontal)
//
//                // Content
//                Group {
//                    if selectedTab == .liked {
//                        likedSection
//                    } else {
//                        matchedSection
//                    }
//                }
//
//                Spacer()
//            }
//
//            // Popup when tapped
//            if let profile = selectedProfile {
//                popup(profile)
//            }
//        }
//    }
//}
//
//// MARK: - Sections
//private extension LikedUsersView {
//
//    var likedSection: some View {
//        Group {
//            if likedProfiles.isEmpty {
//                Spacer()
//                Text("No liked profiles yet.")
//                    .foregroundColor(.white.opacity(0.6))
//                    .frame(maxWidth: .infinity, alignment: .center)
//                Spacer()
//            } else {
//                ScrollView {
//                    VStack(spacing: 16) {
//                        ForEach(likedProfiles) { profile in
//                            Button {
//                                selectedProfile = profile
//                            } label: {
//                                profileRow(profile)
//                            }
//                            .buttonStyle(.plain)
//                        }
//                    }
//                    .padding(.top)
//                }
//            }
//        }
//    }
//
//    var matchedSection: some View {
//        let matches = authViewModel.matches
//
//        return Group {
//            if matches.isEmpty {
//                Spacer()
//                Text("No matches yet.")
//                    .foregroundColor(.white.opacity(0.6))
//                    .frame(maxWidth: .infinity, alignment: .center)
//                Spacer()
//            } else {
//                ScrollView {
//                    VStack(spacing: 16) {
//                        ForEach(matches) { profile in
//                            Button {
//                                selectedProfile = profile
//                            } label: {
//                                profileRow(profile)
//                            }
//                            .buttonStyle(.plain)
//                        }
//                    }
//                    .padding(.top)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - UI pieces
//private extension LikedUsersView {
//
//    var backgroundView: some View {
//        LinearGradient(
//            gradient: Gradient(colors: [Color.purple.opacity(0.9), Color.black]),
//            startPoint: .topLeading,
//            endPoint: .bottomTrailing
//        )
//        .ignoresSafeArea()
//    }
//
//    @ViewBuilder
//    func popup(_ profile: Profile) -> some View {
//        ZStack {
//            Color.black.opacity(0.6)
//                .ignoresSafeArea()
//                .onTapGesture { selectedProfile = nil }
//
//            VStack(spacing: 16) {
//                avatarView(profilePhoto: profile.profilePhoto, imageData: profile.imageData)
//                    .frame(width: 120, height: 120)
//
//                Text((profile.name ?? "").isEmpty ? "Unknown User" : (profile.name ?? "Unknown User"))
//                    .font(.title2)
//                    .bold()
//                    .foregroundColor(.white)
//
//                Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
//                    .font(.subheadline)
//                    .foregroundColor(.white.opacity(0.8))
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 12)
//
//                Button("Close") {
//                    withAnimation { selectedProfile = nil }
//                }
//                .foregroundColor(.white)
//                .padding(.vertical, 8)
//                .padding(.horizontal, 24)
//                .background(Color.red)
//                .cornerRadius(10)
//            }
//            .padding()
//            .frame(maxWidth: 300)
//            .background(Color.black.opacity(0.85))
//            .cornerRadius(16)
//            .shadow(radius: 10)
//        }
//        .transition(.opacity.combined(with: .scale))
//        .animation(.easeInOut, value: selectedProfile)
//    }
//
//    @ViewBuilder
//    func profileRow(_ profile: Profile) -> some View {
//        HStack(spacing: 12) {
//            avatarView(profilePhoto: profile.profilePhoto, imageData: profile.imageData)
//                .frame(width: 60, height: 60)
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text((profile.name ?? "").isEmpty ? "Unknown User" : (profile.name ?? "Unknown User"))
//                    .font(.headline)
//                    .foregroundColor(.black)
//
//                Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .lineLimit(2)
//            }
//            Spacer()
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(radius: 3)
//        .padding(.horizontal)
//    }
//
//    // Avatar View
//    @ViewBuilder
//    func avatarView(profilePhoto: String?, imageData: Data?) -> some View {
//
//        if let data = imageData, let ui = UIImage(data: data) {
//            Image(uiImage: ui)
//                .resizable()
//                .scaledToFill()
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
//
//        } else if let photo = profilePhoto,
//                  let base64Img = decodeBase64Image(photo) {
//            Image(uiImage: base64Img)
//                .resizable()
//                .scaledToFill()
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
//
//        } else if let photo = profilePhoto,
//                  let url = normalizedPhotoURL(photo) {
//            AsyncImage(url: url) { phase in
//                switch phase {
//                case .success(let image):
//                    image.resizable().scaledToFill()
//
//                case .failure(_):
//                    Circle()
//                        .fill(Color.gray.opacity(0.3))
//                        .overlay(
//                            Image(systemName: "person.fill")
//                                .foregroundColor(.white)
//                        )
//
//                default:
//                    ZStack {
//                        Circle().fill(Color.gray.opacity(0.3))
//                        ProgressView()
//                    }
//                }
//            }
//            .clipShape(Circle())
//            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
//
//        } else {
//            Circle()
//                .fill(Color.gray.opacity(0.3))
//                .overlay(
//                    Image(systemName: "person.fill")
//                        .foregroundColor(.white)
//                )
//        }
//    }
//
//    // MARK: - Helpers
//
//    func decodeBase64Image(_ input: String) -> UIImage? {
//        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else { return nil }
//
//        let base64String: String
//        if let range = trimmed.range(of: "base64,") {
//            base64String = String(trimmed[range.upperBound...])
//        } else {
//            base64String = trimmed
//        }
//
//        guard let data = Data(base64Encoded: base64String),
//              let img = UIImage(data: data) else {
//            return nil
//        }
//        return img
//    }
//
//    func normalizedPhotoURL(_ input: String) -> URL? {
//        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else { return nil }
//
//        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
//            return URL(string: trimmed)
//        }
//
//        let serverBase = "http://127.0.0.1:8000"
//        let fixed = trimmed.hasPrefix("/") ? "\(serverBase)\(trimmed)" : "\(serverBase)/\(trimmed)"
//        return URL(string: fixed)
//    }
//
//    // MARK: - Per-user keys (match SwipeScreen)
//    func swipedKey() -> String {
//        let uid = authViewModel.userId ?? "guest"
//        return "swipedProfileIds_\(uid)"
//    }
//
//    func likedKey() -> String {
//        let uid = authViewModel.userId ?? "guest"
//        return "likedProfileIds_\(uid)"
//    }
//
//    // MARK: - Restart logic (PER USER)
//    func restartAllSwiping() {
//        // clear only this user's swipe history
//        UserDefaults.standard.removeObject(forKey: swipedKey())
//        UserDefaults.standard.removeObject(forKey: likedKey())
//
//        // reset UI lists
//        likedProfiles.removeAll()
//        selectedProfile = nil
//
//        // tell view model to clear matches & suppress old backend ones
//        authViewModel.handleRestartSwiping()
//
//        // clear all chat previews + unread badges
//        ChatStore.shared.reset()
//
//        // bump nonce so SwipeScreen reloads fresh deck
//        restartSwipingNonce += 1
//
//        print("♻️ Restart Swiping tapped: likes, matches, chats cleared for this user.")
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    LikedUsersView(likedProfiles: .constant(sampleProfiles))
//        .environmentObject(AuthViewModel())
//}
//  LikedUsersView.swift
//  NetSwipe
//
//  Swift 6–safe version
//  ✅ Two top tabs: Liked / Matched
//  ✅ Restart Swiping clears local swipe state + likes + matches UI (PER USER)
//  ✅ Also notifies AuthViewModel, which clears matches + ChatStore + sockets
//

//import SwiftUI
//import UIKit
//
//struct LikedUsersView: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//
//    @Binding var likedProfiles: [Profile]
//    @State private var selectedProfile: Profile? = nil
//
//    // top tab selector
//    private enum TopTab: String, CaseIterable {
//        case liked = "Liked"
//        case matched = "Matched"
//    }
//    @State private var selectedTab: TopTab = .liked
//
//    // restart nonce shared with SwipeScreen
//    @AppStorage("restartSwipingNonce") private var restartSwipingNonce: Int = 0
//
//    // confirmation alert before wiping everything
//    @State private var showRestartAlert: Bool = false
//
//    var body: some View {
//        ZStack {
//            backgroundView
//
//            VStack(alignment: .leading, spacing: 12) {
//
//                // Header Row + Restart Button
//                HStack {
//                    Text(selectedTab == .liked ? "People You Liked" : "People You Matched")
//                        .font(.title)
//                        .bold()
//                        .foregroundColor(.white)
//
//                    Spacer()
//
//                    Button {
//                        showRestartAlert = true
//                    } label: {
//                        HStack(spacing: 6) {
//                            Image(systemName: "arrow.counterclockwise")
//                            Text("Restart Swiping")
//                        }
//                        .font(.subheadline.bold())
//                        .foregroundColor(.white)
//                        .padding(.vertical, 6)
//                        .padding(.horizontal, 10)
//                        .background(Color.red.opacity(0.9))
//                        .cornerRadius(10)
//                    }
//                }
//                .padding(.top, 40)
//                .padding(.horizontal)
//
//                // Segmented Tabs
//                Picker("", selection: $selectedTab) {
//                    ForEach(TopTab.allCases, id: \.self) { tab in
//                        Text(tab.rawValue).tag(tab)
//                    }
//                }
//                .pickerStyle(.segmented)
//                .padding(.horizontal)
//
//                // Content
//                Group {
//                    if selectedTab == .liked {
//                        likedSection
//                    } else {
//                        matchedSection
//                    }
//                }
//
//                Spacer()
//            }
//
//            // Popup when tapped
//            if let profile = selectedProfile {
//                popup(profile)
//            }
//        }
//        .alert("Restart Swiping?",
//               isPresented: $showRestartAlert,
//               actions: {
//            Button("Cancel", role: .cancel) {}
//
//            Button("Restart", role: .destructive) {
//                restartAllSwiping()
//            }
//        }, message: {
//            Text("This will clear your liked profiles, matches, and chat previews for this account and reload a fresh stack of profiles.")
//        })
//    }
//}
//
//// MARK: - Sections
//private extension LikedUsersView {
//
//    var likedSection: some View {
//        Group {
//            if likedProfiles.isEmpty {
//                Spacer()
//                Text("No liked profiles yet.")
//                    .foregroundColor(.white.opacity(0.6))
//                    .frame(maxWidth: .infinity, alignment: .center)
//                Spacer()
//            } else {
//                ScrollView {
//                    VStack(spacing: 16) {
//                        ForEach(likedProfiles) { profile in
//                            Button {
//                                selectedProfile = profile
//                            } label: {
//                                profileRow(profile)
//                            }
//                            .buttonStyle(.plain)
//                        }
//                    }
//                    .padding(.top)
//                }
//            }
//        }
//    }
//
//    var matchedSection: some View {
//        let matches = authViewModel.matches
//
//        return Group {
//            if matches.isEmpty {
//                Spacer()
//                Text("No matches yet.")
//                    .foregroundColor(.white.opacity(0.6))
//                    .frame(maxWidth: .infinity, alignment: .center)
//                Spacer()
//            } else {
//                ScrollView {
//                    VStack(spacing: 16) {
//                        ForEach(matches) { profile in
//                            Button {
//                                selectedProfile = profile
//                            } label: {
//                                profileRow(profile)
//                            }
//                            .buttonStyle(.plain)
//                        }
//                    }
//                    .padding(.top)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - UI pieces
//private extension LikedUsersView {
//
//    var backgroundView: some View {
//        LinearGradient(
//            gradient: Gradient(colors: [Color.purple.opacity(0.9), Color.black]),
//            startPoint: .topLeading,
//            endPoint: .bottomTrailing
//        )
//        .ignoresSafeArea()
//    }
//
//    @ViewBuilder
//    func popup(_ profile: Profile) -> some View {
//        ZStack {
//            Color.black.opacity(0.6)
//                .ignoresSafeArea()
//                .onTapGesture { selectedProfile = nil }
//
//            VStack(spacing: 16) {
//                avatarView(profilePhoto: profile.profilePhoto, imageData: profile.imageData)
//                    .frame(width: 120, height: 120)
//
//                Text((profile.name ?? "").isEmpty ? "Unknown User" : (profile.name ?? "Unknown User"))
//                    .font(.title2)
//                    .bold()
//                    .foregroundColor(.white)
//
//                Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
//                    .font(.subheadline)
//                    .foregroundColor(.white.opacity(0.8))
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 12)
//
//                Button("Close") {
//                    withAnimation { selectedProfile = nil }
//                }
//                .foregroundColor(.white)
//                .padding(.vertical, 8)
//                .padding(.horizontal, 24)
//                .background(Color.red)
//                .cornerRadius(10)
//            }
//            .padding()
//            .frame(maxWidth: 300)
//            .background(Color.black.opacity(0.85))
//            .cornerRadius(16)
//            .shadow(radius: 10)
//        }
//        .transition(.opacity .combined(with: .scale))
//        .animation(.easeInOut, value: selectedProfile)
//    }
//
//    @ViewBuilder
//    func profileRow(_ profile: Profile) -> some View {
//        HStack(spacing: 12) {
//            avatarView(profilePhoto: profile.profilePhoto, imageData: profile.imageData)
//                .frame(width: 60, height: 60)
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text((profile.name ?? "").isEmpty ? "Unknown User" : (profile.name ?? "Unknown User"))
//                    .font(.headline)
//                    .foregroundColor(.black)
//
//                Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .lineLimit(2)
//            }
//            Spacer()
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(radius: 3)
//        .padding(.horizontal)
//    }
//
//    // Avatar View
//    @ViewBuilder
//    func avatarView(profilePhoto: String?, imageData: Data?) -> some View {
//
//        if let data = imageData, let ui = UIImage(data: data) {
//            Image(uiImage: ui)
//                .resizable()
//                .scaledToFill()
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
//
//        } else if let photo = profilePhoto,
//                  let base64Img = decodeBase64Image(photo) {
//            Image(uiImage: base64Img)
//                .resizable()
//                .scaledToFill()
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
//
//        } else if let photo = profilePhoto,
//                  let url = normalizedPhotoURL(photo) {
//            AsyncImage(url: url) { phase in
//                switch phase {
//                case .success(let image):
//                    image.resizable().scaledToFill()
//
//                case .failure(_):
//                    Circle()
//                        .fill(Color.gray.opacity(0.3))
//                        .overlay(
//                            Image(systemName: "person.fill")
//                                .foregroundColor(.white)
//                        )
//
//                default:
//                    ZStack {
//                        Circle().fill(Color.gray.opacity(0.3))
//                        ProgressView()
//                    }
//                }
//            }
//            .clipShape(Circle())
//            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
//
//        } else {
//            Circle()
//                .fill(Color.gray.opacity(0.3))
//                .overlay(
//                    Image(systemName: "person.fill")
//                        .foregroundColor(.white)
//                )
//        }
//    }
//
//    // MARK: - Helpers
//
//    func decodeBase64Image(_ input: String) -> UIImage? {
//        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else { return nil }
//
//        let base64String: String
//        if let range = trimmed.range(of: "base64,") {
//            base64String = String(trimmed[range.upperBound...])
//        } else {
//            base64String = trimmed
//        }
//
//        guard let data = Data(base64Encoded: base64String),
//              let img = UIImage(data: data) else {
//            return nil
//        }
//        return img
//    }
//
//    func normalizedPhotoURL(_ input: String) -> URL? {
//        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else { return nil }
//
//        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
//            return URL(string: trimmed)
//        }
//
//        let serverBase = "http://127.0.0.1:8000"
//        let fixed = trimmed.hasPrefix("/") ? "\(serverBase)\(trimmed)" : "\(serverBase)/\(trimmed)"
//        return URL(string: fixed)
//    }
//
//    // MARK: - Per-user keys (match SwipeScreen)
//    func swipedKey() -> String {
//        let uid = authViewModel.userId ?? "guest"
//        return "swipedProfileIds_\(uid)"
//    }
//
//    func likedKey() -> String {
//        let uid = authViewModel.userId ?? "guest"
//        return "likedProfileIds_\(uid)"
//    }
//
//    // MARK: - Restart logic (PER USER)
//    func restartAllSwiping() {
//        // 1) clear only this user's swipe history (new per-user keys)
//        UserDefaults.standard.removeObject(forKey: swipedKey())
//        UserDefaults.standard.removeObject(forKey: likedKey())
//
//        // 1b) also clear legacy global keys in case old code still reads them
//        UserDefaults.standard.removeObject(forKey: "swipedProfileIds")
//        UserDefaults.standard.removeObject(forKey: "likedProfileIds")
//
//        // 2) reset local UI lists
//        likedProfiles.removeAll()
//        selectedProfile = nil
//        selectedTab = .liked
//
//        // 3) tell view model to clear matches, chats, sockets & suppress old matches
//        authViewModel.applyLocalRestartFromUI()
//
//        // 4) bump nonce so SwipeScreen reloads a fresh deck (and resets its state)
//        restartSwipingNonce += 1
//
//        print("♻️ Restart Swiping tapped: swipes, likes, matches cleared for this user.")
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    LikedUsersView(likedProfiles: .constant(sampleProfiles))
//        .environmentObject(AuthViewModel())
//}
////  LikedUsersView.swift
////  NetSwipe
////
////  Two top tabs: Liked / Matched
////  Per-row Remove / Unmatch button
////  Unmatch also clears chat history + previews + unread for that pair
////
//
//import SwiftUI
//import UIKit
//
//// Basic response for delete / unmatch endpoint
//private struct BasicResponse: Codable {
//    let success: Bool
//    let message: String?
//}
//
//struct LikedUsersView: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//
//    @Binding var likedProfiles: [Profile]
//    @State private var selectedProfile: Profile? = nil
//
//    // Top tab selector
//    private enum TopTab: String, CaseIterable {
//        case liked = "Liked"
//        case matched = "Matched"
//    }
//    @State private var selectedTab: TopTab = .liked
//
//    var body: some View {
//        ZStack {
//            backgroundView
//
//            VStack(alignment: .leading, spacing: 12) {
//
//                // Header
//                HStack {
//                    Text(selectedTab == .liked ? "People You Liked" : "People You Matched")
//                        .font(.title)
//                        .bold()
//                        .foregroundColor(.white)
//
//                    Spacer()
//                }
//                .padding(.top, 40)
//                .padding(.horizontal)
//
//                // Segmented Tabs
//                Picker("", selection: $selectedTab) {
//                    ForEach(TopTab.allCases, id: \.self) { tab in
//                        Text(tab.rawValue).tag(tab)
//                    }
//                }
//                .pickerStyle(.segmented)
//                .padding(.horizontal)
//
//                // Content
//                Group {
//                    if selectedTab == .liked {
//                        likedSection
//                    } else {
//                        matchedSection
//                    }
//                }
//
//                Spacer()
//            }
//
//            // Popup when a row is tapped
//            if let profile = selectedProfile {
//                popup(profile)
//            }
//        }
//    }
//}
//
//// MARK: - Internal helpers
//
//private enum RowKind {
//    case liked
//    case matched
//}
//
//// MARK: - Sections
//private extension LikedUsersView {
//
//    var likedSection: some View {
//        Group {
//            if likedProfiles.isEmpty {
//                Spacer()
//                Text("No liked profiles yet.")
//                    .foregroundColor(.white.opacity(0.6))
//                    .frame(maxWidth: .infinity, alignment: .center)
//                Spacer()
//            } else {
//                ScrollView {
//                    VStack(spacing: 16) {
//                        ForEach(likedProfiles) { profile in
//                            profileRow(profile, kind: .liked)
//                                .onTapGesture {
//                                    selectedProfile = profile
//                                }
//                        }
//                    }
//                    .padding(.top)
//                }
//            }
//        }
//    }
//
//    var matchedSection: some View {
//        let matches = authViewModel.matches
//
//        return Group {
//            if matches.isEmpty {
//                Spacer()
//                Text("No matches yet.")
//                    .foregroundColor(.white.opacity(0.6))
//                    .frame(maxWidth: .infinity, alignment: .center)
//                Spacer()
//            } else {
//                ScrollView {
//                    VStack(spacing: 16) {
//                        ForEach(matches) { profile in
//                            profileRow(profile, kind: .matched)
//                                .onTapGesture {
//                                    selectedProfile = profile
//                                }
//                        }
//                    }
//                    .padding(.top)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - UI pieces
//private extension LikedUsersView {
//
//    var backgroundView: some View {
//        LinearGradient(
//            gradient: Gradient(colors: [Color.purple.opacity(0.9), Color.black]),
//            startPoint: .topLeading,
//            endPoint: .bottomTrailing
//        )
//        .ignoresSafeArea()
//    }
//
//    @ViewBuilder
//    func popup(_ profile: Profile) -> some View {
//        ZStack {
//            Color.black.opacity(0.6)
//                .ignoresSafeArea()
//                .onTapGesture { selectedProfile = nil }
//
//            VStack(spacing: 16) {
//                avatarView(profilePhoto: profile.profilePhoto, imageData: profile.imageData)
//                    .frame(width: 120, height: 120)
//
//                Text((profile.name ?? "").isEmpty ? "Unknown User" : (profile.name ?? "Unknown User"))
//                    .font(.title2)
//                    .bold()
//                    .foregroundColor(.white)
//
//                Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
//                    .font(.subheadline)
//                    .foregroundColor(.white.opacity(0.8))
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 12)
//
//                Button("Close") {
//                    withAnimation { selectedProfile = nil }
//                }
//                .foregroundColor(.white)
//                .padding(.vertical, 8)
//                .padding(.horizontal, 24)
//                .background(Color.red)
//                .cornerRadius(10)
//            }
//            .padding()
//            .frame(maxWidth: 300)
//            .background(Color.black.opacity(0.85))
//            .cornerRadius(16)
//            .shadow(radius: 10)
//        }
//        .transition(.opacity.combined(with: .scale))
//        .animation(.easeInOut, value: selectedProfile)
//    }
//
//    @ViewBuilder
//    func profileRow(_ profile: Profile, kind: RowKind) -> some View {
//        HStack(spacing: 12) {
//            avatarView(profilePhoto: profile.profilePhoto, imageData: profile.imageData)
//                .frame(width: 60, height: 60)
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text((profile.name ?? "").isEmpty ? "Unknown User" : (profile.name ?? "Unknown User"))
//                    .font(.headline)
//                    .foregroundColor(.black)
//
//                Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .lineLimit(2)
//            }
//
//            Spacer()
//
//            Button(role: .destructive) {
//                switch kind {
//                case .liked:
//                    removeLikedProfile(profile)
//                case .matched:
//                    removeMatchedProfile(profile)
//                }
//            } label: {
//                Text(kind == .liked ? "Remove" : "Unmatch")
//                    .font(.caption.bold())
//                    .padding(.vertical, 6)
//                    .padding(.horizontal, 10)
//                    .background(Color.red.opacity(0.1))
//                    .foregroundColor(.red)
//                    .cornerRadius(8)
//            }
//            .buttonStyle(.borderless) // so tap gesture on row still works
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(radius: 3)
//        .padding(.horizontal)
//    }
//
//    // Avatar View (same image logic you already had)
//    @ViewBuilder
//    func avatarView(profilePhoto: String?, imageData: Data?) -> some View {
//
//        if let data = imageData, let ui = UIImage(data: data) {
//            Image(uiImage: ui)
//                .resizable()
//                .scaledToFill()
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
//
//        } else if let photo = profilePhoto,
//                  let base64Img = decodeBase64Image(photo) {
//            Image(uiImage: base64Img)
//                .resizable()
//                .scaledToFill()
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
//
//        } else if let photo = profilePhoto,
//                  let url = normalizedPhotoURL(photo) {
//            AsyncImage(url: url) { phase in
//                switch phase {
//                case .success(let image):
//                    image.resizable().scaledToFill()
//
//                case .failure(_):
//                    Circle()
//                        .fill(Color.gray.opacity(0.3))
//                        .overlay(
//                            Image(systemName: "person.fill")
//                                .foregroundColor(.white)
//                        )
//
//                default:
//                    ZStack {
//                        Circle().fill(Color.gray.opacity(0.3))
//                        ProgressView()
//                    }
//                }
//            }
//            .clipShape(Circle())
//            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
//
//        } else {
//            Circle()
//                .fill(Color.gray.opacity(0.3))
//                .overlay(
//                    Image(systemName: "person.fill")
//                        .foregroundColor(.white)
//                )
//        }
//    }
//
//    // MARK: - Helpers (base64 + URL + liked IDs persistence)
//
//    func decodeBase64Image(_ input: String) -> UIImage? {
//        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else { return nil }
//
//        let base64String: String
//        if let range = trimmed.range(of: "base64,") {
//            base64String = String(trimmed[range.upperBound...])
//        } else {
//            base64String = trimmed
//        }
//
//        guard let data = Data(base64Encoded: base64String),
//              let img = UIImage(data: data) else {
//            return nil
//        }
//        return img
//    }
//
//    func normalizedPhotoURL(_ input: String) -> URL? {
//        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else { return nil }
//
//        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
//            return URL(string: trimmed)
//        }
//
//        let serverBase = "http://127.0.0.1:8000"
//        let fixed = trimmed.hasPrefix("/") ? "\(serverBase)\(trimmed)" : "\(serverBase)/\(trimmed)"
//        return URL(string: fixed)
//    }
//
//    // MARK: - Persistence for liked IDs (matches SwipeScreen logic)
//
//    func likedKey() -> String {
//        let uid = authViewModel.userId ?? "guest"
//        return "likedProfileIds_\(uid)"
//    }
//
//    func loadLikedIds() -> Set<String> {
//        guard let data = UserDefaults.standard.data(forKey: likedKey()),
//              !data.isEmpty,
//              let arr = try? JSONDecoder().decode([String].self, from: data)
//        else { return [] }
//        return Set(arr)
//    }
//
//    func saveLikedIds(_ set: Set<String>) {
//        if let data = try? JSONEncoder().encode(Array(set)) {
//            UserDefaults.standard.set(data, forKey: likedKey())
//        }
//    }
//
//    // MARK: - Row actions
//
//    func removeLikedProfile(_ profile: Profile) {
//        likedProfiles.removeAll { $0.id == profile.id }
//
//        var likedIds = loadLikedIds()
//        likedIds.remove(profile.id)
//        saveLikedIds(likedIds)
//
//        if selectedProfile?.id == profile.id {
//            selectedProfile = nil
//        }
//
//        print("🗑 Removed liked profile \(profile.id)")
//    }
//
//    func removeMatchedProfile(_ profile: Profile) {
//        // 1) Remove from in-memory matches
//        authViewModel.matches.removeAll { $0.id == profile.id }
//
//        // 2) Also remove from likedProfiles + likedIds so UI matches backend
//        likedProfiles.removeAll { $0.id == profile.id }
//        var likedIds = loadLikedIds()
//        likedIds.remove(profile.id)
//        saveLikedIds(likedIds)
//
//        // 3) Clear local chat store for this pair
//        if let meId = authViewModel.userId {
//            ChatStore.shared.clearChat(with: profile.id, myId: meId)
//        }
//
//        // 4) Close popup if it was showing this profile
//        if selectedProfile?.id == profile.id {
//            selectedProfile = nil
//        }
//
//        // 5) Call backend to unmatch + delete chat/messages for BOTH users
//        if let meId = authViewModel.userId {
//            let endpoint = "/match/unmatch/\(profile.id)?me=\(meId)"
//
//            NetworkManager.shared.deleteRequest(endpoint: endpoint) {
//                (result: Result<BasicResponse, Error>) in
//                switch result {
//                case .success(let resp):
//                    print("✅ Unmatch backend success:", resp.message ?? "no message")
//                case .failure(let error):
//                    print("❌ Unmatch backend error:", error.localizedDescription)
//                }
//            }
//        }
//
//        print("🗑 Unmatched profile \(profile.id)")
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    LikedUsersView(likedProfiles: .constant(sampleProfiles))
//        .environmentObject(AuthViewModel())
//}
//  LikedUsersView.swift
//  NetSwipe
//
//  Two top tabs: Liked / Matched
//  Per-row Remove / Unmatch button
//  Unmatch also:
//   - clears chat history + previews + unread for that pair
//   - removes like + match both sides (backend)
//   - removes this user from local swiped/liked sets
//   - re-inserts the unmatched user at TOP of the swipe deck
//

import SwiftUI
import UIKit

// Basic response for delete / unmatch endpoint
private struct BasicResponse: Codable {
    let success: Bool
    let message: String?
}

struct LikedUsersView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    /// Liked profiles shown under the "Liked" tab (shared with SwipeScreen)
    @Binding var likedProfiles: [Profile]

    /// The main swipe deck from SwipeScreen
    /// Top card = LAST element in this array
    @Binding var profiles: [Profile]

    @State private var selectedProfile: Profile? = nil

    // Top tab selector
    private enum TopTab: String, CaseIterable {
        case liked = "Liked"
        case matched = "Matched"
    }
    @State private var selectedTab: TopTab = .liked

    var body: some View {
        ZStack {
            backgroundView

            VStack(alignment: .leading, spacing: 12) {

                // Header
                HStack {
                    Text(selectedTab == .liked ? "People You Liked" : "People You Matched")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.top, 40)
                .padding(.horizontal)

                // Segmented Tabs
                Picker("", selection: $selectedTab) {
                    ForEach(TopTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Content
                Group {
                    if selectedTab == .liked {
                        likedSection
                    } else {
                        matchedSection
                    }
                }

                Spacer()
            }

            // Popup when a row is tapped
            if let profile = selectedProfile {
                popup(profile)
            }
        }
    }
}

// MARK: - Internal helpers

private enum RowKind {
    case liked
    case matched
}

// MARK: - Sections
private extension LikedUsersView {

    var likedSection: some View {
        Group {
            if likedProfiles.isEmpty {
                Spacer()
                Text("No liked profiles yet.")
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(likedProfiles) { profile in
                            profileRow(profile, kind: .liked)
                                .onTapGesture {
                                    selectedProfile = profile
                                }
                        }
                    }
                    .padding(.top)
                }
            }
        }
    }

    var matchedSection: some View {
        let matches = authViewModel.matches

        return Group {
            if matches.isEmpty {
                Spacer()
                Text("No matches yet.")
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(matches) { profile in
                            profileRow(profile, kind: .matched)
                                .onTapGesture {
                                    selectedProfile = profile
                                }
                        }
                    }
                    .padding(.top)
                }
            }
        }
    }
}

// MARK: - UI pieces
private extension LikedUsersView {

    var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.purple.opacity(0.9), Color.black]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    @ViewBuilder
    func popup(_ profile: Profile) -> some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { selectedProfile = nil }

            VStack(spacing: 16) {
                avatarView(profilePhoto: profile.profilePhoto, imageData: profile.imageData)
                    .frame(width: 120, height: 120)

                Text((profile.name ?? "").isEmpty ? "Unknown User" : (profile.name ?? "Unknown User"))
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)

                Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)

                Button("Close") {
                    withAnimation { selectedProfile = nil }
                }
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 24)
                .background(Color.red)
                .cornerRadius(10)
            }
            .padding()
            .frame(maxWidth: 300)
            .background(Color.black.opacity(0.85))
            .cornerRadius(16)
            .shadow(radius: 10)
        }
        .transition(.opacity.combined(with: .scale))
        .animation(.easeInOut, value: selectedProfile)
    }

    @ViewBuilder
    func profileRow(_ profile: Profile, kind: RowKind) -> some View {
        HStack(spacing: 12) {
            avatarView(profilePhoto: profile.profilePhoto, imageData: profile.imageData)
                .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text((profile.name ?? "").isEmpty ? "Unknown User" : (profile.name ?? "Unknown User"))
                    .font(.headline)
                    .foregroundColor(.black)

                Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }

            Spacer()

            Button(role: .destructive) {
                switch kind {
                case .liked:
                    removeLikedProfile(profile)
                case .matched:
                    removeMatchedProfile(profile)
                }
            } label: {
                Text(kind == .liked ? "Remove" : "Unmatch")
                    .font(.caption.bold())
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
            }
            .buttonStyle(.borderless) // so tap gesture on row still works
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
        .padding(.horizontal)
    }

    // Avatar View (same image logic you already had)
    @ViewBuilder
    func avatarView(profilePhoto: String?, imageData: Data?) -> some View {

        if let data = imageData, let ui = UIImage(data: data) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))

        } else if let photo = profilePhoto,
                  let base64Img = decodeBase64Image(photo) {
            Image(uiImage: base64Img)
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))

        } else if let photo = profilePhoto,
                  let url = normalizedPhotoURL(photo) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()

                case .failure(_):
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                        )

                default:
                    ZStack {
                        Circle().fill(Color.gray.opacity(0.3))
                        ProgressView()
                    }
                }
            }
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))

        } else {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                )
        }
    }

    // MARK: - Helpers (base64 + URL)

    func decodeBase64Image(_ input: String) -> UIImage? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let base64String: String
        if let range = trimmed.range(of: "base64,") {
            base64String = String(trimmed[range.upperBound...])
        } else {
            base64String = trimmed
        }

        guard let data = Data(base64Encoded: base64String),
              let img = UIImage(data: data) else {
            return nil
        }
        return img
    }

    func normalizedPhotoURL(_ input: String) -> URL? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
            return URL(string: trimmed)
        }

        let serverBase = "http://127.0.0.1:8000"
        let fixed = trimmed.hasPrefix("/") ? "\(serverBase)\(trimmed)" : "\(serverBase)/\(trimmed)"
        return URL(string: fixed)
    }

    // MARK: - Persistence for liked / swiped IDs (matches SwipeScreen logic)

    func likedKey() -> String {
        let uid = authViewModel.userId ?? "guest"
        return "likedProfileIds_\(uid)"
    }

    func swipedKey() -> String {
        let uid = authViewModel.userId ?? "guest"
        return "swipedProfileIds_\(uid)"
    }

    func loadLikedIds() -> Set<String> {
        guard let data = UserDefaults.standard.data(forKey: likedKey()),
              !data.isEmpty,
              let arr = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return Set(arr)
    }

    func saveLikedIds(_ set: Set<String>) {
        if let data = try? JSONEncoder().encode(Array(set)) {
            UserDefaults.standard.set(data, forKey: likedKey())
        }
    }

    func loadSwipedIds() -> Set<String> {
        guard let data = UserDefaults.standard.data(forKey: swipedKey()),
              !data.isEmpty,
              let arr = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return Set(arr)
    }

    func saveSwipedIds(_ set: Set<String>) {
        if let data = try? JSONEncoder().encode(Array(set)) {
            UserDefaults.standard.set(data, forKey: swipedKey())
        }
    }

    // MARK: - Row actions

    func removeLikedProfile(_ profile: Profile) {
        likedProfiles.removeAll { $0.id == profile.id }

        var likedIds = loadLikedIds()
        likedIds.remove(profile.id)
        saveLikedIds(likedIds)

        if selectedProfile?.id == profile.id {
            selectedProfile = nil
        }

        print("🗑 Removed liked profile \(profile.id)")
    }

    func removeMatchedProfile(_ profile: Profile) {
        // 1) Remove from in-memory matches
        authViewModel.matches.removeAll { $0.id == profile.id }

        // 2) Also remove from likedProfiles + likedIds so UI matches backend
        likedProfiles.removeAll { $0.id == profile.id }
        var likedIds = loadLikedIds()
        likedIds.remove(profile.id)
        saveLikedIds(likedIds)

        // 2b) Remove from swipedIds so this user becomes swipeable again
        var swipedIds = loadSwipedIds()
        swipedIds.remove(profile.id)
        saveSwipedIds(swipedIds)

        // 3) Clear local chat store for this pair
        if let meId = authViewModel.userId {
            ChatStore.shared.clearChat(with: profile.id, myId: meId)
        }

        // 4) Close popup if it was showing this profile
        if selectedProfile?.id == profile.id {
            selectedProfile = nil
        }

        // 5) Re-insert this profile at TOP of the deck (last element in profiles)
        //    Avoid duplicates: if it's already in the deck, move it to the end.
        if let existingIndex = profiles.firstIndex(where: { $0.id == profile.id }) {
            let p = profiles.remove(at: existingIndex)
            profiles.append(p)
        } else {
            profiles.append(profile)
        }

        // 6) Call backend to unmatch + delete chat/messages for BOTH users
        if let meId = authViewModel.userId {
            let endpoint = "/match/unmatch/\(profile.id)?me=\(meId)"

            NetworkManager.shared.deleteRequest(endpoint: endpoint) {
                (result: Result<BasicResponse, Error>) in
                switch result {
                case .success(let resp):
                    print("✅ Unmatch backend success:", resp.message ?? "no message")
                case .failure(let error):
                    print("❌ Unmatch backend error:", error.localizedDescription)
                }
            }
        }

        print("🗑 Unmatched profile \(profile.id) and re-added to deck as top card")
    }
}

// MARK: - Preview

#Preview {
    LikedUsersView(
        likedProfiles: .constant(sampleProfiles),
        profiles: .constant(sampleProfiles)
    )
    .environmentObject(AuthViewModel())
}
