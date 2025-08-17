//
// CreateRollView.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import SwiftUI

/// Main form view for creating or editing a roll
@available(iOS 15.0, *)
struct CreateRollView: View {
    @ObservedObject var viewModel: CreateRollViewModel
    @State private var showRestaurantPicker = false
    @FocusState private var focusedField: Field?

    // MARK: - Constants

    private enum Constants {
        static let sectionSpacing: CGFloat = 24
        static let fieldSpacing: CGFloat = 16
        static let horizontalPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let maxDescriptionHeight: CGFloat = 120
    }

    private enum Field: Hashable {
        case name
        case description
        case tags
    }

    // MARK: - Dependencies

    let hapticService: HapticFeedbackServicing
    let restaurantRepository: RestaurantRepositoryProtocol

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: Constants.sectionSpacing) {
                self.nameSection
                self.typeSection
                self.ratingSection
                self.restaurantSection
                self.descriptionSection
                self.tagsSection

                if let error = viewModel.viewState.errorMessage {
                    self.errorView(message: error)
                }
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.vertical, Constants.sectionSpacing)
        }
        .navigationTitle(self.viewModel.viewState.isEditing ? "Edit Roll" : "New Roll")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    self.viewModel.cancel()
                }
                .foregroundColor(.rcPink500)
                .disabled(self.viewModel.viewState.isSaving)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    self.focusedField = nil
                    self.viewModel.saveRoll()
                }
                .foregroundColor(.rcPink500)
                .font(.body.weight(.semibold))
                .disabled(!self.viewModel.viewState.isValid || self.viewModel.viewState.isSaving)
                .overlay {
                    if self.viewModel.viewState.isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .rcPink500))
                            .scaleEffect(0.8)
                    }
                }
            }
        }
        .sheet(isPresented: self.$showRestaurantPicker) {
            RestaurantPicker(
                selectedRestaurant: Binding(
                    get: { self.viewModel.viewState.selectedRestaurant },
                    set: { self.viewModel.updateRestaurant($0) }
                ),
                isPresented: self.$showRestaurantPicker,
                viewModel: RestaurantPickerViewModel(
                    restaurantRepository: self.restaurantRepository
                )
            )
        }
        .interactiveDismissDisabled(self.viewModel.viewState.isSaving)
    }

    // MARK: - Name Section

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Roll Name", systemImage: "pencil")
                .font(.headline)
                .foregroundColor(.rcSeaweed800)

            TextField("Enter roll name...", text: Binding(
                get: { self.viewModel.viewState.name },
                set: { self.viewModel.updateName($0) }
            ))
            .textFieldStyle(CustomTextFieldStyle())
            .focused(self.$focusedField, equals: .name)
            .submitLabel(.next)
            .onSubmit {
                self.focusedField = .description
            }

            if !self.viewModel.viewState.name.isEmpty {
                Text("\(self.viewModel.viewState.name.count)/\(CreateRollConstants.Validation.maxNameLength)")
                    .font(.caption)
                    .foregroundColor(
                        self.viewModel.viewState.name.count > CreateRollConstants.Validation.maxNameLength ?
                            .red : .rcSeaweed800.opacity(0.6)
                    )
            }
        }
    }

    // MARK: - Type Section

    private var typeSection: some View {
        RollTypePicker(
            selectedType: Binding(
                get: { self.viewModel.viewState.selectedType },
                set: { self.viewModel.updateType($0) }
            ),
            hapticService: self.hapticService
        )
    }

    // MARK: - Rating Section

    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Rating", systemImage: "star")
                .font(.headline)
                .foregroundColor(.rcSeaweed800)

            RatingPicker(
                rating: Binding(
                    get: { self.viewModel.viewState.rating },
                    set: { self.viewModel.updateRating($0) }
                ),
                hapticService: self.hapticService
            )
        }
    }

    // MARK: - Restaurant Section

    private var restaurantSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Restaurant", systemImage: "fork.knife")
                .font(.headline)
                .foregroundColor(.rcSeaweed800)

            Button(action: { self.showRestaurantPicker = true }, label: {
                HStack {
                    if let restaurant = viewModel.viewState.selectedRestaurant {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(restaurant.name)
                                .font(.body)
                                .foregroundColor(.rcSeaweed800)

                            Text("\(restaurant.address.street), \(restaurant.address.city)")
                                .font(.caption)
                                .foregroundColor(.rcSeaweed800.opacity(0.6))
                        }
                    } else {
                        Text("Select restaurant...")
                            .foregroundColor(.rcSeaweed800.opacity(0.5))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.rcSeaweed800.opacity(0.5))
                }
                .padding(12)
                .background(Color.rcRice50)
                .cornerRadius(Constants.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .strokeBorder(Color.rcNori800.opacity(0.08))
                )
            })
            .disabled(self.viewModel.viewState.isSaving)
        }
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Description (Optional)", systemImage: "text.alignleft")
                .font(.headline)
                .foregroundColor(.rcSeaweed800)

            TextEditor(text: Binding(
                get: { self.viewModel.viewState.description },
                set: { self.viewModel.updateDescription($0) }
            ))
            .focused(self.$focusedField, equals: .description)
            .frame(minHeight: Constants.maxDescriptionHeight)
            .padding(8)
            .background(Color.rcRice50)
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .strokeBorder(Color.rcNori800.opacity(0.08))
            )

            Text("\(self.viewModel.viewState.description.count)/\(CreateRollConstants.Validation.maxDescriptionLength)")
                .font(.caption)
                .foregroundColor(
                    self.viewModel.viewState.description.count > CreateRollConstants.Validation.maxDescriptionLength ?
                        .red : .rcSeaweed800.opacity(0.6)
                )
        }
    }

    // MARK: - Tags Section

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Tags (Optional)", systemImage: "tag")
                .font(.headline)
                .foregroundColor(.rcSeaweed800)

            TextField("Add tags separated by commas...", text: Binding(
                get: { self.viewModel.viewState.tags.joined(separator: ", ") },
                set: { self.viewModel.updateTags($0) }
            ))
            .textFieldStyle(CustomTextFieldStyle())
            .focused(self.$focusedField, equals: .tags)
            .submitLabel(.done)
            .onSubmit {
                self.focusedField = nil
            }

            if !self.viewModel.viewState.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(self.viewModel.viewState.tags, id: \.self) { tag in
                            TagChip(text: tag)
                        }
                    }
                }
            }

            Text(
                "Max \(CreateRollConstants.Validation.maxTagCount) tags, " +
                    "\(CreateRollConstants.Validation.maxTagLength) characters each"
            )
            .font(.caption)
            .foregroundColor(.rcSeaweed800.opacity(0.6))
        }
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)

            Text(message)
                .font(.caption)
                .foregroundColor(.red)

            Spacer()
        }
        .padding(12)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Custom Text Field Style

private struct CustomTextFieldStyle: TextFieldStyle {
    // swiftlint:disable:next identifier_name
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color.rcRice50)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.rcNori800.opacity(0.08))
            )
    }
}

// MARK: - Tag Chip

private struct TagChip: View {
    let text: String

    var body: some View {
        Text(self.text)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.rcPink500.opacity(0.1))
            .foregroundColor(.rcPink500)
            .cornerRadius(16)
    }
}

// MARK: - Preview

#if DEBUG
    @available(iOS 15.0, *)
    struct CreateRollView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                CreateRollView(
                    viewModel: CreateRollViewModel(
                        rollRepository: InMemoryRollRepository(),
                        chefRepository: InMemoryChefRepository(),
                        restaurantRepository: InMemoryRestaurantRepository(),
                        hapticService: HapticFeedbackService()
                    ),
                    hapticService: HapticFeedbackService(),
                    restaurantRepository: InMemoryRestaurantRepository()
                )
            }
        }
    }
#endif
