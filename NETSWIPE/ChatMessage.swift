//
////
////  ChatMessage.swift
////  NetSwipe

import Foundation

struct ChatMessage: Identifiable, Equatable, Codable, Hashable {
    let id: String
    let chatId: String
    let fromUserId: String
    let toUserId: String
    let text: String
    let createdAt: Date

    static func makeChatId(_ a: String, _ b: String) -> String {
        [a, b].sorted().joined(separator: "_")
    }
}
