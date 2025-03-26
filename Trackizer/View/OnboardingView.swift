//
//  OnboardingView.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-02-18.
//

import SwiftUI
import LinkKit
import FirebaseAuth

struct OnboardingView: View {
    @State private var showOnboarding = true
    @State private var isPresentingLink = false // Controls Plaid modal
    @StateObject var viewModel = PlaidViewModel() // Inject Plaid ViewModel

    var body: some View {
        if showOnboarding {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    TabView {
                        FeatureView(imageName: "chart.bar", title: "Track Your Expenses", description: "Easily track all your transactions in one place.", backgroundImage: "track_expenses")
                        FeatureView(imageName: "creditcard", title: "Set Budgets", description: "Manage your spending and stick to your budget.", backgroundImage: "set_budget")
                        FeatureView(imageName: "chart.pie", title: "Get Insights", description: "See where your money goes with detailed analytics.", backgroundImage: "calendar_view")
                    }
                    .frame(height: 550)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))

                    Spacer()

                    // Connect Bank Button
                    PrimaryButton(title: "Connect Bank", onPressed: {
                        Task {
                            guard let userId = Auth.auth().currentUser?.uid else {
                                print("❌ No user ID found")
                                return
                            }
                            await viewModel.initalizePlaidLink(userId: userId)
                            isPresentingLink = true // Show Plaid Link UI
                        }
                    })
                    .offset(y: -75) // Adjust to position properly

                    // Setup Later Button -> Goes to MainTabView
                    PrimaryButton(title: "Setup Later", onPressed: {
                        showOnboarding = false // Hide onboarding and show MainTabView
                    })
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .offset(y: -50) // Adjust for proper placement
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
            }
            .transition(.move(edge: .bottom))
            .sheet(isPresented: $isPresentingLink) {
                if let linkController = viewModel.linkController {
                    linkController
                        .ignoresSafeArea()
                        .onDisappear {
                            if viewModel.linkSuccess {
                                showOnboarding = false // Dismiss onboarding after linking bank
                            }
                        }
                } else {
                    Text("Loading Plaid...") // Show loading state if linkController is nil
                }
            }
        } else {
            MainTabView() // Show MainTabView after onboarding
        }
    }
}

struct FeatureView: View {
    var imageName: String
    var title: String
    var description: String
    var backgroundImage: String

    var body: some View {
        ZStack {
            Image(backgroundImage)
                .resizable()
                .scaledToFit()
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Image(systemName: imageName) // Replace with actual feature images
                //     .resizable()
                //     .scaledToFit()
                //     .frame(width: 100, height: 100)
                //     .padding()
                //     .foregroundColor(.blue)

                // Text(title)
                //     .font(.title2)
                //     .fontWeight(.bold)
                //     .padding(.top, 10)
                //     .foregroundColor(.white)

                // Text(description)
                //     .font(.body)
                //     .multilineTextAlignment(.center)
                //     .padding(.horizontal, 20)
                //     .foregroundColor(.white)
            }
            .padding()
            .background(Color.clear)
            .cornerRadius(12)
            .offset(y: 50)
        }
    }
}

#Preview {
    OnboardingView() // Remove showConnectBank binding
}
