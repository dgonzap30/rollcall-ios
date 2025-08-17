//
// HTTPAPIClient.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation

// MARK: - HTTP API Client

@available(iOS 15.0, *)
public actor HTTPAPIClient: APIClientProtocol {
    // MARK: - Properties

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    // MARK: - Initialization

    public init(
        baseURL: URL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.encoder = encoder

        // Configure decoder for API response format
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        // Configure encoder for API request format
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    // MARK: - APIClientProtocol Implementation

    public func request<T: Codable>(_ request: APIRequest) async throws -> APIResponse<T> {
        let urlRequest = try buildURLRequest(from: request)

        do {
            let (data, response) = try await session.data(for: urlRequest)
            return try self.handleResponse(data: data, response: response)
        } catch let error as URLError {
            throw NetworkError.networkError(error)
        } catch {
            throw NetworkError.unknownError(error)
        }
    }

    public func upload<T: Codable>(_ request: APIUploadRequest) async throws -> APIResponse<T> {
        let urlRequest = try buildUploadRequest(from: request)

        do {
            let (data, response) = try await session.upload(for: urlRequest, from: request.data)
            return try self.handleResponse(data: data, response: response)
        } catch let error as URLError {
            throw NetworkError.networkError(error)
        } catch {
            throw NetworkError.unknownError(error)
        }
    }

    // MARK: - Private Methods

    private func buildURLRequest(from apiRequest: APIRequest) throws -> URLRequest {
        let url = self.baseURL.appendingPathComponent(apiRequest.endpoint.path)

        var request = URLRequest(url: url)
        request.httpMethod = apiRequest.method.rawValue
        request.timeoutInterval = apiRequest.timeout

        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Add custom headers
        for (key, value) in apiRequest.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Add body if present
        request.httpBody = apiRequest.body

        return request
    }

    private func buildUploadRequest(from apiRequest: APIUploadRequest) throws -> URLRequest {
        let url = self.baseURL.appendingPathComponent(apiRequest.endpoint.path)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.timeoutInterval = apiRequest.timeout

        // Set upload headers
        request.setValue(apiRequest.mimeType, forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Add custom headers
        for (key, value) in apiRequest.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    private func handleResponse<T: Codable>(
        data: Data,
        response: URLResponse
    ) throws -> APIResponse<T> {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError(NSError(domain: "Invalid response type", code: 0))
        }

        // Extract headers
        var headers: [String: String] = [:]
        for (key, value) in httpResponse.allHeaderFields {
            if let key = key as? String, let value = value as? String {
                headers[key] = value
            }
        }

        // Check for HTTP errors
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        // Decode response data
        do {
            let decodedData = try decoder.decode(T.self, from: data)
            return APIResponse(
                data: decodedData,
                statusCode: httpResponse.statusCode,
                headers: headers
            )
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

// MARK: - Factory Methods

@available(iOS 15.0, *)
extension HTTPAPIClient {
    public static func production() -> HTTPAPIClient {
        // MARK: MVP Configuration - Update URL when backend API is deployed

        let baseURL = URL(string: "https://api.rollcall.app")!
        return HTTPAPIClient(baseURL: baseURL)
    }

    public static func staging() -> HTTPAPIClient {
        // MARK: MVP Configuration - Update URL when staging environment is configured

        let baseURL = URL(string: "https://staging-api.rollcall.app")!
        return HTTPAPIClient(baseURL: baseURL)
    }

    public static func development() -> HTTPAPIClient {
        let baseURL = URL(string: "http://localhost:3000")!
        return HTTPAPIClient(baseURL: baseURL)
    }
}
