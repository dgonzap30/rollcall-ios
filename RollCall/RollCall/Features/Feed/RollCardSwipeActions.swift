//
// RollCardSwipeActions.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import SwiftUI

/// Swipe action modifiers for roll cards in the feed
@available(iOS 15.0, *)
struct RollCardSwipeActionsModifier: ViewModifier {
    let roll: Roll
    let onEdit: (Roll) -> Void
    let onDelete: (Roll) -> Void
    @State private var showDeleteConfirmation = false

    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                self.deleteButton
                self.editButton
            }
            .confirmationDialog(
                "Delete Roll?",
                isPresented: self.$showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    self.onDelete(self.roll)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete \"\(self.roll.name)\"? This action cannot be undone.")
            }
    }

    private var editButton: some View {
        Button {
            self.onEdit(self.roll)
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(.rcPink500)
    }

    private var deleteButton: some View {
        Button {
            self.showDeleteConfirmation = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red)
    }
}

// MARK: - View Extension

@available(iOS 15.0, *)
extension View {
    /// Adds swipe actions for editing and deleting a roll
    /// - Parameters:
    ///   - roll: The roll to perform actions on
    ///   - onEdit: Closure called when edit is tapped
    ///   - onDelete: Closure called when delete is confirmed
    func rollCardSwipeActions(
        roll: Roll,
        onEdit: @escaping (Roll) -> Void,
        onDelete: @escaping (Roll) -> Void
    ) -> some View {
        modifier(RollCardSwipeActionsModifier(
            roll: roll,
            onEdit: onEdit,
            onDelete: onDelete
        ))
    }
}

// MARK: - Roll Swipe Action Result

@available(iOS 15.0, *)
enum RollSwipeAction {
    case edit(Roll)
    case delete(RollID)
    case cancelled
}
