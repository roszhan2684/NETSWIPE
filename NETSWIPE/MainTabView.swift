//////  MainTabView.swift
//////  NetSwipe
//////
//////  ✅ Legacy TabView only (fixes iOS18 TabContent buildExpression errors)
//////  ✅ Chats tab shows unread badge when unread > 0
//////  ✅ Swift 6 safe onChange signatures
//////
////
////import SwiftUI
////
////struct MainTabView: View {
////    @EnvironmentObject var authViewModel: AuthViewModel
////
////    @Binding var likedProfiles: [Profile]
////    @Binding var isLoggedIn: Bool
////
////    @State private var profiles: [Profile] = sampleProfiles
////    @State private var swipeTrigger: SwipeDirection = .none
////    @State private var showCompletion: Bool = false
////    @State private var matchedProfile: Profile? = nil
////
////    // 🔔 Global unread store (for Chats tab badge)
////    @ObservedObject private var chatStore = ChatStore.shared
////    private var unreadTotal: Int { chatStore.totalUnread }
////
////    var body: some View {
////        TabView {
////
////            // 🟣 SWIPE
////            SwipeScreen(
////                profiles: $profiles,
////                likedProfiles: $likedProfiles,
////                swipeTrigger: $swipeTrigger,
////                matchedProfile: $matchedProfile,
////                showCompletion: $showCompletion
////            )
////            .environmentObject(authViewModel)
////            .tabItem {
////                Label("Swipe", systemImage: "hand.point.right.fill")
////            }
////
////            // ❤️ LIKED
////            LikedUsersView(likedProfiles: $likedProfiles)
////                .environmentObject(authViewModel)
////                .tabItem {
////                    Label("Liked", systemImage: "heart.fill")
////                }
////
////            // 💬 CHATS (conditional badge using ChatStore.totalUnread)
////            ChatListScreen()
////                .environmentObject(authViewModel)
////                .tabItem {
////                    Label("Chats", systemImage: "message.fill")
////                }
////                .modifier(UnreadBadge(count: unreadTotal))
////
////            // ⚙️ SETTINGS
////            SettingsScreen(isLoggedIn: $isLoggedIn)
////                .environmentObject(authViewModel)
////                .tabItem {
////                    Label("Settings", systemImage: "gearshape.fill")
////                }
////        }
////        .tint(.purple)
////
////        // ✅ Reset unread + previews when user changes
////        .onChange(of: authViewModel.userId) { _, _ in
////            ChatStore.shared.reset()
////        }
////
////        // ✅ Reset unread + previews on logout
////        .onChange(of: isLoggedIn) { _, newVal in
////            if !newVal {
////                ChatStore.shared.reset()
////            }
////        }
////    }
////}
////
////// MARK: - Conditional badge helper
////private struct UnreadBadge: ViewModifier {
////    let count: Int
////
////    @ViewBuilder
////    func body(content: Content) -> some View {
////        if count > 0 {
////            content.badge(count)
////        } else {
////            content
////        }
////    }
////}
////
////// MARK: - Preview
////#Preview {
////    MainTabView(
////        likedProfiles: .constant(sampleProfiles),
////        isLoggedIn: .constant(true)
////    )
////    .environmentObject(AuthViewModel())
////}
////
////  MainTabView.swift
////  NetSwipe
////
////  ✅ Legacy TabView only (fixes iOS 18 TabContent buildExpression errors)
////  ✅ Each tab gets its own NavigationStack where needed
////  ✅ Chats tab shows unread badge when unread > 0
////  ✅ ChatStore reset when user/logged-in status changes
////
//
//import SwiftUI
//
//struct MainTabView: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//
//    @Binding var likedProfiles: [Profile]
//    @Binding var isLoggedIn: Bool
//
//    @State private var profiles: [Profile] = sampleProfiles
//    @State private var swipeTrigger: SwipeDirection = .none
//    @State private var showCompletion: Bool = false
//    @State private var matchedProfile: Profile? = nil
//
//    // 🔔 Global unread store (for Chats tab badge)
//    @ObservedObject private var chatStore = ChatStore.shared
//    private var unreadTotal: Int { chatStore.totalUnread }
//
//    var body: some View {
//        TabView {
//
//            // 🟣 SWIPE
//            NavigationStack {
//                SwipeScreen(
//                    profiles: $profiles,
//                    likedProfiles: $likedProfiles,
//                    swipeTrigger: $swipeTrigger,
//                    matchedProfile: $matchedProfile,
//                    showCompletion: $showCompletion
//                )
//                .environmentObject(authViewModel)
//            }
//            .tabItem {
//                Label("Swipe", systemImage: "hand.point.right.fill")
//            }
//
//            // ❤️ LIKED
//            NavigationStack {
//                LikedUsersView(likedProfiles: $likedProfiles)
//                    .environmentObject(authViewModel)
//            }
//            .tabItem {
//                Label("Liked", systemImage: "heart.fill")
//            }
//
//            // 💬 CHATS
//            // ChatListScreen already wraps itself in a NavigationStack,
//            // so we present it directly here.
//            ChatListScreen()
//                .environmentObject(authViewModel)
//                .tabItem {
//                    Label("Chats", systemImage: "message.fill")
//                }
//                .modifier(UnreadBadge(count: unreadTotal))
//
//            // ⚙️ SETTINGS
//            NavigationStack {
//                SettingsScreen(isLoggedIn: $isLoggedIn)
//                    .environmentObject(authViewModel)
//            }
//            .tabItem {
//                Label("Settings", systemImage: "gearshape.fill")
//            }
//        }
//        .tint(.purple)
//
//        // ✅ Reset chat store when the logged-in user changes
//        .onChange(of: authViewModel.userId) { _, _ in
//            ChatStore.shared.reset()
//        }
//
//        // ✅ Reset on logout
//        .onChange(of: isLoggedIn) { _, newVal in
//            if !newVal {
//                ChatStore.shared.reset()
//            }
//        }
//    }
//}
//
//// MARK: - Conditional badge helper
//private struct UnreadBadge: ViewModifier {
//    let count: Int
//
//    @ViewBuilder
//    func body(content: Content) -> some View {
//        if count > 0 {
//            content.badge(count)
//        } else {
//            content
//        }
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    MainTabView(
//        likedProfiles: .constant(sampleProfiles),
//        isLoggedIn: .constant(true)
//    )
//    .environmentObject(AuthViewModel())
//}
//  MainTabView.swift
//  NetSwipe
//
//  ✅ Legacy TabView only (fixes iOS 18 TabContent buildExpression errors)
//  ✅ Each tab gets its own NavigationStack where needed
//  ✅ Chats tab shows unread badge when unread > 0
//  ✅ ChatStore reset when user/logged-in status changes
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @Binding var likedProfiles: [Profile]
    @Binding var isLoggedIn: Bool

    @State private var profiles: [Profile] = sampleProfiles
    @State private var swipeTrigger: SwipeDirection = .none
    @State private var showCompletion: Bool = false
    @State private var matchedProfile: Profile? = nil

    // 🔔 Global unread store (for Chats tab badge)
    @ObservedObject private var chatStore = ChatStore.shared
    private var unreadTotal: Int { chatStore.totalUnread }

    var body: some View {
        TabView {

            // 🟣 SWIPE
            NavigationStack {
                SwipeScreen(
                    profiles: $profiles,
                    likedProfiles: $likedProfiles,
                    swipeTrigger: $swipeTrigger,
                    matchedProfile: $matchedProfile,
                    showCompletion: $showCompletion
                )
                .environmentObject(authViewModel)
            }
            .tabItem {
                Label("Swipe", systemImage: "hand.point.right.fill")
            }

            // ❤️ LIKED
            NavigationStack {
                LikedUsersView(
                    likedProfiles: $likedProfiles,
                    profiles: $profiles          // ✅ pass profiles binding here
                )
                .environmentObject(authViewModel)
            }
            .tabItem {
                Label("Liked", systemImage: "heart.fill")
            }

            // 💬 CHATS
            // ChatListScreen already wraps itself in a NavigationStack,
            // so we present it directly here.
            ChatListScreen()
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Chats", systemImage: "message.fill")
                }
                .modifier(UnreadBadge(count: unreadTotal))

            // ⚙️ SETTINGS
            NavigationStack {
                SettingsScreen(isLoggedIn: $isLoggedIn)
                    .environmentObject(authViewModel)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(.purple)

        // ✅ Reset chat store when the logged-in user changes
        .onChange(of: authViewModel.userId) { _, _ in
            ChatStore.shared.reset()
        }

        // ✅ Reset on logout
        .onChange(of: isLoggedIn) { _, newVal in
            if !newVal {
                ChatStore.shared.reset()
            }
        }
    }
}

// MARK: - Conditional badge helper
private struct UnreadBadge: ViewModifier {
    let count: Int

    @ViewBuilder
    func body(content: Content) -> some View {
        if count > 0 {
            content.badge(count)
        } else {
            content
        }
    }
}

// MARK: - Preview
#Preview {
    MainTabView(
        likedProfiles: .constant(sampleProfiles),
        isLoggedIn: .constant(true)
    )
    .environmentObject(AuthViewModel())
}
