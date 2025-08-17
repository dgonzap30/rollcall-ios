//
// RatingPicker.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import SwiftUI

/// A 5-star rating picker component with haptic feedback and accessibility support
struct RatingPicker: View {
    @Binding var rating: Int
    let hapticService: HapticFeedbackServicing?

    // MARK: - Constants

    enum Constants {
        static let starSize: CGFloat = 44 // WCAG 2.2 AA minimum touch target
        static let starSpacing: CGFloat = 8
        static let animationDuration: Double = 0.2
        static let springResponse: Double = 0.4
        static let springDamping: Double = 0.8
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: Constants.starSpacing) {
            ForEach(1...5, id: \.self) { value in
                StarButton(
                    value: value,
                    currentRating: self.rating
                ) { self.selectRating(value) }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rating")
        .accessibilityValue("\(self.rating) out of 5 stars")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                if self.rating < 5 {
                    self.selectRating(self.rating + 1)
                }
            case .decrement:
                if self.rating > 1 {
                    self.selectRating(self.rating - 1)
                }
            @unknown default:
                break
            }
        }
    }

    // MARK: - Private Methods

    private func selectRating(_ value: Int) {
        withAnimation(.spring(response: Constants.springResponse, dampingFraction: Constants.springDamping)) {
            self.rating = value
        }

        Task {
            await self.hapticService?.impact(style: .light)
        }
    }
}

// MARK: - Star Button Component

private struct StarButton: View {
    let value: Int
    let currentRating: Int
    let action: () -> Void

    private var isFilled: Bool {
        self.value <= self.currentRating
    }

    var body: some View {
        Button(action: self.action) {
            Image(systemName: self.isFilled ? "star.fill" : "star")
                .font(.title2)
                .foregroundColor(self.isFilled ? Color.rcSalmon300 : Color.rcSeaweed800.opacity(0.3))
                .frame(width: RatingPicker.Constants.starSize, height: RatingPicker.Constants.starSize)
                .scaleEffect(self.isFilled ? 1.0 : 0.9)
                .animation(
                    .spring(
                        response: RatingPicker.Constants.springResponse,
                        dampingFraction: RatingPicker.Constants.springDamping
                    ),
                    value: self.isFilled
                )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(self.value) star\(self.value == 1 ? "" : "s")")
        .accessibilityAddTraits(self.isFilled ? .isSelected : [])
    }
}

// MARK: - Preview

#if DEBUG
    struct RatingPicker_Previews: PreviewProvider {
        struct PreviewWrapper: View {
            @State private var rating: Int = 3

            var body: some View {
                VStack(spacing: 32) {
                    Text("Rating: \(self.rating)")
                        .font(.headline)

                    RatingPicker(rating: self.$rating, hapticService: nil)

                    Button("Reset to 3") {
                        withAnimation {
                            self.rating = 3
                        }
                    }
                    .padding()
                    .background(Color.rcPink500)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
            }
        }

        static var previews: some View {
            PreviewWrapper()
                .previewDisplayName("Rating Picker")
        }
    }
#endif
