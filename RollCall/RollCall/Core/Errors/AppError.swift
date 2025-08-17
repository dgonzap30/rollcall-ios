//
// AppError.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

@available(iOS 15.0, *)
public enum AppError: LocalizedError, Sendable {
    case network(URLError)
    case networkError
    case api(message: String, code: Int)
    case validation(field: String, message: String)
    case validationError(String)
    case authenticationError
    case unauthorized
    case notFound(String)
    case dataNotFound
    case database(String)
    case serverError
    case unknown

    public var errorDescription: String? {
        switch self {
        case let .network(error):
            "Network error: \(error.localizedDescription)"
        case .networkError:
            "Network error occurred"
        case let .api(message, _):
            message
        case let .validation(field, message):
            "\(field): \(message)"
        case let .validationError(message):
            message
        case .authenticationError:
            "Authentication required"
        case .unauthorized:
            "Please log in to continue"
        case let .notFound(message):
            "Not found: \(message)"
        case .dataNotFound:
            "Data not found"
        case let .database(message):
            "Database error: \(message)"
        case .serverError:
            "Server error occurred"
        case .unknown:
            "Something went wrong"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .network, .networkError:
            "Please check your internet connection and try again"
        case .api, .serverError:
            "Please try again later"
        case .validation, .validationError:
            "Please correct the error and try again"
        case .authenticationError, .unauthorized:
            "Sign in to access this feature"
        case .notFound, .dataNotFound:
            "The requested item could not be found"
        case .database:
            "Please try again or contact support if the problem persists"
        case .unknown:
            "Please try again"
        }
    }
}
