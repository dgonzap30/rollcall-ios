//
// RestaurantPicker.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import SwiftUI

/// A searchable restaurant selection sheet
struct RestaurantPicker: View {
    @Binding var selectedRestaurant: Restaurant?
    @Binding var isPresented: Bool
    @ObservedObject private var viewModel: RestaurantPickerViewModel
    @State private var searchText = ""

    // MARK: - Constants

    enum Constants {
        static let rowHeight: CGFloat = 56
        static let rowPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let searchFieldPadding: CGFloat = 12
    }

    // MARK: - Init

    init(
        selectedRestaurant: Binding<Restaurant?>,
        isPresented: Binding<Bool>,
        viewModel: RestaurantPickerViewModel
    ) {
        _selectedRestaurant = selectedRestaurant
        _isPresented = isPresented
        self.viewModel = viewModel
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                self.searchBar

                Divider()

                self.restaurantList
            }
            .navigationTitle("Select Restaurant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        self.isPresented = false
                    }
                    .foregroundColor(.rcPink500)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if self.selectedRestaurant != nil {
                        Button("Clear") {
                            self.selectedRestaurant = nil
                            self.isPresented = false
                        }
                        .foregroundColor(.rcPink500)
                    }
                }
            }
        }
        .task {
            await self.viewModel.loadRestaurants()
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.rcSeaweed800.opacity(0.5))

            TextField("Search restaurants...", text: self.$searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(Constants.searchFieldPadding)
        .background(Color.rcRice50)
        .cornerRadius(8)
        .padding(.horizontal, Constants.rowPadding)
        .padding(.vertical, 12)
    }

    // MARK: - Restaurant List

    @ViewBuilder
    private var restaurantList: some View {
        let filteredRestaurants = self.viewModel.filteredRestaurants(searchText: self.searchText)

        if self.viewModel.viewState.isLoading {
            self.loadingView
        } else if filteredRestaurants.isEmpty {
            self.emptyView
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredRestaurants) { restaurant in
                        RestaurantRow(
                            restaurant: restaurant,
                            isSelected: self.selectedRestaurant?.id == restaurant.id
                        ) {
                            self.selectRestaurant(restaurant)
                        }

                        if restaurant.id != filteredRestaurants.last?.id {
                            Divider()
                                .padding(.leading, Constants.rowPadding)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .rcPink500))

            Text("Loading restaurants...")
                .font(.caption)
                .foregroundColor(.rcSeaweed800.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 48))
                .foregroundColor(.rcSeaweed800.opacity(0.3))

            Text(self.searchText.isEmpty ? "No restaurants available" : "No restaurants found")
                .font(.headline)
                .foregroundColor(.rcSeaweed800)

            if !self.searchText.isEmpty {
                Text("Try adjusting your search")
                    .font(.caption)
                    .foregroundColor(.rcSeaweed800.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Private Methods

    private func selectRestaurant(_ restaurant: Restaurant) {
        self.selectedRestaurant = restaurant
        self.isPresented = false
    }
}

// MARK: - Restaurant Row

private struct RestaurantRow: View {
    let restaurant: Restaurant
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(self.restaurant.name)
                        .font(.body)
                        .fontWeight(self.isSelected ? .semibold : .regular)
                        .foregroundColor(.rcSeaweed800)

                    Text("\(self.restaurant.address.street), \(self.restaurant.address.city)")
                        .font(.caption)
                        .foregroundColor(.rcSeaweed800.opacity(0.6))
                }

                Spacer()

                if self.isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.rcPink500)
                }
            }
            .padding(.horizontal, RestaurantPicker.Constants.rowPadding)
            .padding(.vertical, 12)
            .background(self.isSelected ? Color.rcPink500.opacity(0.05) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(
            "\(self.restaurant.name), \(self.restaurant.address.street), \(self.restaurant.address.city)"
        )
        .accessibilityAddTraits(self.isSelected ? [.isSelected] : [])
    }
}

// MARK: - Restaurant Picker ViewModel ViewState

struct RestaurantPickerViewState {
    var restaurants: [Restaurant] = []
    var isLoading = false
    var error: AppError?

    static let initial = Self()
}

// MARK: - Restaurant Picker ViewModel

final class RestaurantPickerViewModel: ObservableObject {
    @Published private(set) var viewState = RestaurantPickerViewState.initial

    private let restaurantRepository: RestaurantRepositoryProtocol
    private var loadTask: Task<Void, Never>?

    init(restaurantRepository: RestaurantRepositoryProtocol) {
        self.restaurantRepository = restaurantRepository
    }

    deinit {
        loadTask?.cancel()
    }

    func loadRestaurants() async {
        self.loadTask?.cancel()
        self.loadTask = Task { [weak self] in
            guard let self else { return }

            await MainActor.run {
                self.viewState.isLoading = true
                self.viewState.error = nil
            }

            do {
                let fetchedRestaurants = try await restaurantRepository.fetchAllRestaurants()
                await MainActor.run {
                    self.viewState.restaurants = fetchedRestaurants.sorted { $0.name < $1.name }
                    self.viewState.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.viewState.error = error as? AppError ?? .unknown
                    self.viewState.isLoading = false
                }
            }
        }
    }

    func filteredRestaurants(searchText: String) -> [Restaurant] {
        guard !searchText.isEmpty else { return self.viewState.restaurants }

        let lowercasedSearch = searchText.lowercased()
        return self.viewState.restaurants.filter { restaurant in
            restaurant.name.lowercased().contains(lowercasedSearch) ||
                restaurant.address.street.lowercased().contains(lowercasedSearch) ||
                restaurant.address.city.lowercased().contains(lowercasedSearch)
        }
    }
}

// MARK: - Preview

#if DEBUG
    struct RestaurantPicker_Previews: PreviewProvider {
        struct PreviewWrapper: View {
            @State private var selectedRestaurant: Restaurant?
            @State private var isPresented = true

            var body: some View {
                VStack {
                    if let restaurant = selectedRestaurant {
                        Text("Selected: \(restaurant.name)")
                            .padding()
                    }

                    Button("Show Picker") {
                        self.isPresented = true
                    }
                    .padding()
                    .background(Color.rcPink500)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .sheet(isPresented: self.$isPresented) {
                    RestaurantPicker(
                        selectedRestaurant: self.$selectedRestaurant,
                        isPresented: self.$isPresented,
                        viewModel: RestaurantPickerViewModel(
                            restaurantRepository: InMemoryRestaurantRepository()
                        )
                    )
                }
            }
        }

        static var previews: some View {
            PreviewWrapper()
        }
    }
#endif
