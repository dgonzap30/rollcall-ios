//
// RollMapper.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation

// MARK: - Roll Mapper

@available(iOS 15.0, *)
public enum RollMapper {
    // MARK: - DTO to Domain

    public static func toDomain(from dto: RollDTO) throws -> Roll {
        guard let rollUUID = UUID(uuidString: dto.id) else {
            throw MappingError.invalidID("Invalid roll ID: \(dto.id)")
        }
        let rollID = RollID(value: rollUUID)

        guard let chefUUID = UUID(uuidString: dto.chefId) else {
            throw MappingError.invalidID("Invalid chef ID: \(dto.chefId)")
        }
        let chefID = ChefID(value: chefUUID)

        guard let restaurantUUID = UUID(uuidString: dto.restaurantId) else {
            throw MappingError.invalidID("Invalid restaurant ID: \(dto.restaurantId)")
        }
        let restaurantID = RestaurantID(value: restaurantUUID)

        guard let rollType = RollType(rawValue: dto.type) else {
            throw MappingError.invalidEnum("Invalid roll type: \(dto.type)")
        }

        guard let rating = Rating(value: dto.rating) else {
            throw MappingError.invalidValue("Invalid rating: \(dto.rating)")
        }

        let photoURL = dto.photoUrl.flatMap { URL(string: $0) }

        let dateFormatter = ISO8601DateFormatter()
        guard let createdAt = dateFormatter.date(from: dto.createdAt) else {
            throw MappingError.invalidDate("Invalid created date: \(dto.createdAt)")
        }

        guard let updatedAt = dateFormatter.date(from: dto.updatedAt) else {
            throw MappingError.invalidDate("Invalid updated date: \(dto.updatedAt)")
        }

        return Roll(
            id: rollID,
            chefID: chefID,
            restaurantID: restaurantID,
            type: rollType,
            name: dto.name,
            description: dto.description,
            rating: rating,
            photoURL: photoURL,
            tags: dto.tags,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    // MARK: - Domain to DTO

    public static func toDTO(from domain: Roll) -> RollDTO {
        let dateFormatter = ISO8601DateFormatter()

        return RollDTO(
            id: domain.id.value.uuidString,
            chefId: domain.chefID.value.uuidString,
            restaurantId: domain.restaurantID.value.uuidString,
            type: domain.type.rawValue,
            name: domain.name,
            description: domain.description,
            rating: domain.rating.value,
            photoUrl: domain.photoURL?.absoluteString,
            tags: domain.tags,
            createdAt: dateFormatter.string(from: domain.createdAt),
            updatedAt: dateFormatter.string(from: domain.updatedAt)
        )
    }

    public static func toCreateDTO(from domain: Roll) -> CreateRollDTO {
        CreateRollDTO(
            chefId: domain.chefID.value.uuidString,
            restaurantId: domain.restaurantID.value.uuidString,
            type: domain.type.rawValue,
            name: domain.name,
            description: domain.description,
            rating: domain.rating.value,
            photoUrl: domain.photoURL?.absoluteString,
            tags: domain.tags
        )
    }

    // MARK: - Collection Mapping

    public static func toDomain(from response: RollsResponseDTO) throws -> [Roll] {
        try response.rolls.map { try self.toDomain(from: $0) }
    }
}

// MARK: - Mapping Errors

@available(iOS 15.0, *)
public enum MappingError: Error, LocalizedError {
    case invalidID(String)
    case invalidEnum(String)
    case invalidValue(String)
    case invalidDate(String)

    public var errorDescription: String? {
        switch self {
        case let .invalidID(message),
             let .invalidEnum(message),
             let .invalidValue(message),
             let .invalidDate(message):
            message
        }
    }
}
