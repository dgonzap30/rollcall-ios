//
// RollDTO.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation

// MARK: - Roll DTOs

@available(iOS 15.0, *)
public struct RollDTO: Codable {
    public let id: String
    public let chefId: String
    public let restaurantId: String
    public let type: String
    public let name: String
    public let description: String?
    public let rating: Int
    public let photoUrl: String?
    public let tags: [String]
    public let createdAt: String
    public let updatedAt: String

    public init(
        id: String,
        chefId: String,
        restaurantId: String,
        type: String,
        name: String,
        description: String?,
        rating: Int,
        photoUrl: String?,
        tags: [String],
        createdAt: String,
        updatedAt: String
    ) {
        self.id = id
        self.chefId = chefId
        self.restaurantId = restaurantId
        self.type = type
        self.name = name
        self.description = description
        self.rating = rating
        self.photoUrl = photoUrl
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@available(iOS 15.0, *)
public struct CreateRollDTO: Codable {
    public let chefId: String
    public let restaurantId: String
    public let type: String
    public let name: String
    public let description: String?
    public let rating: Int
    public let photoUrl: String?
    public let tags: [String]

    public init(
        chefId: String,
        restaurantId: String,
        type: String,
        name: String,
        description: String?,
        rating: Int,
        photoUrl: String?,
        tags: [String]
    ) {
        self.chefId = chefId
        self.restaurantId = restaurantId
        self.type = type
        self.name = name
        self.description = description
        self.rating = rating
        self.photoUrl = photoUrl
        self.tags = tags
    }
}

@available(iOS 15.0, *)
public struct RollsResponseDTO: Codable {
    public let rolls: [RollDTO]
    public let pagination: PaginationDTO

    public init(rolls: [RollDTO], pagination: PaginationDTO) {
        self.rolls = rolls
        self.pagination = pagination
    }
}
