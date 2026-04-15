//  AuthModels.swift
//  NetSwipe
//

import Foundation

// MARK: - Registration
struct RegisterRequest: Codable {
    let email: String
    let username: String
    let password: String
}

struct RegisterResponse: Codable {
    let message: String
    let userId: String?        // Backend-generated MongoDB identifier
    let email: String?
    let username: String?
    let verified: Bool?        // Indicates whether the account has been OTP-verified
    let profileCompleted: Bool?
}

// MARK: - OTP Verification
struct VerifyRequest: Codable {
    let email: String
    let otp: String
}

struct VerifyResponse: Codable {
    let message: String
    let verified: Bool?
    let userId: String?        // Present when the backend returns the user identifier on success
}

// MARK: - Login
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
    let userId: String
    let email: String
    let username: String
}

// MARK: - Generic API Error Response
struct APIErrorResponse: Codable, Error {
    let message: String
}
