//
//  TransactionViewModel.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-02-19.
//

import SwiftUI
import FirebaseAuth
import Foundation

struct Transaction: Codable, Identifiable {
    let id: String
    let amount: Double
    let date: String
    let name: String
    let merchantName: String?
    let category: [String]?
    let pending: Bool
    let accountId: String
    let paymentChannel: String?
    var isManual: Bool
    var selectedIcon: String
    
    enum CodingKeys: String, CodingKey {
        case id = "transaction_id"
        case amount
        case date
        case name
        case merchantName = "merchant_name"
        case category
        case pending
        case accountId = "account_id"
        case paymentChannel = "payment_channel"
        case isManual
        case selectedIcon
    }
    
    init(id: String, amount: Double, date: String, name: String, merchantName: String?,
         category: [String]?, pending: Bool, accountId: String, paymentChannel: String?,
         isManual: Bool, selectedIcon: String) {
        self.id = id
        self.amount = amount
        self.date = date
        self.name = name
        self.merchantName = merchantName
        self.category = category
        self.pending = pending
        self.accountId = accountId
        self.paymentChannel = paymentChannel
        self.isManual = isManual
        self.selectedIcon = selectedIcon
        
        print("DEBUG: Created transaction with name: \(name), category: \(category?.first ?? "none"), icon: \(selectedIcon)")
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        amount = try container.decode(Double.self, forKey: .amount)
        date = try container.decode(String.self, forKey: .date)
        name = try container.decode(String.self, forKey: .name)
        merchantName = try container.decodeIfPresent(String.self, forKey: .merchantName)
        category = try container.decodeIfPresent([String].self, forKey: .category)
        pending = try container.decode(Bool.self, forKey: .pending)
        accountId = try container.decode(String.self, forKey: .accountId)
        paymentChannel = try container.decodeIfPresent(String.self, forKey: .paymentChannel)
        
        // Try to decode isManual, defaulting to false if not present
        isManual = try container.decodeIfPresent(Bool.self, forKey: .isManual) ?? false
        
        print("DEBUG: Decoding transaction: \(name), category: \(category?.first ?? "none"), isManual: \(isManual)")
        
        // First try to decode the selectedIcon from the data
        if let icon = try? container.decodeIfPresent(String.self, forKey: .selectedIcon), !icon.isEmpty {
            print("DEBUG: Using provided icon: \(icon)")
            selectedIcon = icon
        } else {
            // Otherwise determine the icon based on the transaction data
            selectedIcon = Self.determineIcon(
                category: category?.first,
                merchantName: merchantName,
                name: name
            )
            print("DEBUG: Determined icon: \(selectedIcon)")
        }
    }
    
    static func determineIcon(category: String?, merchantName: String?, name: String) -> String {
        // Log the inputs to see what we're working with
        print("DEBUG: determineIcon inputs - category: \(category ?? "nil"), merchantName: \(merchantName ?? "nil"), name: \(name)")
        
        let searchText = [category, merchantName, name]
            .compactMap { $0?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
            .joined(separator: " ")
        
        print("DEBUG: searchText = \(searchText)")
        
        // Define keyword groups
        let foodKeywords = ["food", "restaurant", "dining", "cafe", "coffee", "doordash", "drink", "mcdonalds", "starbucks", "chipotle", "burger"]
        let transportKeywords = ["uber", "lyft", "taxi", "transport", "parking", "gas", "car", "auto", "vehicle"]
        let shoppingKeywords = ["shopping", "amazon", "target", "walmart", "store", "market", "purchase", "buy"]
        let healthKeywords = ["health", "medical", "pharmacy", "doctor", "hospital", "clinic", "dental", "medicine"]
        let entertainmentKeywords = ["entertainment", "spotify", "netflix", "movie", "hulu", "disney", "game", "music", "stream"]
        let utilitiesKeywords = ["utilities", "electric", "water", "internet", "phone", "bill", "subscription", "cable", "service"]
        let educationKeywords = ["education", "school", "university", "college", "tuition", "course", "class", "student"]
        let travelKeywords = ["travel", "airline", "hotel", "airbnb", "flight", "trip", "vacation", "booking"]
        let groceriesKeywords = ["groceries", "supermarket", "trader", "whole foods", "safeway", "kroger", "food"]
        let fitnessKeywords = ["fitness", "gym", "sport", "workout", "exercise", "training"]
        let incomeKeywords = ["deposit", "salary", "payment", "income", "payroll", "wage", "earning", "direct deposit"]
        
        // Check each keyword group
        for (keywords, icon) in [
            (foodKeywords, "fork.knife"),
            (transportKeywords, "car.fill"),
            (shoppingKeywords, "cart.fill"),
            (healthKeywords, "cross.case.fill"),
            (entertainmentKeywords, "play.tv.fill"),
            (utilitiesKeywords, "bolt.fill"),
            (educationKeywords, "book.fill"),
            (travelKeywords, "airplane"),
            (groceriesKeywords, "basket.fill"),
            (fitnessKeywords, "figure.run"),
            (incomeKeywords, "dollarsign.circle.fill")
        ] {
            // Check if any keyword is contained in the search text
            for keyword in keywords {
                if searchText.contains(keyword) {
                    print("DEBUG: Matched keyword \"\(keyword)\" -> \(icon)")
                    return icon
                }
            }
        }
        
        print("DEBUG: No keyword match found, defaulting to creditcard.fill")
        return "creditcard.fill"
    }
}

extension Transaction {
    static func createManual(
        id: String = UUID().uuidString,
        amount: Double,
        name: String,
        category: String,
        selectedIcon: String
    ) -> Transaction {
        print("DEBUG: Creating manual transaction - name: \(name), category: \(category), icon: \(selectedIcon)")
        return Transaction(
            id: id,
            amount: amount,
            date: Date().ISO8601Format(),
            name: name,
            merchantName: name,
            category: [category],
            pending: false,
            accountId: "manual",
            paymentChannel: "manual",
            isManual: true,
            selectedIcon: selectedIcon
        )
    }
}

struct PlaidTransactionsResponse: Codable {
    let transactions: [Transaction]
    let total_transactions: Int
}

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var manualTransactions: [Transaction] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var lastRefreshDate: Date?
    @Published var hasFetchedTransactions = false
    @Published var searchText = ""
    @Published var selectedCategory: String?
    @Published var categoryTotals: [String: Double] = [:]
    @Published var showBankTransactions:Bool = true
    
    private let baseURL = "http://192.168.1.109:5001"
    
    init() {
        print("DEBUG: TransactionViewModel initialized")
        loadManualTransactions()
        
        if Auth.auth().currentUser != nil {
            fetchTransactions()
        }
    }
    
    var categoryAnalysis: [(category: String, amount: Double)] {
        let groupedTransactions = Dictionary(grouping: transactions) { transaction in
            transaction.category?.first ?? "Other"
        }
        
        return groupedTransactions.map { category, transactions in
            let total = transactions.reduce(0) { $0 + abs($1.amount) }
            return (category: category, amount: total)
        }.sorted { $0.amount > $1.amount }
    }
    
    
    // Add this computed property for filtered transactions
    var filteredTransactions: [Transaction] {
        let transactions = showBankTransactions ? transactions : manualTransactions
        
        let searched = searchText.isEmpty ? transactions : transactions.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
        
        if let category = selectedCategory {
            return searched.filter { $0.category?.first == category }
        }
        return searched
    }
    
    // Add this function to calculate category totals
    func updateCategoryTotals() {
        let grouped = Dictionary(grouping: transactions) { transaction in
            transaction.category?.first ?? "Other"
        }
        
        categoryTotals = grouped.mapValues { transactions in
            transactions.reduce(0) { $0 + abs($1.amount) }
        }
    }
    
    
    var allTransactions: [Transaction] {
        let combined = transactions + manualTransactions
        let sorted = combined.sorted {
            // Convert string dates to Date objects for proper sorting
            let dateFormatter = ISO8601DateFormatter()
            if let date1 = dateFormatter.date(from: $0.date),
               let date2 = dateFormatter.date(from: $1.date) {
                return date1 > date2
            }
            return false
        }
        print("DEBUG: All transactions count: \(sorted.count) (API: \(transactions.count), Manual: \(manualTransactions.count))")
        return sorted
    }
    
    
    
    
    
    func addManualTransaction(amount: Double, name: String, category: String, selectedIcon: String) {
        print("DEBUG: Adding manual transaction - \(name), \(category), \(selectedIcon)")
        let newTransaction = Transaction.createManual(
            amount: amount,
            name: name,
            category: category,
            selectedIcon: selectedIcon
            
        )
        manualTransactions.append(newTransaction)
        print("DEBUG: Manual transactions count after adding: \(manualTransactions.count)")
        saveManualTransactions()
    }
    
    private func saveManualTransactions() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(manualTransactions)
            UserDefaults.standard.set(data, forKey: "manualTransactions")
            print("DEBUG: Saved \(manualTransactions.count) manual transactions to UserDefaults")
        } catch {
            print("ERROR: Failed to save manual transactions: \(error)")
        }
    }
    
    private func loadManualTransactions() {
        if let data = UserDefaults.standard.data(forKey: "manualTransactions") {
            do {
                let decoder = JSONDecoder()
                let loaded = try decoder.decode([Transaction].self, from: data)
                manualTransactions = loaded
                print("DEBUG: Loaded \(manualTransactions.count) manual transactions from UserDefaults")
            } catch {
                print("ERROR: Failed to decode manual transactions: \(error)")
            }
        } else {
            print("DEBUG: No manual transactions found in UserDefaults")
        }
    }
    
    func fetchTransactions() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("🔑 Error: No authenticated user")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/get_transactions") else {
            print("🌐 Error: Invalid URL configuration")
            return
        }
        
        // Improved request configuration
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30 // Add a timeout
        
        let body: [String: Any] = ["userId": userId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // Use async/await for more modern networking
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("🌐 Error: Invalid HTTP response")
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    do {
                        let decodedResponse = try JSONDecoder().decode(PlaidTransactionsResponse.self, from: data)
                        await MainActor.run {
                            self.transactions = decodedResponse.transactions
                            self.categorizeTransactions()
                            self.hasFetchedTransactions = true
                            print("✅ Transactions loaded successfully: \(decodedResponse.transactions.count) transactions")
                        }
                    } catch {
                        print("❌ Decoding Error: \(error)")
                        await handleFetchError(error)
                    }
                case 404:
                    print("👤 User profile not found or needs update")
                    await handleFetchError(NSError(domain: "NetworkError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User profile not found"]))
                default:
                    print("❌ Unexpected HTTP Status: \(httpResponse.statusCode)")
                    await handleFetchError(NSError(domain: "NetworkError", code: httpResponse.statusCode, userInfo: nil))
                }
            } catch {
                print("🌐 Network Error: \(error.localizedDescription)")
                await handleFetchError(error)
            }
        }
    }

    // Add a method to handle fetch errors with potential retry
    private func handleFetchError(_ error: Error) async {
        await MainActor.run {
            self.error = error.localizedDescription
            
            // Optional: Implement retry logic
            if let retryCount = UserDefaults.standard.object(forKey: "transactionFetchRetryCount") as? Int, retryCount < 3 {
                UserDefaults.standard.set(retryCount + 1, forKey: "transactionFetchRetryCount")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.fetchTransactions()
                }
            } else {
                // Reset retry count or handle persistent failure
                UserDefaults.standard.removeObject(forKey: "transactionFetchRetryCount")
                // Optionally show an error to the user
            }
        }
    }
        // Optional: Add a retry mechanism
        func retryFetchTransactions(delay: TimeInterval = 3.0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.fetchTransactions()
            }
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
    
}
        
    
    
   
