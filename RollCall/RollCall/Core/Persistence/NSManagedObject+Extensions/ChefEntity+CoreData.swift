//
// ChefEntity+CoreData.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import CoreData
import Foundation

@available(iOS 15.0, *)
@objc(ChefEntity)
public class ChefEntity: NSManagedObject {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<ChefEntity> {
        NSFetchRequest<ChefEntity>(entityName: "ChefEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var username: String
    @NSManaged public var displayName: String
    @NSManaged public var email: String
    @NSManaged public var bio: String?
    @NSManaged public var avatarURL: String?
    @NSManaged public var favoriteRollType: String?
    @NSManaged public var rollCount: Int32
    @NSManaged public var joinedAt: Date
    @NSManaged public var lastActiveAt: Date
    @NSManaged public var rolls: Set<RollEntity>?
}

// MARK: - Domain Model Conversion

@available(iOS 15.0, *)
extension ChefEntity {
    static func from(_ chef: Chef, context: NSManagedObjectContext) -> ChefEntity {
        let entity = ChefEntity(context: context)
        entity.id = chef.id.value
        entity.username = chef.username
        entity.displayName = chef.displayName
        entity.email = chef.email
        entity.bio = chef.bio
        entity.avatarURL = chef.avatarURL?.absoluteString
        entity.favoriteRollType = chef.favoriteRollType?.rawValue
        entity.rollCount = Int32(chef.rollCount)
        entity.joinedAt = chef.joinedAt
        entity.lastActiveAt = chef.lastActiveAt
        return entity
    }

    func toDomainModel() -> Chef {
        Chef(
            id: ChefID(value: self.id),
            username: self.username,
            displayName: self.displayName,
            email: self.email,
            bio: self.bio,
            avatarURL: self.avatarURL.flatMap { URL(string: $0) },
            favoriteRollType: self.favoriteRollType.flatMap { RollType(rawValue: $0) },
            rollCount: Int(self.rollCount),
            joinedAt: self.joinedAt,
            lastActiveAt: self.lastActiveAt
        )
    }

    func update(from chef: Chef) {
        self.username = chef.username
        self.displayName = chef.displayName
        self.email = chef.email
        self.bio = chef.bio
        self.avatarURL = chef.avatarURL?.absoluteString
        self.favoriteRollType = chef.favoriteRollType?.rawValue
        self.rollCount = Int32(chef.rollCount)
        self.lastActiveAt = chef.lastActiveAt
    }
}
