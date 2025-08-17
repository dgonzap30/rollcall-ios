//
// MockAPIClient.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation

// MARK: - Mock API Client

@available(iOS 15.0, *)
public actor MockAPIClient: APIClientProtocol {
    // MARK: - Properties

    private var responses: [String: Any] = [:]
    private var errors: [String: Error] = [:]
    private var delay: TimeInterval = 0.5

    // MARK: - Initialization

    public init() {
        Task {
            await self.setupDefaultResponses()
        }
    }

    // MARK: - Configuration

    public func setResponse(_ response: some Codable, for endpoint: APIEndpoint) {
        self.responses[endpoint.path] = response
    }

    public func setError(_ error: Error, for endpoint: APIEndpoint) {
        self.errors[endpoint.path] = error
    }

    public func setDelay(_ delay: TimeInterval) {
        self.delay = delay
    }

    // MARK: - APIClientProtocol Implementation

    public func request<T: Codable>(_ request: APIRequest) async throws -> APIResponse<T> {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(self.delay * 1_000_000_000))

        let path = request.endpoint.path

        // Check for configured error
        if let error = errors[path] {
            throw error
        }

        // Check for configured response
        guard let mockResponse = responses[path] else {
            throw NetworkError.noData
        }

        // Attempt to cast to expected type
        guard let typedResponse = mockResponse as? T else {
            // If direct cast fails, try JSON encoding/decoding for type conversion
            // Create a mock response for the expected type
            throw NetworkError.noData
        }

        return APIResponse(
            data: typedResponse,
            statusCode: 200,
            headers: ["Content-Type": "application/json"]
        )
    }

    public func upload<T: Codable>(_ request: APIUploadRequest) async throws -> APIResponse<T> {
        // Simulate upload delay (longer than regular requests)
        try await Task.sleep(nanoseconds: UInt64((self.delay * 2) * 1_000_000_000))

        let path = request.endpoint.path

        // Check for configured error
        if let error = errors[path] {
            throw error
        }

        // Mock upload success response
        let uploadResponse = UploadResponse(
            id: UUID().uuidString,
            url: "https://mock-cdn.rollcall.app/uploads/\(UUID().uuidString)",
            mimeType: request.mimeType,
            size: request.data.count
        )

        guard let typedResponse = uploadResponse as? T else {
            // Mock upload success response
            guard let typedResponse = uploadResponse as? T else {
                throw NetworkError.decodingError(NSError(domain: "Type mismatch", code: 0))
            }

            return APIResponse(
                data: typedResponse,
                statusCode: 201,
                headers: ["Content-Type": "application/json"]
            )
        }

        return APIResponse(
            data: typedResponse,
            statusCode: 201,
            headers: ["Content-Type": "application/json"]
        )
    }

    // MARK: - Private Methods

    private func setupDefaultResponses() {
        // Default responses for common endpoints
        self.responses["/api/v1/rolls"] = []
        self.responses["/api/v1/chefs"] = []
        self.responses["/api/v1/restaurants"] = []
    }
}

// MARK: - Mock Response Models

@available(iOS 15.0, *)
public struct UploadResponse: Codable {
    public let id: String
    public let url: String
    public let mimeType: String
    public let size: Int

    public init(id: String, url: String, mimeType: String, size: Int) {
        self.id = id
        self.url = url
        self.mimeType = mimeType
        self.size = size
    }
}
