//
// ErrorView.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/07/25.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
struct ErrorView: View {
    let error: AppError
    let retry: (() -> Void)?

    @ViewBuilder private var errorIcon: some View {
        switch self.error {
        case .network:
            Text("📡")
                .font(.system(size: 36))
                .rotationEffect(.degrees(180))
        case .unauthorized:
            Text("🔒")
                .font(.system(size: 36))
        default:
            Text("⚠️")
                .font(.system(size: 36))
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            // Error icon
            ZStack {
                Circle()
                    .fill(Color.rcSalmon300.opacity(0.1))
                    .frame(width: 80, height: 80)

                self.errorIcon
            }

            VStack(spacing: 12) {
                // Error title
                Text("Oops!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.rcSeaweed800)

                // Error message
                Text(self.error.localizedDescription)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.rcSeaweed800.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                // Recovery suggestion
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.rcSoy600)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 32)

            // Retry button
            if let retry {
                Button(action: retry) {
                    HStack(spacing: 8) {
                        Text("↻")
                            .font(.system(size: 20, weight: .bold))

                        Text("Try Again")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [Color.rcGradientPink, Color.rcGradientOrange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 3)
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(1.0)
                .animation(AnimationTokens.Spring.bouncy(), value: 1.0)
            }
        }
        .padding(40)
        .frame(maxWidth: 400)
    }
}

#if DEBUG
    @available(iOS 15.0, macOS 12.0, *)
    struct ErrorView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ErrorView(
                    error: .network(URLError(.notConnectedToInternet))
                ) { print("Retry tapped") }
                    .previewDisplayName("Network Error")

                ErrorView(
                    error: .unauthorized,
                    retry: nil
                )
                .previewDisplayName("Unauthorized")

                ErrorView(
                    error: .validation(field: "Email", message: "Invalid email format")
                ) { print("Retry tapped") }
                    .previewDisplayName("Validation Error")
            }
        }
    }
#endif
