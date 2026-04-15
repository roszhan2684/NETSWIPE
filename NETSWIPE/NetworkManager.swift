////
////  NetworkManager.swift
////  NetSwipe
////
////  Final version — enhanced logging, safe decoding, and backend alignment
////
//
//import Foundation
//import SwiftUI
//import Combine
//
//final class NetworkManager {
//    static let shared = NetworkManager()
//
//    // ⚙️ Change IP if testing on real iPhone (find via System Preferences → Network)
//    // Example: "http://192.168.1.4:8000"
//    private let baseURL = "http://127.0.0.1:8000"
//
//    private init() {}
//
//    // Shared JSON decoder configured for backend’s ISO8601 timestamps
//    private var jsonDecoder: JSONDecoder {
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .iso8601
//        return decoder
//    }
//
//    // MARK: - POST Request
//    func postRequest<T: Codable, U: Codable>(
//        endpoint: String,
//        body: T,
//        completion: @escaping (Result<U, Error>) -> Void
//    ) {
//        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
//            print("❌ Invalid URL: \(baseURL)\(endpoint)")
//            completion(.failure(NetworkError.invalidURL))
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // 🔑 Attach token if available
//        if let token = UserDefaults.standard.string(forKey: "authToken") {
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }
//
//        // 🧩 Encode safely
//        do {
//            request.httpBody = try JSONEncoder().encode(body)
//        } catch {
//            print("❌ JSON Encoding Error:", error.localizedDescription)
//            completion(.failure(NetworkError.encodingFailed))
//            return
//        }
//
//        // 🚀 Execute
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("🌐 ❌ Network Error:", error.localizedDescription)
//                completion(.failure(error))
//                return
//            }
//
//            guard let http = response as? HTTPURLResponse else {
//                completion(.failure(NetworkError.invalidResponse))
//                return
//            }
//
//            // Log details
//            print("\n🌐 [POST] \(url.absoluteString)")
//            print("📬 Status Code:", http.statusCode)
//
//            guard let data = data else {
//                print("⚠️ No response data received")
//                completion(.failure(NetworkError.noData))
//                return
//            }
//
//            // Show raw response
//            print("🟢 Raw JSON Response:")
//            print(String(data: data, encoding: .utf8) ?? "⚠️ [Unreadable JSON]")
//
//            // Validate HTTP code range
//            guard (200...299).contains(http.statusCode) else {
//                print("❌ Server Error (\(http.statusCode))")
//                completion(.failure(NetworkError.serverError(code: http.statusCode)))
//                return
//            }
//
//            // ✅ Decode response
//            do {
//                let decoded = try self.jsonDecoder.decode(U.self, from: data)
//                DispatchQueue.main.async {
//                    completion(.success(decoded))
//                }
//            } catch {
//                print("❌ POST Decoding Error:", error)
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//            }
//        }.resume()
//    }
//
//    // MARK: - GET Request
//    func getRequest<U: Codable>(
//        endpoint: String,
//        completion: @escaping (Result<U, Error>) -> Void
//    ) {
//        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
//            print("❌ Invalid URL: \(baseURL)\(endpoint)")
//            completion(.failure(NetworkError.invalidURL))
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//
//        // 🔑 Attach token if available
//        if let token = UserDefaults.standard.string(forKey: "authToken") {
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }
//
//        // 🚀 Execute
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("🌐 ❌ Network Error:", error.localizedDescription)
//                completion(.failure(error))
//                return
//            }
//
//            guard let http = response as? HTTPURLResponse else {
//                completion(.failure(NetworkError.invalidResponse))
//                return
//            }
//
//            print("\n🌐 [GET] \(url.absoluteString)")
//            print("📬 Status Code:", http.statusCode)
//
//            guard let data = data else {
//                print("⚠️ No response data received")
//                completion(.failure(NetworkError.noData))
//                return
//            }
//
//            print("🟢 Raw JSON Response:")
//            print(String(data: data, encoding: .utf8) ?? "⚠️ [Unreadable JSON]")
//
//            guard (200...299).contains(http.statusCode) else {
//                print("❌ Server Error (\(http.statusCode))")
//                completion(.failure(NetworkError.serverError(code: http.statusCode)))
//                return
//            }
//
//            do {
//                let decoded = try self.jsonDecoder.decode(U.self, from: data)
//                DispatchQueue.main.async {
//                    completion(.success(decoded))
//                }
//            } catch {
//                print("❌ GET Decoding Error:", error)
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//            }
//        }.resume()
//    }
//}
//
//// MARK: - Network Error Enum
//enum NetworkError: LocalizedError {
//    case invalidURL
//    case invalidResponse
//    case encodingFailed
//    case noData
//    case serverError(code: Int)
//
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL:
//            return "The request URL is invalid."
//        case .invalidResponse:
//            return "The server returned an invalid response."
//        case .encodingFailed:
//            return "Failed to encode request body."
//        case .noData:
//            return "No data received from the server."
//        case .serverError(let code):
//            return "Server returned error code \(code)."
//        }
//    }
//}
//
////  NetworkManager.swift
////  NetSwipe
////
////  Final version — enhanced logging, safe decoding, and backend alignment
////
//
//import Foundation
//import SwiftUI
//import Combine
//
//final class NetworkManager {
//    static let shared = NetworkManager()
//
//    // ⚙️ For Simulator: 127.0.0.1 == your Mac
//    // ⚙️ For real iPhone on same Wi-Fi: use your Mac’s LAN IP (e.g. "http://192.168.1.4:8000")
//    private let baseURL = "http://127.0.0.1:8000"
//
//    private init() {}
//
//    // Shared JSON decoder (you can extend this later if you add Date fields)
//    private var jsonDecoder: JSONDecoder {
//        let decoder = JSONDecoder()
//        // Only used if you decode Date properties (safe to keep)
//        decoder.dateDecodingStrategy = .iso8601
//        return decoder
//    }
//
//    // Shared JSON encoder so we can also log the outgoing body
//    private var jsonEncoder: JSONEncoder {
//        let encoder = JSONEncoder()
//        return encoder
//    }
//
//    // MARK: - POST Request
//    func postRequest<T: Codable, U: Codable>(
//        endpoint: String,
//        body: T,
//        completion: @escaping (Result<U, Error>) -> Void
//    ) {
//        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
//            print("❌ Invalid URL: \(baseURL)\(endpoint)")
//            DispatchQueue.main.async {
//                completion(.failure(NetworkError.invalidURL))
//            }
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // 🔑 Attach token if available
//        if let token = UserDefaults.standard.string(forKey: "authToken") {
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }
//
//        // 🧩 Encode safely + log outgoing JSON
//        do {
//            let encodedBody = try jsonEncoder.encode(body)
//            request.httpBody = encodedBody
//
//            if let jsonString = String(data: encodedBody, encoding: .utf8) {
//                print("\n📤 [POST BODY] \(endpoint)")
//                print(jsonString.prefix(1000)) // avoid spamming full base64 in console
//                if jsonString.count > 1000 {
//                    print("… (truncated body, total length: \(jsonString.count) chars)")
//                }
//            } else {
//                print("⚠️ Could not stringify request body for logging.")
//            }
//        } catch {
//            print("❌ JSON Encoding Error:", error.localizedDescription)
//            DispatchQueue.main.async {
//                completion(.failure(NetworkError.encodingFailed))
//            }
//            return
//        }
//
//        // 🚀 Execute
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            // Network-level error
//            if let error = error {
//                print("🌐 ❌ Network Error:", error.localizedDescription)
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//                return
//            }
//
//            guard let http = response as? HTTPURLResponse else {
//                DispatchQueue.main.async {
//                    completion(.failure(NetworkError.invalidResponse))
//                }
//                return
//            }
//
//            // Log status
//            print("\n🌐 [POST] \(url.absoluteString)")
//            print("📬 Status Code:", http.statusCode)
//
//            guard let data = data else {
//                print("⚠️ No response data received")
//                DispatchQueue.main.async {
//                    completion(.failure(NetworkError.noData))
//                }
//                return
//            }
//
//            // Show raw response (useful for debugging backend JSON)
//            if let raw = String(data: data, encoding: .utf8) {
//                print("🟢 Raw JSON Response:")
//                print(raw)
//            } else {
//                print("⚠️ [Unreadable JSON]")
//            }
//
//            // Validate HTTP code range
//            guard (200...299).contains(http.statusCode) else {
//                print("❌ Server Error (\(http.statusCode))")
//                DispatchQueue.main.async {
//                    completion(.failure(NetworkError.serverError(code: http.statusCode)))
//                }
//                return
//            }
//
//            // ✅ Decode response → U (e.g., UpdateProfileResponse)
//            do {
//                let decoded = try self.jsonDecoder.decode(U.self, from: data)
//                DispatchQueue.main.async {
//                    completion(.success(decoded))
//                }
//            } catch {
//                print("❌ POST Decoding Error:", error)
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//            }
//        }.resume()
//    }
//
//    // MARK: - GET Request
//    func getRequest<U: Codable>(
//        endpoint: String,
//        completion: @escaping (Result<U, Error>) -> Void
//    ) {
//        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
//            print("❌ Invalid URL: \(baseURL)\(endpoint)")
//            DispatchQueue.main.async {
//                completion(.failure(NetworkError.invalidURL))
//            }
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//
//        // 🔑 Attach token if available
//        if let token = UserDefaults.standard.string(forKey: "authToken") {
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }
//
//        // 🚀 Execute
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("🌐 ❌ Network Error:", error.localizedDescription)
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//                return
//            }
//
//            guard let http = response as? HTTPURLResponse else {
//                DispatchQueue.main.async {
//                    completion(.failure(NetworkError.invalidResponse))
//                }
//                return
//            }
//
//            print("\n🌐 [GET] \(url.absoluteString)")
//            print("📬 Status Code:", http.statusCode)
//
//            guard let data = data else {
//                print("⚠️ No response data received")
//                DispatchQueue.main.async {
//                    completion(.failure(NetworkError.noData))
//                }
//                return
//            }
//
//            if let raw = String(data: data, encoding: .utf8) {
//                print("🟢 Raw JSON Response:")
//                print(raw)
//            } else {
//                print("⚠️ [Unreadable JSON]")
//            }
//
//            guard (200...299).contains(http.statusCode) else {
//                print("❌ Server Error (\(http.statusCode))")
//                DispatchQueue.main.async {
//                    completion(.failure(NetworkError.serverError(code: http.statusCode)))
//                }
//                return
//            }
//
//            do {
//                let decoded = try self.jsonDecoder.decode(U.self, from: data)
//                DispatchQueue.main.async {
//                    completion(.success(decoded))
//                }
//            } catch {
//                print("❌ GET Decoding Error:", error)
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//            }
//        }.resume()
//    }
//}
//
//// MARK: - Network Error Enum
//enum NetworkError: LocalizedError {
//    case invalidURL
//    case invalidResponse
//    case encodingFailed
//    case noData
//    case serverError(code: Int)
//
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL:
//            return "The request URL is invalid."
//        case .invalidResponse:
//            return "The server returned an invalid response."
//        case .encodingFailed:
//            return "Failed to encode request body."
//        case .noData:
//            return "No data received from the server."
//        case .serverError(let code):
//            return "Server returned error code \(code)."
//        }
//    }
//}
////  NetworkManager.swift
////  NetSwipe
////
////  Final version — enhanced logging, safe decoding, backend alignment
////  + Added Dictionary POST overload (for older calls)
////  + ✅ Added DELETE support (for profile delete)
////
//
//import Foundation
//import SwiftUI
//import Combine
//
//final class NetworkManager {
//    static let shared = NetworkManager()
//
//    // ⚙️ Simulator: 127.0.0.1 == your Mac
//    // ⚙️ Real iPhone: use your Mac LAN IP
//    private let baseURL = "http://127.0.0.1:8000"
//
//    private init() {}
//
//    // Shared JSON decoder
//    private var jsonDecoder: JSONDecoder {
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .iso8601
//        return decoder
//    }
//
//    // Shared JSON encoder
//    private var jsonEncoder: JSONEncoder {
//        JSONEncoder()
//    }
//
//    // MARK: - Build Request
//    private func makeRequest(url: URL, method: String, bodyData: Data? = nil) -> URLRequest {
//        var request = URLRequest(url: url)
//        request.httpMethod = method
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//
//        // Attach token if available
//        if let token = UserDefaults.standard.string(forKey: "authToken"),
//           !token.isEmpty {
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }
//
//        request.httpBody = bodyData
//        return request
//    }
//
//    // MARK: - POST Request (Codable body)
//    func postRequest<T: Codable, U: Codable>(
//        endpoint: String,
//        body: T,
//        completion: @escaping (Result<U, Error>) -> Void
//    ) {
//        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
//            print("❌ Invalid URL: \(baseURL)\(endpoint)")
//            DispatchQueue.main.async {
//                completion(.failure(NetworkError.invalidURL))
//            }
//            return
//        }
//
//        // Encode body
//        let encodedBody: Data
//        do {
//            encodedBody = try jsonEncoder.encode(body)
//
//            if let jsonString = String(data: encodedBody, encoding: .utf8) {
//                print("\n📤 [POST BODY Codable] \(endpoint)")
//                print(jsonString.prefix(1000))
//                if jsonString.count > 1000 {
//                    print("… (truncated body, total length: \(jsonString.count) chars)")
//                }
//            }
//        } catch {
//            print("❌ JSON Encoding Error:", error.localizedDescription)
//            DispatchQueue.main.async {
//                completion(.failure(NetworkError.encodingFailed))
//            }
//            return
//        }
//
//        let request = makeRequest(url: url, method: "POST", bodyData: encodedBody)
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            self.handleResponse(
//                data: data,
//                response: response,
//                error: error,
//                method: "POST",
//                url: url,
//                completion: completion
//            )
//        }.resume()
//    }
//
//    // MARK: - ✅ POST Request ([String: Any] body)
//    // Use only when you don’t want to create Codable structs.
//    func postRequest<U: Codable>(
//        endpoint: String,
//        body: [String: Any],
//        completion: @escaping (Result<U, Error>) -> Void
//    ) {
//        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
//            print("❌ Invalid URL: \(baseURL)\(endpoint)")
//            DispatchQueue.main.async {
//                completion(.failure(NetworkError.invalidURL))
//            }
//            return
//        }
//
//        let bodyData: Data
//        do {
//            bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
//
//            if let jsonString = String(data: bodyData, encoding: .utf8) {
//                print("\n📤 [POST BODY Dict] \(endpoint)")
//                print(jsonString.prefix(1000))
//                if jsonString.count > 1000 {
//                    print("… (truncated body, total length: \(jsonString.count) chars)")
//                }
//            }
//        } catch {
//            print("❌ Dict JSONSerialization Error:", error.localizedDescription)
//            DispatchQueue.main.async {
//                completion(.failure(NetworkError.encodingFailed))
//            }
//            return
//        }
//
//        let request = makeRequest(url: url, method: "POST", bodyData: bodyData)
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            self.handleResponse(
//                data: data,
//                response: response,
//                error: error,
//                method: "POST",
//                url: url,
//                completion: completion
//            )
//        }.resume()
//    }
//
//    // MARK: - GET Request
//    func getRequest<U: Codable>(
//        endpoint: String,
//        completion: @escaping (Result<U, Error>) -> Void
//    ) {
//        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
//            print("❌ Invalid URL: \(baseURL)\(endpoint)")
//            DispatchQueue.main.async {
//                completion(.failure(NetworkError.invalidURL))
//            }
//            return
//        }
//
//        let request = makeRequest(url: url, method: "GET")
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            self.handleResponse(
//                data: data,
//                response: response,
//                error: error,
//                method: "GET",
//                url: url,
//                completion: completion
//            )
//        }.resume()
//    }
//
//    // MARK: - ✅ DELETE Request (no body)
//    func deleteRequest<U: Codable>(
//        endpoint: String,
//        completion: @escaping (Result<U, Error>) -> Void
//    ) {
//        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
//            print("❌ Invalid URL: \(baseURL)\(endpoint)")
//            DispatchQueue.main.async {
//                completion(.failure(NetworkError.invalidURL))
//            }
//            return
//        }
//
//        let request = makeRequest(url: url, method: "DELETE")
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            self.handleResponse(
//                data: data,
//                response: response,
//                error: error,
//                method: "DELETE",
//                url: url,
//                completion: completion
//            )
//        }.resume()
//    }
//
//    // MARK: - ✅ DELETE Request (optional Codable body)
//    // If backend ever needs a body for delete, use this.
//    func deleteRequest<T: Codable, U: Codable>(
//        endpoint: String,
//        body: T,
//        completion: @escaping (Result<U, Error>) -> Void
//    ) {
//        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
//            print("❌ Invalid URL: \(baseURL)\(endpoint)")
//            DispatchQueue.main.async {
//                completion(.failure(NetworkError.invalidURL))
//            }
//            return
//        }
//
//        let encodedBody: Data
//        do {
//            encodedBody = try jsonEncoder.encode(body)
//            if let jsonString = String(data: encodedBody, encoding: .utf8) {
//                print("\n📤 [DELETE BODY Codable] \(endpoint)")
//                print(jsonString.prefix(1000))
//            }
//        } catch {
//            print("❌ DELETE JSON Encoding Error:", error.localizedDescription)
//            DispatchQueue.main.async {
//                completion(.failure(NetworkError.encodingFailed))
//            }
//            return
//        }
//
//        let request = makeRequest(url: url, method: "DELETE", bodyData: encodedBody)
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            self.handleResponse(
//                data: data,
//                response: response,
//                error: error,
//                method: "DELETE",
//                url: url,
//                completion: completion
//            )
//        }.resume()
//    }
//
//    // MARK: - Shared Response Handler
//    private func handleResponse<U: Codable>(
//        data: Data?,
//        response: URLResponse?,
//        error: Error?,
//        method: String,
//        url: URL,
//        completion: @escaping (Result<U, Error>) -> Void
//    ) {
//        if let error = error {
//            print("🌐 ❌ Network Error:", error.localizedDescription)
//            DispatchQueue.main.async {
//                completion(.failure(error))
//            }
//            return
//        }
//
//        guard let http = response as? HTTPURLResponse else {
//            DispatchQueue.main.async {
//                completion(.failure(NetworkError.invalidResponse))
//            }
//            return
//        }
//
//        print("\n🌐 [\(method)] \(url.absoluteString)")
//        print("📬 Status Code:", http.statusCode)
//
//        guard let data = data else {
//            print("⚠️ No response data received")
//            DispatchQueue.main.async {
//                completion(.failure(NetworkError.noData))
//            }
//            return
//        }
//
//        if let raw = String(data: data, encoding: .utf8) {
//            print("🟢 Raw JSON Response:")
//            print(raw.prefix(4000))
//            if raw.count > 4000 {
//                print("… (truncated response, total length: \(raw.count) chars)")
//            }
//        } else {
//            print("⚠️ [Unreadable JSON]")
//        }
//
//        guard (200...299).contains(http.statusCode) else {
//            print("❌ Server Error (\(http.statusCode))")
//            DispatchQueue.main.async {
//                completion(.failure(NetworkError.serverError(code: http.statusCode)))
//            }
//            return
//        }
//
//        do {
//            let decoded = try self.jsonDecoder.decode(U.self, from: data)
//            DispatchQueue.main.async {
//                completion(.success(decoded))
//            }
//        } catch {
//            print("❌ \(method) Decoding Error:", error)
//            DispatchQueue.main.async {
//                completion(.failure(error))
//            }
//        }
//    }
//}
//
//// MARK: - Network Error Enum
//enum NetworkError: LocalizedError {
//    case invalidURL
//    case invalidResponse
//    case encodingFailed
//    case noData
//    case serverError(code: Int)
//
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL:
//            return "The request URL is invalid."
//        case .invalidResponse:
//            return "The server returned an invalid response."
//        case .encodingFailed:
//            return "Failed to encode request body."
//        case .noData:
//            return "No data received from the server."
//        case .serverError(let code):
//            return "Server returned error code \(code)."
//        }
//    }
//}
//
//  NetworkManager.swift
//  NetSwipe
//
//  Final version — enhanced logging, safe decoding, backend alignment
//  + POST with Codable body
//  + POST with [String: Any] body
//  + GET
//  + DELETE (with or without body)
//

import Foundation
import SwiftUI
import Combine

final class NetworkManager {
    static let shared = NetworkManager()

    // ⚙️ Simulator: 127.0.0.1 == your Mac
    // ⚙️ Real iPhone: use your Mac's LAN IP
    private let baseURL = "http://192.168.1.23:5001"

    private init() {}

    // Shared JSON decoder
    private var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    // Shared JSON encoder
    private var jsonEncoder: JSONEncoder {
        JSONEncoder()
    }

    // MARK: - Build Request

    private func makeRequest(url: URL, method: String, bodyData: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method

        // Standard headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Attach Bearer token if available
        if let token = UserDefaults.standard.string(forKey: "authToken"),
           !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = bodyData
        return request
    }

    // MARK: - POST Request (Codable body)

    func postRequest<T: Codable, U: Codable>(
        endpoint: String,
        body: T,
        completion: @escaping (Result<U, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            print("❌ Invalid URL: \(baseURL)\(endpoint)")
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }

        // Encode body
        let encodedBody: Data
        do {
            encodedBody = try jsonEncoder.encode(body)

            if let jsonString = String(data: encodedBody, encoding: .utf8) {
                print("\n📤 [POST BODY Codable] \(endpoint)")
                print(jsonString.prefix(1000))
                if jsonString.count > 1000 {
                    print("… (truncated body, total length: \(jsonString.count) chars)")
                }
            }
        } catch {
            print("❌ JSON Encoding Error:", error.localizedDescription)
            DispatchQueue.main.async {
                completion(.failure(NetworkError.encodingFailed))
            }
            return
        }

        let request = makeRequest(url: url, method: "POST", bodyData: encodedBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            self.handleResponse(
                data: data,
                response: response,
                error: error,
                method: "POST",
                url: url,
                completion: completion
            )
        }.resume()
    }

    // MARK: - POST Request ([String: Any] body)

    /// Use this when you don’t want to define a Codable struct.
    func postRequest<U: Codable>(
        endpoint: String,
        body: [String: Any],
        completion: @escaping (Result<U, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            print("❌ Invalid URL: \(baseURL)\(endpoint)")
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }

        let bodyData: Data
        do {
            bodyData = try JSONSerialization.data(withJSONObject: body, options: [])

            if let jsonString = String(data: bodyData, encoding: .utf8) {
                print("\n📤 [POST BODY Dict] \(endpoint)")
                print(jsonString.prefix(1000))
                if jsonString.count > 1000 {
                    print("… (truncated body, total length: \(jsonString.count) chars)")
                }
            }
        } catch {
            print("❌ Dict JSONSerialization Error:", error.localizedDescription)
            DispatchQueue.main.async {
                completion(.failure(NetworkError.encodingFailed))
            }
            return
        }

        let request = makeRequest(url: url, method: "POST", bodyData: bodyData)

        URLSession.shared.dataTask(with: request) { data, response, error in
            self.handleResponse(
                data: data,
                response: response,
                error: error,
                method: "POST",
                url: url,
                completion: completion
            )
        }.resume()
    }

    // MARK: - GET Request

    func getRequest<U: Codable>(
        endpoint: String,
        completion: @escaping (Result<U, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            print("❌ Invalid URL: \(baseURL)\(endpoint)")
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }

        let request = makeRequest(url: url, method: "GET")

        URLSession.shared.dataTask(with: request) { data, response, error in
            self.handleResponse(
                data: data,
                response: response,
                error: error,
                method: "GET",
                url: url,
                completion: completion
            )
        }.resume()
    }

    // MARK: - DELETE Request (no body)

    func deleteRequest<U: Codable>(
        endpoint: String,
        completion: @escaping (Result<U, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            print("❌ Invalid URL: \(baseURL)\(endpoint)")
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }

        let request = makeRequest(url: url, method: "DELETE")

        URLSession.shared.dataTask(with: request) { data, response, error in
            self.handleResponse(
                data: data,
                response: response,
                error: error,
                method: "DELETE",
                url: url,
                completion: completion
            )
        }.resume()
    }

    // MARK: - DELETE Request (Codable body, if backend needs it)

    func deleteRequest<T: Codable, U: Codable>(
        endpoint: String,
        body: T,
        completion: @escaping (Result<U, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            print("❌ Invalid URL: \(baseURL)\(endpoint)")
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }

        let encodedBody: Data
        do {
            encodedBody = try jsonEncoder.encode(body)
            if let jsonString = String(data: encodedBody, encoding: .utf8) {
                print("\n📤 [DELETE BODY Codable] \(endpoint)")
                print(jsonString.prefix(1000))
                if jsonString.count > 1000 {
                    print("… (truncated body, total length: \(jsonString.count) chars)")
                }
            }
        } catch {
            print("❌ DELETE JSON Encoding Error:", error.localizedDescription)
            DispatchQueue.main.async {
                completion(.failure(NetworkError.encodingFailed))
            }
            return
        }

        let request = makeRequest(url: url, method: "DELETE", bodyData: encodedBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            self.handleResponse(
                data: data,
                response: response,
                error: error,
                method: "DELETE",
                url: url,
                completion: completion
            )
        }.resume()
    }

    // MARK: - Shared Response Handler

    private func handleResponse<U: Codable>(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        method: String,
        url: URL,
        completion: @escaping (Result<U, Error>) -> Void
    ) {
        if let error = error {
            print("🌐 ❌ Network Error:", error.localizedDescription)
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }

        guard let http = response as? HTTPURLResponse else {
            print("❌ Invalid HTTPURLResponse for \(url)")
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidResponse))
            }
            return
        }

        print("\n🌐 [\(method)] \(url.absoluteString)")
        print("📬 Status Code:", http.statusCode)

        guard let data = data else {
            print("⚠️ No response data received")
            DispatchQueue.main.async {
                completion(.failure(NetworkError.noData))
            }
            return
        }

        if let raw = String(data: data, encoding: .utf8) {
            print("🟢 Raw JSON Response:")
            print(raw.prefix(4000))
            if raw.count > 4000 {
                print("… (truncated response, total length: \(raw.count) chars)")
            }
        } else {
            print("⚠️ [Unreadable JSON]")
        }

        // Non-2xx = server error
        guard (200...299).contains(http.statusCode) else {
            print("❌ Server Error (\(http.statusCode))")
            DispatchQueue.main.async {
                completion(.failure(NetworkError.serverError(code: http.statusCode)))
            }
            return
        }

        // Decode to expected type
        do {
            let decoded = try self.jsonDecoder.decode(U.self, from: data)
            DispatchQueue.main.async {
                completion(.success(decoded))
            }
        } catch {
            print("❌ \(method) Decoding Error:", error)
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Network Error Enum

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case encodingFailed
    case noData
    case serverError(code: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .encodingFailed:
            return "Failed to encode request body."
        case .noData:
            return "No data received from the server."
        case .serverError(let code):
            return "Server returned error code \(code)."
        }
    }
}
