//
//  PlaidViewModel.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-02-09.
//

import Foundation
import LinkKit
import FirebaseAuth

class PlaidViewModel: ObservableObject {
    @Published var linkSuccess = false
    @Published var isPaymentInitiation = false
    @Published var itemId: String?
    @Published var linkToken: String?
    @Published var linkTokenError: String?
    @Published var products: [String] = []
    @Published var linkController: LinkController?
    @Published var transactions: [Transaction] = []
    @Published var categoryTotals: [String: Double] = [:]
    
    
    private let plaidManager: PlaidManager
    private let baseURL = "http://192.168.1.109:5001"
    @Published var hassFetchedtransactions = false
    
    init(plaidManager: PlaidManager = PlaidManager()) {
        self.plaidManager = plaidManager
    }
    
    func fetchTransactions() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("🔑 Please sign in to view transactions")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/get_transactions") else {
            print("🌐 URL configuration needed")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["userId": userId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("🌐 Network status: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("📦 Waiting for transaction data")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Server response: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 404 {
                    print("👤 User profile update needed")
                    return
                }
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(PlaidTransactionsResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.transactions = decodedResponse.transactions
                    self?.categorizeTransactions()
                    print("✅ Transactions loaded successfully")
                }
            } catch {
                print("🔄 Retrying transaction fetch in 3 seconds")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self?.fetchTransactions()
                }
            }
        }.resume()
    }

    private func categorizeTransactions() {
        // Group transactions by category
        let grouped = Dictionary(grouping: transactions) { transaction in
            transaction.category?.first ?? "Other"
        }
        
        // Update category totals
        categoryTotals = grouped.mapValues { transactions in
            transactions.reduce(0) { $0 + $1.amount }
        }
    }


    func initalizePlaidLink(userId: String) async {
        print("🚀 Starting Plaid Link initialization for user: \(userId)")
        await fetchLinkToken(userId: userId)
        
        if let token = linkToken {
            print("🎟 Token received: \(token)")
            var config = LinkTokenConfiguration(token: token) { success in
                print("✅ Success callback received")
                print("🔑 Public token: \(success.publicToken)")
                print("📊 Metadata:")
                print("  - Institution: \(success.metadata.institution.name)")
                print("  - Accounts: \(success.metadata.accounts.count)")
                
                self.handlePlaidSuccess(publicToken: success.publicToken, userId: userId) // Pass userId
            }
            
            config.onEvent = { event in
                print("📡 Plaid Link Event: \(event.eventName)")
                print("  Details: \(event.metadata)")
            }
            
            config.onExit = { exit in
                if let error = exit.error {
                    print("❌ Exit with error: \(error.displayMessage)")
                    print("  Code: \(error.errorCode)")
                } else {
                    print("👋 User exited normally")
                }
            }
            
            let result = Plaid.create(config)
            print("🛠 Plaid.create result: \(result)")
            
            if case .success(let handler) = result {
                print("✨ Handler created successfully")
                await MainActor.run {
                    self.linkController = LinkController(handler: handler)
                    print("🎮 LinkController initialized and ready")
                }
            } else {
                print("🔴 Failed to create Plaid handler")
            }
        } else {
            print("🔴 No link token received")
        }
    }
    
    // Modified to accept userId
    func fetchLinkToken(userId: String) async {
        print("Starting link token fetch for user: \(userId)")
        guard let url = URL(string: "\(baseURL)/create_link_token") else {
            print("❌ Invalid URL for creating link token")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add the userId to the request body
        let body: [String: Any] = ["userId": userId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check the HTTP status code
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("🔴 HTTP error: \(httpResponse.statusCode)")
                return
            }
            
            print("Received data from server")
            let linkTokenResponse = try JSONDecoder().decode(PlaidLinkTokenResponse.self, from: data)
            print("Link token received: \(linkTokenResponse.link_token)")
            
            await MainActor.run {
                self.linkToken = linkTokenResponse.link_token
                self.plaidManager.linkToken = linkTokenResponse.link_token
            }
        } catch {
            print("❌ Error fetching link token: \(error)")
        }
    }
    
    // Modified to accept userId
    func handlePlaidSuccess(publicToken: String, userId: String) {
        exchangePublicToken(publicToken, userId: userId) // Pass userId
        linkSuccess = true
    }
    
    // Modified to accept userId
    private func exchangePublicToken(_ publicToken: String, userId: String) {
        guard let url = URL(string: "\(baseURL)/exchange_public_token") else {
            print("❌ Invalid URL for exchanging public token")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["public_token": publicToken, "userId": userId] // Include userId
        // Use JSONSerialization instead of JSONEncoder
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ Exchange error: \(error)")
                return // Exit if there's a network error
            }
            
            guard let data = data else {
                print("❌ No data received during exchange")
                return // Exit if no data
            }
            
            // Print the raw JSON response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON Response: \(jsonString)")
            }
            
            do {
                let exchangeResponse = try JSONDecoder().decode(PlaidExchangeTokenResponse.self, from: data)
                print("✅ Exchange successful, item ID: \(exchangeResponse.item_id), request ID: \(exchangeResponse.request_id)") // Print request_id
                DispatchQueue.main.async {
                    self?.itemId = exchangeResponse.item_id
                }
            } catch {
                print("❌ Decoding error during exchange: \(error)")
            }
        }.resume() // Make sure to call resume()
    }
    
    // The Codable struct MUST include request_id
    struct PlaidExchangeTokenResponse: Codable {
        let access_token: String
        let item_id: String
        let request_id: String // <---- ADD THIS
    }
}
