//
// RollEntity+CoreData.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import CoreData
import Foundation

@available(iOS 15.0, *)
@objc(RollEntity)
public class RollEntity: NSManagedObject {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<RollEntity> {
        NSFetchRequest<RollEntity>(entityName: "RollEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var desc: String?
    @NSManaged public var type: String
    @NSManaged public var rating: Int16
    @NSManaged public var photoURL: String?
    @NSManaged public var tags: [String]?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var chef: ChefEntity?
    @NSManaged public var restaurant: RestaurantEntity?
}

// MARK: - Domain Model Conversion

@available(iOS 15.0, *)
extension RollEntity {
    static func from(_ roll: Roll, context: NSManagedObjectContext) -> RollEntity {
        let entity = RollEntity(context: context)
        entity.id = roll.id.value
        entity.name = roll.name
        entity.desc = roll.description
        entity.type = roll.type.rawValue
        entity.rating = Int16(roll.rating.value)
        entity.photoURL = roll.photoURL?.absoluteString
        entity.tags = roll.tags
        entity.createdAt = roll.createdAt
        entity.updatedAt = roll.updatedAt
        return entity
    }

    func toDomainModel() throws -> Roll {
        guard let chef,
              let restaurant else {
            throw AppError.database("Roll entity missing required relationships")
        }

        guard let rollType = RollType(rawValue: type) else {
            throw AppError.database("Invalid roll type: \(self.type)")
        }

        return Roll(
            id: RollID(value: self.id),
            chefID: ChefID(value: chef.id),
            restaurantID: RestaurantID(value: restaurant.id),
            type: rollType,
            name: self.name,
            description: self.desc,
            rating: Rating(value: Int(self.rating)) ?? .default,
            photoURL: self.photoURL.flatMap { URL(string: $0) },
            tags: self.tags ?? [],
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }

    func update(from roll: Roll) {
        self.name = roll.name
        self.desc = roll.description
        self.type = roll.type.rawValue
        self.rating = Int16(roll.rating.value)
        self.photoURL = roll.photoURL?.absoluteString
        self.tags = roll.tags
        self.updatedAt = roll.updatedAt
    }
}
