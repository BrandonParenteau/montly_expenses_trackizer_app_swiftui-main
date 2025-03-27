//
//  TrackizerApp.swift
//  Trackizer
//
//  Created by CodeForAny on 11/07/23.
//

import SwiftUI
import Firebase
import GoogleSignIn
import LinkKit

@main
struct TrackizerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var appController = AppController() // Use @StateObject for EnvironmentObject
    @StateObject var weekStore = WeekStore()
    
    

    var body: some Scene {
        WindowGroup {
            if appController.isAuthenticated {
                OnboardingView()
                    .environmentObject(weekStore)
                    .environmentObject(appController)
            } else {
                WelcomView()
            }
        }
    }
}
