//
// RestaurantEntity+CoreData.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import CoreData
import Foundation

@available(iOS 15.0, *)
@objc(RestaurantEntity)
public class RestaurantEntity: NSManagedObject {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<RestaurantEntity> {
        NSFetchRequest<RestaurantEntity>(entityName: "RestaurantEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var cuisineType: String
    @NSManaged public var priceRange: Int16
    @NSManaged public var rating: Double
    @NSManaged public var isOmakaseOffered: Bool
    @NSManaged public var phone: String?
    @NSManaged public var website: String?
    @NSManaged public var photoURLs: [String]?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var street: String?
    @NSManaged public var city: String?
    @NSManaged public var state: String?
    @NSManaged public var postalCode: String?
    @NSManaged public var country: String?
    @NSManaged public var addressFormatted: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var rolls: Set<RollEntity>?
}

// MARK: - Domain Model Conversion

@available(iOS 15.0, *)
extension RestaurantEntity {
    static func from(_ restaurant: Restaurant, context: NSManagedObjectContext) -> RestaurantEntity {
        let entity = RestaurantEntity(context: context)
        entity.id = restaurant.id.value
        entity.name = restaurant.name
        entity.cuisineType = restaurant.cuisine.rawValue
        entity.priceRange = Int16(restaurant.priceRange.rawValue)
        entity.setValidatedRating(restaurant.rating)
        entity.isOmakaseOffered = restaurant.isOmakaseOffered
        entity.phone = restaurant.phoneNumber
        entity.website = restaurant.website?.absoluteString
        entity.photoURLs = restaurant.photoURLs.map(\.absoluteString)
        entity.createdAt = restaurant.createdAt
        entity.updatedAt = restaurant.updatedAt

        // Store address components
        entity.street = restaurant.address.street
        entity.city = restaurant.address.city
        entity.state = restaurant.address.state
        entity.postalCode = restaurant.address.postalCode
        entity.country = restaurant.address.country
        entity.addressFormatted = restaurant.address.formatted

        // Store coordinates
        entity.latitude = restaurant.coordinates.latitude
        entity.longitude = restaurant.coordinates.longitude

        return entity
    }

    func toDomainModel() throws -> Restaurant {
        guard let cuisineTypeEnum = CuisineType(rawValue: cuisineType),
              let priceRangeEnum = PriceRange(rawValue: Int(priceRange)) else {
            throw AppError.database("Invalid enum values in restaurant entity")
        }

        let address: Address? = if let street {
            Address(
                street: street,
                city: self.city ?? "",
                state: self.state ?? "",
                postalCode: self.postalCode ?? "",
                country: self.country ?? ""
            )
        } else {
            nil
        }

        let coordinates = Coordinates(latitude: latitude, longitude: longitude)

        return Restaurant(
            id: RestaurantID(value: self.id),
            name: self.name,
            address: address ?? Address(street: "", city: "", state: "", postalCode: "", country: ""),
            cuisine: cuisineTypeEnum,
            priceRange: priceRangeEnum,
            phoneNumber: self.phone,
            website: self.website.flatMap { URL(string: $0) },
            coordinates: coordinates,
            rating: self.rating,
            photoURLs: self.photoURLs?.compactMap { URL(string: $0) } ?? [],
            isOmakaseOffered: self.isOmakaseOffered,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }

    func update(from restaurant: Restaurant) {
        self.name = restaurant.name
        self.cuisineType = restaurant.cuisine.rawValue
        self.priceRange = Int16(restaurant.priceRange.rawValue)
        self.setValidatedRating(restaurant.rating)
        self.isOmakaseOffered = restaurant.isOmakaseOffered
        self.phone = restaurant.phoneNumber
        self.website = restaurant.website?.absoluteString
        self.photoURLs = restaurant.photoURLs.map(\.absoluteString)
        self.updatedAt = restaurant.updatedAt

        // Update address
        self.street = restaurant.address.street
        self.city = restaurant.address.city
        self.state = restaurant.address.state
        self.postalCode = restaurant.address.postalCode
        self.country = restaurant.address.country
        self.addressFormatted = restaurant.address.formatted

        // Update coordinates
        self.latitude = restaurant.coordinates.latitude
        self.longitude = restaurant.coordinates.longitude
    }

    /// Sets the rating with validation to ensure it's within the valid 1-5 range
    private func setValidatedRating(_ value: Double) {
        let clampedRating = max(1.0, min(5.0, value))
        if clampedRating != value {
            print("Warning: Restaurant rating \(value) was clamped to \(clampedRating)")
        }
        self.rating = clampedRating
    }
}
