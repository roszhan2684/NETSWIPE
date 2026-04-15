//
/////  ChatScreen.swift
////  NetSwipe
////
////  ✅ Live mutual-match chat using Socket.IO
////  ✅ Loads server history via /chat/history (once per chat)
////  ✅ In-memory history via ChatStore (persists while app is running)
////  ✅ Marks unread as read when opened
////  ✅ Cleans up its own socket listener on disappear
////
//
//import SwiftUI
//#if canImport(UIKit)
//import UIKit
//#endif
//
//struct ChatScreen: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//    @ObservedObject private var chatStore = ChatStore.shared
//    let profile: Profile
//
//    @State private var messageText: String = ""
//    @State private var listenerId: UUID? = nil
//    @State private var didLoadHistory: Bool = false
//
//    /// Only allow chat if mutual match exists
//    private var isMatched: Bool {
//        authViewModel.matches.contains(where: { $0.id == profile.id })
//    }
//
//    private var myId: String { authViewModel.userId ?? "" }
//    private var otherId: String { profile.id }
//    private var chatId: String { ChatMessage.makeChatId(myId, otherId) }
//
//    /// Messages for this chat, coming from ChatStore (history + live)
//    private var messages: [ChatMessage] {
//        chatStore.messages(for: chatId)
//    }
//
//    var body: some View {
//        ZStack {
//            LinearGradient(
//                gradient: Gradient(colors: [Color.purple.opacity(0.9), Color.black]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
//
//            if !isMatched {
//                lockedView
//            } else {
//                chatView
//            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            // refresh matches in case we just swiped
//            authViewModel.fetchMatches()
//            startChatIfPossible()
//        }
//        // If matches update (e.g. after fetch), try starting again
//        .onChange(of: authViewModel.matches) { _, _ in
//            startChatIfPossible()
//        }
//        .onDisappear {
//            if chatStore.activeChatUserId == otherId {
//                chatStore.activeChatUserId = nil
//            }
//            SocketService.shared.removeNewMessageHandler(listenerId)
//            listenerId = nil
//        }
//    }
//
//    // MARK: - Start live chat + load history once
//
//    private func startChatIfPossible() {
//        guard !myId.isEmpty else { return }
//        guard isMatched else { return }
//
//        // Mark this chat as active & clear unread for this user
//        chatStore.activeChatUserId = otherId
//        chatStore.markRead(userId: otherId)
//
//        // Load past messages from backend ONCE
//        loadHistoryIfNeeded()
//
//        // Connect + join socket room
//        SocketService.shared.connectIfNeeded()
//        SocketService.shared.join(userId: myId)
//
//        // Attach socket listener once for this screen
//        guard listenerId == nil else { return }
//
//        listenerId = SocketService.shared.onNewMessage { msg in
//            // only handle messages for THIS chat
//            guard msg.chatId == chatId else { return }
//            ChatStore.shared.append(msg, myId: myId)
//        }
//    }
//
//    /// GET /chat/history/:otherUserId?me=myId&limit=200
//    private func loadHistoryIfNeeded() {
//        guard !didLoadHistory else { return }
//        guard !myId.isEmpty, isMatched else { return }
//
//        didLoadHistory = true
//
//        let endpoint = "/chat/history/\(otherId)?me=\(myId)&limit=200"
//
//        NetworkManager.shared.getRequest(endpoint: endpoint) {
//            (result: Result<ChatHistoryResponse, Error>) in
//
//            switch result {
//            case .success(let resp):
//                // Use the mapped messages from ChatHistoryModels.swift
//                let history = resp.chatMessages
//                if history.isEmpty { return }
//
//                // Avoid duplicate inserts: check existing ids first
//                let existing = ChatStore.shared.messages(for: chatId)
//                let existingIds = Set(existing.map { $0.id })
//
//                history.forEach { msg in
//                    if !existingIds.contains(msg.id) {
//                        ChatStore.shared.append(msg, myId: myId)
//                    }
//                }
//
//            case .failure(let err):
//                print("❌ chat history load error:", err.localizedDescription)
//            }
//        }
//    }
//
//    // MARK: - Locked View (no mutual match)
//    private var lockedView: some View {
//        VStack(spacing: 16) {
//            profile.profileImage()
//                .frame(width: 90, height: 90)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1))
//                .shadow(radius: 6)
//
//            Text(profile.displayName)
//                .font(.title2.bold())
//                .foregroundColor(.white)
//
//            Text("You can chat only after a mutual match.")
//                .font(.subheadline)
//                .foregroundColor(.white.opacity(0.8))
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 24)
//
//            Image(systemName: "lock.fill")
//                .font(.system(size: 36))
//                .foregroundColor(.white.opacity(0.9))
//                .padding(.top, 6)
//        }
//        .padding()
//    }
//
//    // MARK: - Main Chat View
//    private var chatView: some View {
//        VStack(spacing: 0) {
//
//            // Header
//            HStack(spacing: 12) {
//                profile.profileImage()
//                    .frame(width: 44, height: 44)
//                    .clipShape(Circle())
//                    .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1))
//
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(profile.displayName)
//                        .font(.headline)
//                        .foregroundColor(.white)
//
//                    Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
//                        .font(.caption)
//                        .foregroundColor(.white.opacity(0.7))
//                        .lineLimit(1)
//                }
//                Spacer()
//            }
//            .padding()
//            .background(Color.black.opacity(0.25))
//
//            // Messages
//            ScrollViewReader { proxy in
//                ScrollView {
//                    VStack(spacing: 10) {
//                        ForEach(messages) { msg in
//                            MessageBubble(message: msg, isMine: msg.fromUserId == myId)
//                                .id(msg.id)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 12)
//                }
//                .onChange(of: messages.count) { _, _ in
//                    if let last = messages.last {
//                        proxy.scrollTo(last.id, anchor: .bottom)
//                    }
//                }
//                // When the view first appears *with* history, scroll to bottom
//                .onAppear {
//                    if let last = messages.last {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                            proxy.scrollTo(last.id, anchor: .bottom)
//                        }
//                    }
//                }
//            }
//
//            // Input bar
//            HStack(spacing: 10) {
//                TextField("Type a message…", text: $messageText)
//                    .textFieldStyle(.roundedBorder)
//                    .submitLabel(.send)
//                    .onSubmit(send)
//
//                Button(action: send) {
//                    Image(systemName: "paperplane.fill")
//                        .padding(10)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .clipShape(Circle())
//                }
//            }
//            .padding()
//            .background(Color.black.opacity(0.25))
//        }
//    }
//
//    // MARK: - Send Message
//    private func send() {
//        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else { return }
//        guard !myId.isEmpty, isMatched else { return }
//
//        let msg = ChatMessage(
//            id: UUID().uuidString,
//            chatId: chatId,
//            fromUserId: myId,
//            toUserId: otherId,
//            text: trimmed,
//            createdAt: Date()
//        )
//
//        // send via socket
//        SocketService.shared.sendMessage(msg)
//
//        // optimistic UI + preview via ChatStore
//        ChatStore.shared.append(msg, myId: myId)
//
//        messageText = ""
//    }
//}
//
//// MARK: - Bubble UI
//private struct MessageBubble: View {
//    let message: ChatMessage
//    let isMine: Bool
//
//    var body: some View {
//        HStack {
//            if isMine { Spacer() }
//
//            VStack(alignment: isMine ? .trailing : .leading, spacing: 4) {
//                Text(message.text)
//                    .padding(12)
//                    .background(isMine ? Color.blue.opacity(0.9) : Color.white.opacity(0.12))
//                    .foregroundColor(.white)
//                    .cornerRadius(14)
//
//                Text(message.createdAt.formatted(date: .omitted, time: .shortened))
//                    .font(.caption2)
//                    .foregroundColor(.white.opacity(0.6))
//            }
//
//            if !isMine { Spacer() }
//        }
//    }
//}
//
//#Preview {
//    ChatScreen(profile: sampleProfiles.first!)
//        .environmentObject(AuthViewModel())
//}
//
//  ChatScreen.swift
//  NetSwipe
//
//  Real-time mutual-match chat using Socket.IO and server-backed history.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ChatScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject private var chatStore = ChatStore.shared
    let profile: Profile

    @State private var messageText: String = ""
    @State private var listenerId: UUID? = nil
    @State private var didLoadHistory: Bool = false

    /// Chat is enabled only when a mutual match exists.
    private var isMatched: Bool {
        authViewModel.matches.contains(where: { $0.id == profile.id })
    }

    private var myId: String { authViewModel.userId ?? "" }
    private var otherId: String { profile.id }
    private var chatId: String { ChatMessage.makeChatId(myId, otherId) }

    /// Messages for this conversation, provided by `ChatStore`.
    private var messages: [ChatMessage] {
        chatStore.messages(for: chatId)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.9), Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if !isMatched {
                lockedView
            } else {
                chatView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Refresh matches and initialise chat state if possible.
            authViewModel.fetchMatches()
            startChatIfPossible()
        }
        .onChange(of: authViewModel.matches) { _, _ in
            startChatIfPossible()
        }
        .onDisappear {
            if chatStore.activeChatUserId == otherId {
                chatStore.activeChatUserId = nil
            }
            SocketService.shared.removeNewMessageHandler(listenerId)
            listenerId = nil
        }
    }

    // MARK: - Live Chat Initialisation and History

    private func startChatIfPossible() {
        guard !myId.isEmpty else { return }
        guard isMatched else { return }

        // Mark this chat as active and clear unread count for this user.
        chatStore.activeChatUserId = otherId
        chatStore.markRead(userId: otherId)

        // Load server-side history once.
        loadHistoryIfNeeded()

        // Ensure socket connection and join the user's room.
        SocketService.shared.connectIfNeeded()
        SocketService.shared.join(userId: myId)

        // Attach a socket listener once for this screen.
        guard listenerId == nil else { return }

        listenerId = SocketService.shared.onNewMessage { msg in
            // Handle only messages for this chat.
            guard msg.chatId == chatId else { return }
            ChatStore.shared.append(msg, myId: myId)
        }
    }

    /// Loads chat history via `GET /chat/history/:otherUserId?me=myId&limit=200`.
    private func loadHistoryIfNeeded() {
        guard !didLoadHistory else { return }
        guard !myId.isEmpty, isMatched else { return }

        didLoadHistory = true

        let endpoint = "/chat/history/\(otherId)?me=\(myId)&limit=200"

        NetworkManager.shared.getRequest(endpoint: endpoint) {
            (result: Result<ChatHistoryResponse, Error>) in

            switch result {
            case .success(let resp):
                let history = resp.chatMessages
                if history.isEmpty { return }

                // Avoid duplicates by checking existing message identifiers.
                let existing = ChatStore.shared.messages(for: chatId)
                let existingIds = Set(existing.map { $0.id })

                history.forEach { msg in
                    if !existingIds.contains(msg.id) {
                        ChatStore.shared.append(msg, myId: myId)
                    }
                }

            case .failure(let err):
                print("❌ chat history load error:", err.localizedDescription)
            }
        }
    }

    // MARK: - Locked View (No Mutual Match)

    private var lockedView: some View {
        VStack(spacing: 16) {
            profile.profileImage()
                .frame(width: 90, height: 90)
                .clipShape(Circle())
                .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1))
                .shadow(radius: 6)

            Text(profile.displayName)
                .font(.title2.bold())
                .foregroundColor(.white)

            Text("You can chat only after a mutual match.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Image(systemName: "lock.fill")
                .font(.system(size: 36))
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 6)
        }
        .padding()
    }

    // MARK: - Main Chat View

    private var chatView: some View {
        VStack(spacing: 0) {

            // Header
            HStack(spacing: 12) {
                profile.profileImage()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    Text(profile.displayName)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text((profile.description ?? "").isEmpty ? "No description" : (profile.description ?? ""))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding()
            .background(Color.black.opacity(0.25))

            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(messages) { msg in
                            MessageBubble(message: msg, isMine: msg.fromUserId == myId)
                                .id(msg.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
                .onAppear {
                    if let last = messages.last {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input bar
            HStack(spacing: 10) {
                TextField("Type a message…", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.send)
                    .onSubmit(send)

                Button(action: send) {
                    Image(systemName: "paperplane.fill")
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color.black.opacity(0.25))
        }
    }

    // MARK: - Send Message

    private func send() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !myId.isEmpty, isMatched else { return }

        let msg = ChatMessage(
            id: UUID().uuidString,
            chatId: chatId,
            fromUserId: myId,
            toUserId: otherId,
            text: trimmed,
            createdAt: Date()
        )

        // Send via socket.
        SocketService.shared.sendMessage(msg)

        // Optimistic UI update via ChatStore.
        ChatStore.shared.append(msg, myId: myId)

        messageText = ""
    }
}

// MARK: - Message Bubble UI

private struct MessageBubble: View {
    let message: ChatMessage
    let isMine: Bool

    var body: some View {
        HStack {
            if isMine { Spacer() }

            VStack(alignment: isMine ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(12)
                    .background(isMine ? Color.blue.opacity(0.9) : Color.white.opacity(0.12))
                    .foregroundColor(.white)
                    .cornerRadius(14)

                Text(message.createdAt.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }

            if !isMine { Spacer() }
        }
    }
}

#Preview {
    ChatScreen(profile: sampleProfiles.first!)
        .environmentObject(AuthViewModel())
}
