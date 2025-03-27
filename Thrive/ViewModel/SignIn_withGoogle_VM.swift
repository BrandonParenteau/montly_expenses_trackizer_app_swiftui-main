//
//  SignIn_withGoogle_VM.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-02-05.
//

import SwiftUI
import Firebase
import GoogleSignIn
import FirebaseAuth

class SignIn_withGoogle_VM: ObservableObject {
    @Published var isLoginSuccessed = false
    
    func signInWithGoogle() {
        // Get the root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("No root view controller found")
            return
        }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] user, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard
                let user = user?.user,
                let idToken = user.idToken else { return }
            
            let accessToken = user.accessToken
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken.tokenString,
                accessToken: accessToken.tokenString
            )
            
            Auth.auth().signIn(with: credential) { [weak self] res, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let user = res?.user else { return }
                print(user)
                
                DispatchQueue.main.async {
                    self?.isLoginSuccessed = true
                }
            }
        }
    }
}
