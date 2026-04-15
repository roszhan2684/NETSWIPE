//
////  ChatStore.swift
////  NetSwipe
////
////  ✅ Keeps unread counts per chat partner
////  ✅ Exposes totalUnread for tab badge
////  ✅ Stores last message preview per chat
////  ✅ Stores full message history per chatId (in-memory)
////  ✅ Global socket listeners call append(_:, myId:)
////  ✅ clearChat(with:myId:) to wipe a single conversation (used by Unmatch)
////
//
//import Foundation
//import Combine
//
//@MainActor
//final class ChatStore: ObservableObject {
//    static let shared = ChatStore()
//
//    /// Unread count per OTHER userId
//    @Published private(set) var unreadByUser: [String: Int] = [:]
//
//    /// Last message per OTHER userId (for preview in ChatListScreen)
//    @Published private(set) var lastMessageByUser: [String: ChatMessage] = [:]
//
//    /// All messages per chatId (used by ChatScreen)
//    @Published private(set) var messagesByChatId: [String: [ChatMessage]] = [:]
//
//    /// Which chat is currently open (OTHER userId)
//    @Published var activeChatUserId: String? = nil
//
//    private init() {}
//
//    /// Sum of all unread counts (used for tab badge)
//    var totalUnread: Int {
//        unreadByUser.values.reduce(0, +)
//    }
//
//    // MARK: - Public helpers
//
//    func unreadCount(for userId: String) -> Int {
//        unreadByUser[userId, default: 0]
//    }
//
//    func lastPreview(for userId: String) -> ChatMessage? {
//        lastMessageByUser[userId]
//    }
//
//    func messages(for chatId: String) -> [ChatMessage] {
//        messagesByChatId[chatId] ?? []
//    }
//
//    // MARK: - Append messages (incoming OR outgoing)
//
//    /// Append any message (incoming or outgoing) and update previews / unread.
//    /// `myId` is the current logged-in user ID.
//    func append(_ msg: ChatMessage, myId: String) {
//        // --- 1) Store in per-chat history with de-dupe ---
//        var existing = messagesByChatId[msg.chatId] ?? []
//
//        // a) duplicate id?
//        if existing.contains(where: { $0.id == msg.id }) {
//            return
//        }
//
//        // b) same content/sender/time window (~3s)? -> treat as socket echo
//        let isEcho = existing.contains(where: {
//            $0.fromUserId == msg.fromUserId &&
//            $0.toUserId == msg.toUserId &&
//            $0.text == msg.text &&
//            abs($0.createdAt.timeIntervalSince(msg.createdAt)) < 3
//        })
//        if isEcho { return }
//
//        existing.append(msg)
//        existing.sort { $0.createdAt < $1.createdAt }
//        messagesByChatId[msg.chatId] = existing
//
//        // --- 2) Update previews + unread counts ---
//
//        // Outgoing: from me -> preview under recipient
//        if msg.fromUserId == myId {
//            lastMessageByUser[msg.toUserId] = msg
//            // outgoing should not increment unread
//            return
//        }
//
//        // Incoming TO me: preview under sender + maybe unread
//        if msg.toUserId == myId {
//            lastMessageByUser[msg.fromUserId] = msg
//
//            // If I'm not viewing that chat right now, increment unread
//            if activeChatUserId != msg.fromUserId {
//                unreadByUser[msg.fromUserId, default: 0] += 1
//            }
//        }
//    }
//
//    // MARK: - Read / Reset
//
//    /// Mark a particular chat as read
//    func markRead(userId: String) {
//        unreadByUser[userId] = 0
//        // Remove zero entries so we don't keep junk keys
//        unreadByUser = unreadByUser.filter { $0.value > 0 }
//    }
//
//    /// Reset everything (logout / switch user / restart swiping)
//    func reset() {
//        unreadByUser.removeAll()
//        lastMessageByUser.removeAll()
//        messagesByChatId.removeAll()
//        activeChatUserId = nil
//    }
//
//    // MARK: - Per-pair clear (used by Unmatch)
//
//    /// Clear chat history + previews + unread for a single other user.
//    /// `chatId` format MUST match backend: min(me, other) + "_" + max(me, other)
//    func clearChat(with otherUserId: String, myId: String) {
//        let chatId = makeChatId(myId: myId, otherUserId: otherUserId)
//
//        messagesByChatId.removeValue(forKey: chatId)
//        unreadByUser.removeValue(forKey: otherUserId)
//        lastMessageByUser.removeValue(forKey: otherUserId)
//
//        if activeChatUserId == otherUserId {
//            activeChatUserId = nil
//        }
//
//        print("🧹 ChatStore: cleared chat with \(otherUserId) (chatId: \(chatId))")
//    }
//
//    // MARK: - Internal helpers
//
//    /// Must match the server's chatId logic: [a, b].sort().join("_")
//    private func makeChatId(myId: String, otherUserId: String) -> String {
//        let ids = [myId, otherUserId].sorted()
//        return "\(ids[0])_\(ids[1])"
//    }
//}
//  ChatStore.swift
//  NetSwipe
//
//  Central in-memory store for chat messages, previews, and unread counts.
//

import Foundation
import Combine

@MainActor
final class ChatStore: ObservableObject {
    static let shared = ChatStore()

    /// Unread message count per other user identifier.
    @Published private(set) var unreadByUser: [String: Int] = [:]

    /// Last message per other user (used for previews in `ChatListScreen`).
    @Published private(set) var lastMessageByUser: [String: ChatMessage] = [:]

    /// All messages grouped by chat identifier.
    @Published private(set) var messagesByChatId: [String: [ChatMessage]] = [:]

    /// Identifier of the user whose chat is currently open.
    @Published var activeChatUserId: String? = nil

    private init() {}

    /// Total unread message count across all conversations (used for tab badge).
    var totalUnread: Int {
        unreadByUser.values.reduce(0, +)
    }

    // MARK: - Public Helpers

    func unreadCount(for userId: String) -> Int {
        unreadByUser[userId, default: 0]
    }

    func lastPreview(for userId: String) -> ChatMessage? {
        lastMessageByUser[userId]
    }

    func messages(for chatId: String) -> [ChatMessage] {
        messagesByChatId[chatId] ?? []
    }

    // MARK: - Append Messages (Incoming or Outgoing)

    /// Appends a message to the store and updates previews and unread counts.
    /// - Parameter myId: The currently authenticated user identifier.
    func append(_ msg: ChatMessage, myId: String) {
        // 1) Store in per-chat history with de-duplication.
        var existing = messagesByChatId[msg.chatId] ?? []

        // a) Skip if a message with the same identifier already exists.
        if existing.contains(where: { $0.id == msg.id }) {
            return
        }

        // b) Avoid treating socket echoes as new messages (same sender, text, and time window).
        let isEcho = existing.contains(where: {
            $0.fromUserId == msg.fromUserId &&
            $0.toUserId == msg.toUserId &&
            $0.text == msg.text &&
            abs($0.createdAt.timeIntervalSince(msg.createdAt)) < 3
        })
        if isEcho { return }

        existing.append(msg)
        existing.sort { $0.createdAt < $1.createdAt }
        messagesByChatId[msg.chatId] = existing

        // 2) Update previews and unread counts.

        // Outgoing messages: preview is stored under the recipient; unread is not incremented.
        if msg.fromUserId == myId {
            lastMessageByUser[msg.toUserId] = msg
            return
        }

        // Incoming messages: preview is stored under the sender; unread increments if chat is not active.
        if msg.toUserId == myId {
            lastMessageByUser[msg.fromUserId] = msg

            if activeChatUserId != msg.fromUserId {
                unreadByUser[msg.fromUserId, default: 0] += 1
            }
        }
    }

    // MARK: - Read / Reset

    /// Marks a conversation with a specific user as read.
    func markRead(userId: String) {
        unreadByUser[userId] = 0
        // Remove keys with zero values to avoid retaining unused entries.
        unreadByUser = unreadByUser.filter { $0.value > 0 }
    }

    /// Clears all chat-related state (used on logout, user switch, or restart swiping).
    func reset() {
        unreadByUser.removeAll()
        lastMessageByUser.removeAll()
        messagesByChatId.removeAll()
        activeChatUserId = nil
    }

    // MARK: - Per-Conversation Clear (Used by Unmatch)

    /// Clears chat history, preview, and unread state for a single other user.
    /// - Note: `chatId` must match the server convention: `[me, other].sorted().joined(by: "_")`.
    func clearChat(with otherUserId: String, myId: String) {
        let chatId = makeChatId(myId: myId, otherUserId: otherUserId)

        messagesByChatId.removeValue(forKey: chatId)
        unreadByUser.removeValue(forKey: otherUserId)
        lastMessageByUser.removeValue(forKey: otherUserId)

        if activeChatUserId == otherUserId {
            activeChatUserId = nil
        }

        print("🧹 ChatStore: cleared chat with \(otherUserId) (chatId: \(chatId))")
    }

    // MARK: - Internal Helpers

    /// Matches the server-side chatId logic: `[a, b].sorted().joined(separator: "_")`.
    private func makeChatId(myId: String, otherUserId: String) -> String {
        let ids = [myId, otherUserId].sorted()
        return "\(ids[0])_\(ids[1])"
    }
}
