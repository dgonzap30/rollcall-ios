//
// AuthServicing.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

// MARK: - Auth Service Protocol

@available(iOS 15.0, macOS 12.0, *)
protocol AuthServicing {
    func login(email: String, password: String) async throws -> Chef
    func logout() async throws
    func signup(email: String, password: String, username: String) async throws -> Chef
    func getCurrentChef() async throws -> Chef?
    func updateProfile(_ chef: Chef) async throws -> Chef
    func deleteAccount() async throws
    func requestPasswordReset(email: String) async throws
}

// MARK: - Auth Error

@available(iOS 15.0, macOS 12.0, *)
enum AuthError: LocalizedError {
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            "Invalid email or password"
        case .emailAlreadyInUse:
            "This email is already registered"
        case .weakPassword:
            "Password must be at least 8 characters"
        case .networkError:
            "Network connection error"
        case .unknown:
            "An unknown error occurred"
        }
    }
}
