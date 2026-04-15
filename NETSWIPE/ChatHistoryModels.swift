//  ChatHistoryModels.swift
//  NetSwipe
//
//  Models for the /chat/history endpoint.
//

import Foundation

// MARK: - Top-level response for /chat/history/:otherUserId

struct ChatHistoryResponse: Codable {
    let success: Bool
    let chatId: String?
    let count: Int?
    let messages: [MessageDTO]?

    /// Maps raw DTOs to strongly typed `ChatMessage` models.
    var chatMessages: [ChatMessage] {
        (messages ?? []).map { $0.asChatMessage() }
    }
}

// MARK: - Raw message DTO from backend

struct MessageDTO: Codable {
    let _id: String?
    let chatId: String?
    let fromUserId: String?
    let toUserId: String?
    let text: String?
    let createdAt: String?   // ISO 8601 date string from backend (e.g. "2025-12-02T04:33:59.264Z")

    // Shared formatter for decoding ISO 8601 timestamps
    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    /// Converts `MessageDTO` into a `ChatMessage` instance.
    func asChatMessage() -> ChatMessage {
        let date: Date

        if let createdAt = createdAt,
           let parsed = MessageDTO.isoFormatter.date(from: createdAt) {
            date = parsed
        } else {
            date = Date()
        }

        return ChatMessage(
            id: _id ?? UUID().uuidString,
            chatId: chatId ?? "",
            fromUserId: fromUserId ?? "",
            toUserId: toUserId ?? "",
            text: text ?? "",
            createdAt: date
        )
    }
}
