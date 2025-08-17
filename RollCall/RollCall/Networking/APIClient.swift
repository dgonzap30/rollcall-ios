//
// APIClient.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation

// MARK: - API Client Protocol

@available(iOS 15.0, *)
public protocol APIClientProtocol: Actor {
    func request<T: Codable>(_ request: APIRequest) async throws -> APIResponse<T>
    func upload<T: Codable>(_ request: APIUploadRequest) async throws -> APIResponse<T>
}

// MARK: - API Request Models

@available(iOS 15.0, *)
public struct APIRequest {
    public let endpoint: APIEndpoint
    public let method: HTTPMethod
    public let headers: [String: String]
    public let body: Data?
    public let timeout: TimeInterval

    public init(
        endpoint: APIEndpoint,
        method: HTTPMethod = .GET,
        headers: [String: String] = [:],
        body: Data? = nil,
        timeout: TimeInterval = 30.0
    ) {
        self.endpoint = endpoint
        self.method = method
        self.headers = headers
        self.body = body
        self.timeout = timeout
    }
}

@available(iOS 15.0, *)
public struct APIUploadRequest {
    public let endpoint: APIEndpoint
    public let data: Data
    public let mimeType: String
    public let headers: [String: String]
    public let timeout: TimeInterval

    public init(
        endpoint: APIEndpoint,
        data: Data,
        mimeType: String,
        headers: [String: String] = [:],
        timeout: TimeInterval = 60.0
    ) {
        self.endpoint = endpoint
        self.data = data
        self.mimeType = mimeType
        self.headers = headers
        self.timeout = timeout
    }
}

// MARK: - API Response Models

@available(iOS 15.0, *)
public struct APIResponse<T: Codable> {
    public let data: T
    public let statusCode: Int
    public let headers: [String: String]

    public init(data: T, statusCode: Int, headers: [String: String]) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
    }
}

// MARK: - HTTP Method

@available(iOS 15.0, *)
public enum HTTPMethod: String, CaseIterable {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
}

// MARK: - API Endpoints

@available(iOS 15.0, *)
public enum APIEndpoint {
    case rolls
    case roll(id: String)
    case chefs
    case chef(id: String)
    case restaurants
    case restaurant(id: String)
    case search(query: String)
    case upload(type: UploadType)

    public enum UploadType {
        case rollPhoto
        case chefAvatar
        case restaurantPhoto
    }

    public var path: String {
        switch self {
        case .rolls:
            "/api/v1/rolls"
        case let .roll(id):
            "/api/v1/rolls/\(id)"
        case .chefs:
            "/api/v1/chefs"
        case let .chef(id):
            "/api/v1/chefs/\(id)"
        case .restaurants:
            "/api/v1/restaurants"
        case let .restaurant(id):
            "/api/v1/restaurants/\(id)"
        case let .search(query):
            "/api/v1/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        case let .upload(type):
            "/api/v1/upload/\(type.rawValue)"
        }
    }
}

@available(iOS 15.0, *)
extension APIEndpoint.UploadType {
    var rawValue: String {
        switch self {
        case .rollPhoto:
            "roll-photo"
        case .chefAvatar:
            "chef-avatar"
        case .restaurantPhoto:
            "restaurant-photo"
        }
    }
}

// MARK: - Network Errors

@available(iOS 15.0, *)
public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(URLError)
    case httpError(statusCode: Int, data: Data?)
    case timeoutError
    case unknownError(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid URL"
        case .noData:
            "No data received"
        case let .decodingError(error):
            "Failed to decode response: \(error.localizedDescription)"
        case let .networkError(urlError):
            "Network error: \(urlError.localizedDescription)"
        case let .httpError(statusCode, _):
            "HTTP error with status code: \(statusCode)"
        case .timeoutError:
            "Request timed out"
        case let .unknownError(error):
            "Unknown error: \(error.localizedDescription)"
        }
    }
}
