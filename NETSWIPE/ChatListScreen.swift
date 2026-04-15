//  ChatListScreen.swift
//  NetSwipe


import SwiftUI

struct ChatListScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject private var chatStore = ChatStore.shared

    @State private var selectedProfile: Profile? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.65, green: 0.25, blue: 0.95),
                        Color(red: 0.18, green: 0.0, blue: 0.25)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    // Screen title
                    Text("Chats")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 12)

                    if authViewModel.matches.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.7))
                            Text("No chats yet")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Swipe right on profiles to start a conversation.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 14) {
                                ForEach(authViewModel.matches) { profile in
                                    let unread = chatStore.unreadCount(for: profile.id)
                                    let last = chatStore.lastPreview(for: profile.id)

                                    ChatRow(
                                        profile: profile,
                                        lastMessage: last?.text ?? "",
                                        unreadCount: unread
                                    ) {
                                        openChat(profile)
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                .padding(.horizontal)
            }
            // Pushes ChatScreen when a profile is selected
            .navigationDestination(item: $selectedProfile) { profile in
                ChatScreen(profile: profile)
                    .environmentObject(authViewModel)
            }
        }
        .onAppear {
            // Refresh mutual matches whenever the Chats tab is opened
            authViewModel.fetchMatches(force: true)
        }
    }

    private func openChat(_ profile: Profile) {
        // Mark chat as active and clear unread count for this user
        chatStore.activeChatUserId = profile.id
        chatStore.markRead(userId: profile.id)
        selectedProfile = profile
    }
}

// MARK: - Chat Row

private struct ChatRow: View {
    let profile: Profile
    let lastMessage: String
    let unreadCount: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                profile.profileImage()
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1))

                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.displayName)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(lastMessage.isEmpty ? "Say hi 👋" : lastMessage)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }

                Spacer()

                if unreadCount > 0 {
                    Text("\(unreadCount)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(8)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
            }
            .padding()
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}
