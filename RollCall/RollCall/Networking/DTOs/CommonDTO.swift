//
// CommonDTO.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation

// MARK: - Pagination DTO

@available(iOS 15.0, *)
public struct PaginationDTO: Codable {
    public let page: Int
    public let perPage: Int
    public let total: Int
    public let totalPages: Int
    public let hasNext: Bool
    public let hasPrevious: Bool

    public init(
        page: Int,
        perPage: Int,
        total: Int,
        totalPages: Int,
        hasNext: Bool,
        hasPrevious: Bool
    ) {
        self.page = page
        self.perPage = perPage
        self.total = total
        self.totalPages = totalPages
        self.hasNext = hasNext
        self.hasPrevious = hasPrevious
    }
}

// MARK: - Error Response DTO

@available(iOS 15.0, *)
public struct ErrorResponseDTO: Codable {
    public let error: String
    public let message: String
    public let code: Int?
    public let details: [String]?

    public init(
        error: String,
        message: String,
        code: Int? = nil,
        details: [String]? = nil
    ) {
        self.error = error
        self.message = message
        self.code = code
        self.details = details
    }
}

// MARK: - Success Response DTO

@available(iOS 15.0, *)
public struct SuccessResponseDTO: Codable {
    public let success: Bool
    public let message: String

    public init(success: Bool, message: String) {
        self.success = success
        self.message = message
    }
}

// MARK: - Address DTO

@available(iOS 15.0, *)
public struct AddressDTO: Codable {
    public let street: String
    public let city: String
    public let state: String
    public let postalCode: String
    public let country: String

    public init(
        street: String,
        city: String,
        state: String,
        postalCode: String,
        country: String
    ) {
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
    }
}

// MARK: - Coordinates DTO

@available(iOS 15.0, *)
public struct CoordinatesDTO: Codable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
