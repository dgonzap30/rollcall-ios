//
// CreateRollConstants.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

#if canImport(SwiftUI)
    import SwiftUI

    @available(iOS 15.0, *)
    enum CreateRollConstants {
        enum Layout {
            static let formSpacing = Spacing.small
            static let sectionSpacing = Spacing.large
            static let horizontalPadding = Spacing.Padding.medium
            static let verticalPadding = Spacing.Padding.large
            static let textEditorMinHeight: CGFloat = 80
            static let starSize: CGFloat = 28
        }

        enum Animation {
            static let formTransition = AnimationTokens.Curve.standard()
            static let errorShake = AnimationTokens.Spring.standard()
            static let ratingTap = AnimationTokens.Spring.bouncy()
        }

        enum Strings {
            static let navigationTitle = "New Roll"
            static let editNavigationTitle = "Edit Roll"
            static let namePlaceholder = "Roll name"
            static let nameLabel = "Name"
            static let typeLabel = "Type"
            static let ratingLabel = "Rating"
            static let restaurantLabel = "Restaurant"
            static let descriptionLabel = "Description"
            static let descriptionPlaceholder = "Description (optional)"
            static let tagsLabel = "Tags"
            static let tagsPlaceholder = "Tags (comma separated)"
            static let saveButton = "Save Roll"
            static let cancelButton = "Cancel"
            static let selectRestaurant = "Select Restaurant"
            static let addRestaurant = "Add New Restaurant"
            static let saving = "Saving..."
            static let loadingRestaurants = "Loading restaurants..."
        }

        enum Validation {
            static let minNameLength = 2
            static let maxNameLength = 50
            static let maxDescriptionLength = 500
            static let maxTagCount = 10
            static let maxTagLength = 20
        }

        enum Accessibility {
            static let ratingHint = "Tap to rate %d stars"
            static let ratingValue = "%d out of 5 stars"
            static let typeHint = "Tap to select %@ type"
            static let deleteHint = "Double tap to delete this roll"
            static let saveHint = "Double tap to save roll"
            static let cancelHint = "Double tap to cancel without saving"
        }
    }
#endif
