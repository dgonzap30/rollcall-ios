//
// GradientCTAButton.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import SwiftUI

#if canImport(SwiftUI)
    @available(iOS 15.0, *)
    @MainActor
    public struct GradientCTAButton: View {
        let title: String
        let icon: String?
        let systemIcon: String?
        let action: () async -> Void
        let isPressed: Binding<Bool>?

        @State private var arrowOffset: CGFloat = 0

        public init(
            title: String,
            icon: String? = nil,
            systemIcon: String? = nil,
            action: @escaping () async -> Void,
            isPressed: Binding<Bool>? = nil
        ) {
            self.title = title
            self.icon = icon
            self.systemIcon = systemIcon
            self.action = action
            self.isPressed = isPressed
        }

        public var body: some View {
            Button(action: {
                Task {
                    await self.action()
                }
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.rcGradientPink,
                                    Color.rcGradientOrange
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                .padding(1)
                        )

                    HStack(spacing: 12) {
                        if let icon {
                            Image(icon)
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                        } else if let systemIcon {
                            Image(systemName: systemIcon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        Text(self.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .kerning(0.3)

                        if self.showArrow {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .offset(x: self.arrowOffset)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
            })
            .scaleEffect(self.isPressedValue ? 0.95 : 1.0)
            .compositingGroup()
            .shadow(
                color: Color.black.opacity(0.15),
                radius: self.isPressedValue ? 8 : 12,
                x: 0,
                y: self.isPressedValue ? 2 : 3
            )
            .accessibilityLabel(self.title)
            .accessibilityHint("Double tap to \(self.title.lowercased())")
            .onAppear {
                if self.showArrow {
                    withAnimation(
                        .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                    ) {
                        self.arrowOffset = 4
                    }
                }
            }
        }

        private var isPressedValue: Bool {
            self.isPressed?.wrappedValue ?? false
        }

        private var showArrow: Bool {
            self.icon == nil && self.systemIcon == nil
        }
    }

    #if DEBUG
        @available(iOS 15.0, *)
        struct GradientCTAButton_Previews: PreviewProvider {
            static var previews: some View {
                VStack(spacing: 20) {
                    GradientCTAButton(
                        title: "Begin Your Journey"
                    ) {}

                    GradientCTAButton(
                        title: "Continue",
                        systemIcon: "arrow.forward.circle.fill"
                    ) {}

                    GradientCTAButton(
                        title: "Get Started",
                        icon: "sushi.icon"
                    ) {}
                }
                .padding()
                .background(Color.rcRice50)
            }
        }
    #endif
#endif
