//
//  PlaidManager.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-02-09.
//

// Add to Podfile:
// pod 'Plaid', '~> 5.0'

// Add to Podfile:
// pod 'Plaid', '~> 5.0'

// Add to Podfile:
// pod 'Plaid', '~> 5.0'


import LinkKit
import UIKit
import SwiftUI

class PlaidManager: ObservableObject {
    @Published var linkToken: String = ""
    private var linkHandler: Handler?
    @Published var categoryTotals: [String: Double] = [:]
    
    
    func fetchLinkToken(completion: @escaping () -> Void) {
        let url = URL(string: "http://192.168.1.96:5001/create_link_token")!
        
        // Add request configuration
        var request = URLRequest(url: url)
        request.httpMethod = "POST"  // Ensure method matches server expectation
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("🔄 Starting link token fetch...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching link token:", error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Response status code:", httpResponse.statusCode)
            }
            
            if let data = data {
                print("📦 Received data:", String(data: data, encoding: .utf8) ?? "")
                
                do {
                    let tokenResponse = try JSONDecoder().decode(LinkTokenResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.linkToken = tokenResponse.link_token
                        print("✅ Link token received:", self.linkToken)
                        completion()
                    }
                } catch {
                    print("❌ JSON decode error:", error)
                }
            }
        }.resume()
    }

    // MARK: - Present Plaid Link
    func presentPlaidLink() {
        guard !linkToken.isEmpty else {
            print("Link token is not available")
            return
        }

        let linkConfiguration = LinkTokenConfiguration(
            token: linkToken,
            onSuccess: { success in
                print("Public token: \(success.publicToken)")
                // TODO: Send public token to your backend
            }
        )

        let result = Plaid.create(linkConfiguration)
        switch result {
        case .success(let handler):
            self.linkHandler = handler
            DispatchQueue.main.async {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let viewController = windowScene.windows.first?.rootViewController {
                    handler.open(presentUsing: .viewController(viewController))
                }
            }
        case .failure(let error):
            print("Link creation error: \(error)")
        }
    }
}

struct LinkTokenResponse: Codable {
    let link_token: String
}
