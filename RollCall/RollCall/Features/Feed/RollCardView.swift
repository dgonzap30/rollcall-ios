//
// RollCardView.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

#if canImport(SwiftUI)
    import SwiftUI

    @available(iOS 15.0, *)
    @MainActor
    public struct RollCardView: View {
        let rollCard: RollCardViewState
        let onTap: () -> Void

        public init(rollCard: RollCardViewState, onTap: @escaping () -> Void) {
            self.rollCard = rollCard
            self.onTap = onTap
        }

        public var body: some View {
            Button(action: self.onTap) {
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    self.headerSection
                    self.rollInfoSection
                    self.ratingSection
                    self.descriptionSection
                    self.tagsSection
                }
                .padding(Spacing.Padding.medium)
                .background(Color.rcRice50)
                .cornerRadius(BorderRadius.large)
                .shadow(color: Color.rcNori800.opacity(0.08), radius: 8, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: BorderRadius.large)
                        .strokeBorder(Color.rcNori800.opacity(0.06), lineWidth: 1)
                )
            }
            .buttonStyle(ScaleButtonStyle())
            .accessibilityElement(children: .combine)
            .accessibilityLabel(self.accessibilityDescription)
            .accessibilityHint("Double tap to view details")
        }

        // MARK: - Header Section

        private var headerSection: some View {
            HStack(spacing: Spacing.small) {
                // Chef avatar placeholder
                Circle()
                    .fill(Color.rcPink100)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(self.rollCard.chefName.prefix(1).uppercased())
                            .font(.rcCaption)
                            .fontWeight(.semibold)
                            .foregroundColor(.rcPink700)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(self.rollCard.chefName)
                        .font(.rcBody)
                        .fontWeight(.medium)
                        .foregroundColor(.rcSeaweed800)

                    Text(self.rollCard.timeAgo)
                        .font(.rcCaption)
                        .foregroundColor(.rcSoy600)
                }

                Spacer()

                // Roll type badge
                Text(self.rollCard.rollType)
                    .font(.rcCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.rcPink700)
                    .padding(.horizontal, Spacing.Padding.small)
                    .padding(.vertical, Spacing.Padding.tiny)
                    .background(Color.rcPink100)
                    .cornerRadius(BorderRadius.small)
            }
        }

        // MARK: - Roll Info Section

        private var rollInfoSection: some View {
            VStack(alignment: .leading, spacing: Spacing.xSmall) {
                Text(self.rollCard.rollName)
                    .font(.rcHeadline)
                    .foregroundColor(.rcSeaweed800)
                    .lineLimit(2)

                HStack(spacing: Spacing.xxxSmall) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.rcSoy600)

                    Text(self.rollCard.restaurantName)
                        .font(.rcCaption)
                        .foregroundColor(.rcSoy600)
                        .lineLimit(1)
                }
            }
        }

        // MARK: - Rating Section

        private var ratingSection: some View {
            HStack(spacing: Spacing.xxxSmall) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= self.rollCard.rating ? "star.fill" : "star")
                        .font(.system(size: 14))
                        .foregroundColor(star <= self.rollCard.rating ? .rcSalmon300 : .rcSoy600.opacity(0.3))
                }
            }
        }

        // MARK: - Description Section

        @ViewBuilder
        private var descriptionSection: some View {
            if let description = rollCard.description {
                Text(description)
                    .font(.rcBody)
                    .foregroundColor(.rcSeaweed800.opacity(0.8))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
        }

        // MARK: - Tags Section

        @ViewBuilder
        private var tagsSection: some View {
            if !self.rollCard.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.xSmall) {
                        ForEach(self.rollCard.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.rcCaption)
                                .foregroundColor(.rcPink700)
                                .padding(.horizontal, Spacing.Padding.small)
                                .padding(.vertical, Spacing.Padding.tiny)
                                .background(Color.rcPink100.opacity(0.6))
                                .cornerRadius(BorderRadius.small)
                        }
                    }
                }
            }
        }

        // MARK: - Private Helpers

        private var accessibilityDescription: String {
            "\(self.rollCard.chefName) logged \(self.rollCard.rollName) at \(self.rollCard.restaurantName). " +
                "Rating: \(self.rollCard.rating) out of 5 stars"
        }
    }

    // MARK: - Preview

    #if DEBUG
        @available(iOS 15.0, *)
        struct RollCardView_Previews: PreviewProvider {
            static var previews: some View {
                RollCardView(
                    rollCard: RollCardViewState(
                        id: "1",
                        chefName: "Chef Tanaka",
                        chefAvatarURL: nil,
                        restaurantName: "Sushi Paradise",
                        rollName: "Salmon Nigiri",
                        rollType: "Nigiri",
                        rating: 5,
                        description: "Fresh and buttery salmon with perfect rice seasoning",
                        photoURL: nil,
                        timeAgo: "2 hours ago",
                        tags: ["salmon", "fresh", "traditional"]
                    )
                ) {}
                    .padding()
                    .background(Color.rcBackgroundBase)
                    .previewLayout(.sizeThatFits)
            }
        }
    #endif

#endif
