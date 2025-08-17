//
// RollTypePicker.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import SwiftUI

/// A grid-based roll type picker with accessible touch targets
struct RollTypePicker: View {
    @Binding var selectedType: RollType
    let hapticService: HapticFeedbackServicing?

    // MARK: - Constants

    enum Constants {
        static let gridColumns = 2
        static let itemMinHeight: CGFloat = 44 // WCAG 2.2 AA minimum
        static let itemPadding: CGFloat = 12
        static let cornerRadius: CGFloat = 12
        static let borderWidth: CGFloat = 2
        static let animationDuration: Double = 0.2
        static let gridSpacing: CGFloat = 12
    }

    // MARK: - Layout

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: Constants.gridSpacing),
        count: Constants.gridColumns
    )

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Roll Type")
                .font(.headline)
                .foregroundColor(.rcSeaweed800)
                .accessibilityAddTraits(.isHeader)

            LazyVGrid(columns: self.columns, spacing: Constants.gridSpacing) {
                ForEach(RollType.allCases, id: \.self) { type in
                    RollTypeButton(
                        type: type,
                        isSelected: self.selectedType == type
                    ) { self.selectType(type) }
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    // MARK: - Private Methods

    private func selectType(_ type: RollType) {
        guard self.selectedType != type else { return }

        withAnimation(.easeInOut(duration: Constants.animationDuration)) {
            self.selectedType = type
        }

        Task {
            await self.hapticService?.impact(style: .light)
        }
    }
}

// MARK: - Roll Type Button Component

private struct RollTypeButton: View {
    let type: RollType
    let isSelected: Bool
    let action: () -> Void

    private var backgroundColor: Color {
        self.isSelected ? Color.rcPink500 : Color.rcRice50
    }

    private var foregroundColor: Color {
        self.isSelected ? .white : Color.rcSeaweed800
    }

    private var borderColor: Color {
        self.isSelected ? Color.rcPink500 : Color.rcNori800.opacity(0.08)
    }

    var body: some View {
        Button(action: self.action) {
            VStack(spacing: 4) {
                Image(systemName: self.type.iconName)
                    .font(.title3)

                Text(self.type.displayName)
                    .font(.caption)
                    .fontWeight(self.isSelected ? .semibold : .regular)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: RollTypePicker.Constants.itemMinHeight)
            .padding(RollTypePicker.Constants.itemPadding)
            .background(self.backgroundColor)
            .foregroundColor(self.foregroundColor)
            .cornerRadius(RollTypePicker.Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: RollTypePicker.Constants.cornerRadius)
                    .strokeBorder(self.borderColor, lineWidth: RollTypePicker.Constants.borderWidth)
            )
            .shadow(
                color: self.isSelected ? Color.rcPink500.opacity(0.3) : Color.clear,
                radius: self.isSelected ? 8 : 0,
                y: self.isSelected ? 2 : 0
            )
            .scaleEffect(self.isSelected ? 1.02 : 1.0)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.7),
                value: self.isSelected
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(self.type.displayName) roll type")
        .accessibilityAddTraits(self.isSelected ? [.isSelected] : [])
        .accessibilityHint(self.isSelected ? "Currently selected" : "Tap to select")
    }
}

// MARK: - RollType Extension for UI

extension RollType {
    var iconName: String {
        switch self {
        case .nigiri:
            "rectangle.portrait.fill"
        case .maki:
            "circle.fill"
        case .sashimi:
            "square.fill"
        case .temaki:
            "triangle.fill"
        case .uramaki:
            "circle.circle.fill"
        case .omakase:
            "star.fill"
        case .other:
            "questionmark.circle.fill"
        }
    }
}

// MARK: - Preview

#if DEBUG
    struct RollTypePicker_Previews: PreviewProvider {
        struct PreviewWrapper: View {
            @State private var selectedType: RollType = .nigiri

            var body: some View {
                VStack(spacing: 24) {
                    Text("Selected: \(self.selectedType.displayName)")
                        .font(.headline)

                    RollTypePicker(selectedType: self.$selectedType, hapticService: nil)

                    Button("Reset to Nigiri") {
                        withAnimation {
                            self.selectedType = .nigiri
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.rcPink500)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.body.weight(.semibold))
                }
                .padding()
            }
        }

        static var previews: some View {
            Group {
                PreviewWrapper()
                    .previewDisplayName("Roll Type Picker")

                PreviewWrapper()
                    .preferredColorScheme(.dark)
                    .previewDisplayName("Dark Mode")

                PreviewWrapper()
                    .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
                    .previewDisplayName("XXL Dynamic Type")
            }
        }
    }
#endif
