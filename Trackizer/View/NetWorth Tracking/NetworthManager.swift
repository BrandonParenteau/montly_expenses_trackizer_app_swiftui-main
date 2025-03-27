//
//  NetworthManager.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-26.
//

import Foundation

struct Asset: Identifiable, Codable {
    let id: UUID
    var name: String
    var value: Double
    var category: AssetCategory
    
    enum AssetCategory: String, Codable, CaseIterable {
        case cash, investments, realEstate, retirement, cryptocurrency, other
    }
}

struct Liability: Identifiable, Codable {
    let id: UUID
    var name: String
    var amount: Double
    var category: LiabilityCategory
    
    enum LiabilityCategory: String, Codable, CaseIterable {
        case mortgage, studentLoans, creditCard, personalLoans, other
    }
}

struct NetWorthDataPoint: Identifiable, Decodable, Encodable {
    let id = UUID()
    let date: Date
    let value: Double
}

class NetWorthManager: ObservableObject {
    @Published var assets: [Asset] = []
    @Published var liabilities: [Liability] = []
    @Published var netWorthHistory: [NetWorthDataPoint] = []
    
    var totalAssets: Double {
        assets.reduce(0) { $0 + $1.value }
    }
    
    var totalLiabilities: Double {
        liabilities.reduce(0) { $0 + $1.amount }
    }
    
    var netWorth: Double {
        totalAssets - totalLiabilities
    }
    
    func addAsset(name: String, value: Double, category: Asset.AssetCategory) {
        let newAsset = Asset(id: UUID(), name: name, value: value, category: category)
        assets.append(newAsset)
        recordNetWorthSnapshots()
        saveData()
    }
    
    func addLiability(name: String, amount: Double, category: Liability.LiabilityCategory) {
        let newLiability = Liability(id: UUID(), name: name, amount: amount, category: category)
        liabilities.append(newLiability)
        recordNetWorthSnapshots()
        saveData()
    }
    
    func removeAsset(at offsets: IndexSet) {
        assets.remove(atOffsets: offsets)
        recordNetWorthSnapshots()
        saveData()
    }
    
    func removeLiability(at offsets: IndexSet) {
        liabilities.remove(atOffsets: offsets)
        recordNetWorthSnapshots()
        saveData()
    }
    
    func calculateNetWorth() -> Double {
        totalAssets - totalLiabilities
    }
    
    func recordNetWorthSnapshots() {
        let currentNetWorth = calculateNetWorth()
        let dataPoint = NetWorthDataPoint(date: Date(), value: currentNetWorth)
        
        // Always allow recording, even on the same day
        netWorthHistory.append(dataPoint)
        
        // Optional: Limit historical data to prevent unbounded growth
        if netWorthHistory.count > 365 {  // Keep only last year of data
            netWorthHistory.removeFirst(netWorthHistory.count - 365)
        }
        
        saveData()
    }
    
    func filterNetWorthData(for period: TimePeriod) -> [NetWorthDataPoint] {
        let now = Date()
        
        switch period {
        case .oneMonth:
            return netWorthHistory.filter {
                Calendar.current.dateComponents([.month], from: $0.date, to: now).month ?? 0 <= 1
            }
        case .threeMonths:
            return netWorthHistory.filter {
                Calendar.current.dateComponents([.month], from: $0.date, to: now).month ?? 0 <= 3
            }
        case .sixMonths:
            return netWorthHistory.filter {
                Calendar.current.dateComponents([.month], from: $0.date, to: now).month ?? 0 <= 6
            }
        case .oneYear:
            return netWorthHistory.filter {
                Calendar.current.dateComponents([.year], from: $0.date, to: now).year ?? 0 <= 1
            }
        case .allTime:
            return netWorthHistory
        }
    }
    
    func saveData() {
        let encoder = JSONEncoder()
        if let assetsData = try? encoder.encode(assets),
           let liabilitiesData = try? encoder.encode(liabilities),
           let netWorthHistoryData = try? encoder.encode(netWorthHistory) {
            UserDefaults.standard.set(assetsData, forKey: "savedAssets")
            UserDefaults.standard.set(liabilitiesData, forKey: "savedLiabilities")
            UserDefaults.standard.set(netWorthHistoryData, forKey: "savedNetWorthHistory")
        }
    }
    
    func loadData() {
        let decoder = JSONDecoder()
        if let assetsData = UserDefaults.standard.data(forKey: "savedAssets"),
           let liabilitiesData = UserDefaults.standard.data(forKey: "savedLiabilities"),
           let netWorthHistoryData = UserDefaults.standard.data(forKey: "savedNetWorthHistory") {
            assets = (try? decoder.decode([Asset].self, from: assetsData)) ?? []
            liabilities = (try? decoder.decode([Liability].self, from: liabilitiesData)) ?? []
            netWorthHistory = (try? decoder.decode([NetWorthDataPoint].self, from: netWorthHistoryData)) ?? []
        }
    }
    
    enum TimePeriod: String, CaseIterable {
        case oneMonth = "1M"
        case threeMonths = "3M"
        case sixMonths = "6M"
        case oneYear = "1Y"
        case allTime = "All"
    }
    
    init() {
        loadData()
    }
}

