//
//  AppDelegate.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-01-25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import LinkKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
        FirebaseApp.configure()
            
        return true
    }
}

