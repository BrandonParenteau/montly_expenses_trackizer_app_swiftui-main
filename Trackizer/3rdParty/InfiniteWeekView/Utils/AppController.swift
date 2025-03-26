//
//  AppController.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-01-25.
//

import FirebaseAuth
import SwiftUI
import GoogleSignIn

class AppController: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String? = nil
    @Published var isAuthenticated: Bool = false
    
    init() {
        if Auth.auth().currentUser != nil {
            self.isAuthenticated = true
        }
    }
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email and password cannot be empty"])
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
        
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            await MainActor.run {
                print("User signed up: \(authResult.user.uid)")
                self.isAuthenticated = true
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func signIn() async throws {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            await MainActor.run {
                print("User signed in: \(authResult.user.uid)")
                self.isAuthenticated = true
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func signOut() async throws {
        do {
            try Auth.auth().signOut()
            await MainActor.run {
                self.isAuthenticated = false
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
}
