////
////  SocketService.swift
////  NETSWIPE
////
////  ✅ Multi-listener Socket.IO service
////  ✅ Attaches "new_message" ONCE in init
////  ✅ Works with:
////      • ChatListScreen global unread listener  -> onNewMessage { ... }
////      • ChatScreen local listener             -> store UUID + removeNewMessageHandler(_:)
////
//
//import Foundation
//import SocketIO
//import Combine
//
//final class SocketService: ObservableObject {
//    static let shared = SocketService()
//
//    private let manager: SocketManager
//    private let socket: SocketIOClient
//
//    @Published private(set) var isConnected: Bool = false
//
//    /// Multiple handlers keyed by UUID so different views can subscribe safely.
//    private var newMessageHandlers: [UUID: (ChatMessage) -> Void] = [:]
//
//    private init() {
//        // Same base URL as your NetworkManager (simulator)
//        let url = URL(string: "http://127.0.0.1:8000")!
//
//        manager = SocketManager(
//            socketURL: url,
//            config: [
//                .log(true),
//                .compress,
//                .forceWebsockets(true) // helps simulator reliability
//            ]
//        )
//
//        socket = manager.defaultSocket
//
//        // MARK: - Base events
//        socket.on(clientEvent: .connect) { [weak self] _, _ in
//            self?.isConnected = true
//            print("🟣 socket connected")
//        }
//
//        socket.on(clientEvent: .disconnect) { [weak self] _, _ in
//            self?.isConnected = false
//            print("🔴 socket disconnected")
//        }
//
//        socket.on(clientEvent: .error) { data, _ in
//            print("❌ socket error:", data)
//        }
//
//        // MARK: - Global "new_message" listener (broadcast to all handlers)
//        socket.on("new_message") { [weak self] data, _ in
//            guard let dict = data.first as? [String: Any] else { return }
//
//            let id           = dict["_id"] as? String ?? UUID().uuidString
//            let chatId       = dict["chatId"] as? String ?? ""
//            let from         = dict["fromUserId"] as? String ?? ""
//            let to           = dict["toUserId"] as? String ?? ""
//            let text         = dict["text"] as? String ?? ""
//            let createdAtStr = dict["createdAt"] as? String ?? ""
//            let createdAt    = ISO8601DateFormatter().date(from: createdAtStr) ?? Date()
//
//            let msg = ChatMessage(
//                id: id,
//                chatId: chatId,
//                fromUserId: from,
//                toUserId: to,
//                text: text,
//                createdAt: createdAt
//            )
//
//            DispatchQueue.main.async {
//                // Broadcast to all registered handlers
//                self?.newMessageHandlers.values.forEach { $0(msg) }
//            }
//        }
//    }
//
//    // MARK: - Connection
//
//    func connectIfNeeded() {
//        if socket.status != .connected && socket.status != .connecting {
//            socket.connect()
//        }
//    }
//
//    func join(userId: String) {
//        guard !userId.isEmpty else { return }
//        connectIfNeeded()
//        socket.emit("join", ["userId": userId])
//        print("✅ join room for user:", userId)
//    }
//
//    func disconnect() {
//        socket.disconnect()
//        isConnected = false
//        newMessageHandlers.removeAll()
//    }
//
//    // MARK: - Send Message
//
//    func sendMessage(from: String, to: String, text: String) {
//        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !from.isEmpty, !to.isEmpty, !trimmed.isEmpty else { return }
//
//        connectIfNeeded()
//        socket.emit("send_message", [
//            "fromUserId": from,
//            "toUserId": to,
//            "text": trimmed
//        ])
//    }
//
//    /// Convenience overload used by ChatScreen
//    func sendMessage(_ msg: ChatMessage) {
//        sendMessage(from: msg.fromUserId, to: msg.toUserId, text: msg.text)
//    }
//
//    // MARK: - Multi Listener API
//
//    /// Subscribe to new messages. `ChatListScreen` and `ChatScreen` can both call this.
//    /// You can ignore the returned UUID if you don't plan to remove the handler.
//    @discardableResult
//    func onNewMessage(_ handler: @escaping (ChatMessage) -> Void) -> UUID {
//        let id = UUID()
//        newMessageHandlers[id] = handler
//        return id
//    }
//
//    /// Remove a specific handler (useful in `ChatScreen.onDisappear`).
//    func removeNewMessageHandler(_ id: UUID?) {
//        guard let id else { return }
//        newMessageHandlers.removeValue(forKey: id)
//    }
//
//    /// Optional: clear everything (e.g., on full logout)
//    func removeAllNewMessageHandlers() {
//        newMessageHandlers.removeAll()
//    }
//}
//
//  SocketService.swift
//  NetSwipe
//
//  ✅ Multi-listener Socket.IO service
//  ✅ Attaches "new_message" ONCE in init
//  ✅ Works with:
//      • ChatListScreen global listener  -> onNewMessage { ... }
//      • ChatScreen local listener       -> store UUID + removeNewMessageHandler(_:)
//

import Foundation
import SocketIO
import Combine

final class SocketService: ObservableObject {
    static let shared = SocketService()

    private let manager: SocketManager
    private let socket: SocketIOClient

    @Published private(set) var isConnected: Bool = false

    /// Multiple handlers keyed by UUID so different views can subscribe safely.
    private var newMessageHandlers: [UUID: (ChatMessage) -> Void] = [:]

    private init() {
        // Same base URL as your NetworkManager
        let url = URL(string: "http://192.168.1.23:5001")!

        manager = SocketManager(
            socketURL: url,
            config: [
                .log(true),
                .compress,
                .forceWebsockets(true) // helps simulator reliability
            ]
        )

        socket = manager.defaultSocket

        // MARK: - Base events
        socket.on(clientEvent: .connect) { [weak self] _, _ in
            self?.isConnected = true
            print("🟣 socket connected")
        }

        socket.on(clientEvent: .disconnect) { [weak self] _, _ in
            self?.isConnected = false
            print("🔴 socket disconnected")
        }

        socket.on(clientEvent: .error) { data, _ in
            print("❌ socket error:", data)
        }

        // MARK: - Global "new_message" listener (broadcast to all handlers)
        socket.on("new_message") { [weak self] data, _ in
            guard let dict = data.first as? [String: Any] else { return }

            let id           = dict["_id"] as? String ?? UUID().uuidString
            let chatId       = dict["chatId"] as? String ?? ""
            let from         = dict["fromUserId"] as? String ?? ""
            let to           = dict["toUserId"] as? String ?? ""
            let text         = dict["text"] as? String ?? ""
            let createdAtStr = dict["createdAt"] as? String ?? ""
            let createdAt    = ISO8601DateFormatter().date(from: createdAtStr) ?? Date()

            let msg = ChatMessage(
                id: id,
                chatId: chatId,
                fromUserId: from,
                toUserId: to,
                text: text,
                createdAt: createdAt
            )

            DispatchQueue.main.async {
                // Broadcast to all registered handlers (ChatListScreen, ChatScreen, etc.)
                self?.newMessageHandlers.values.forEach { $0(msg) }
            }
        }
    }

    // MARK: - Connection

    func connectIfNeeded() {
        if socket.status != .connected && socket.status != .connecting {
            socket.connect()
        }
    }

    func join(userId: String) {
        guard !userId.isEmpty else { return }
        connectIfNeeded()
        socket.emit("join", ["userId": userId])
        print("✅ join room for user:", userId)
    }

    func disconnect() {
        socket.disconnect()
        isConnected = false
        newMessageHandlers.removeAll()
    }

    // MARK: - Send Message

    func sendMessage(from: String, to: String, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !from.isEmpty, !to.isEmpty, !trimmed.isEmpty else { return }

        connectIfNeeded()
        socket.emit("send_message", [
            "fromUserId": from,
            "toUserId": to,
            "text": trimmed
        ])
    }

    /// Convenience overload used by ChatScreen
    func sendMessage(_ msg: ChatMessage) {
        sendMessage(from: msg.fromUserId, to: msg.toUserId, text: msg.text)
    }

    // MARK: - Multi Listener API

    /// Subscribe to new messages. `ChatListScreen` and `ChatScreen` can both call this.
    /// You can ignore the returned UUID if you don't plan to remove the handler.
    @discardableResult
    func onNewMessage(_ handler: @escaping (ChatMessage) -> Void) -> UUID {
        let id = UUID()
        newMessageHandlers[id] = handler
        return id
    }

    /// Remove a specific handler (useful in `ChatScreen.onDisappear`).
    func removeNewMessageHandler(_ id: UUID?) {
        guard let id else { return }
        newMessageHandlers.removeValue(forKey: id)
    }

    /// Optional: clear everything (e.g., on full logout)
    func removeAllNewMessageHandlers() {
        newMessageHandlers.removeAll()
    }
}
