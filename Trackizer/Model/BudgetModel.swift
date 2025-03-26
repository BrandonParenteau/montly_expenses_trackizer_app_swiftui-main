//
//  BudgetModel.swift
//  Trackizer
//
//  Created by CodeForAny on 13/07/23.
//

import SwiftUI
import Combine

class BudgetModel: ObservableObject, Identifiable {
    let id = UUID()
    @Published var name: String = ""
    @Published var icon: String = ""
    @Published var spend_amount: String = ""
    @Published var total_amount: String = ""
    @Published var left_amount: String = ""
    @Published var color: Color = .secondaryC
    @Published var perSpend: Double = 0.0
    @Published var payPeriod: String? = nil
    
    init(dict: NSDictionary) {
        print("📝 BudgetModel initializing with dictionary:")
            print("- Name: \(dict.value(forKey: "name") as? String ?? "")")
            print("- Spend Amount: \(dict.value(forKey: "spend_amount") as? String ?? "")")
            print("- Total Amount: \(dict.value(forKey: "total_amount") as? String ?? "")")
        
        self.name = dict.value(forKey: "name") as? String ?? ""
        self.icon = dict.value(forKey: "icon") as? String ?? ""
        self.spend_amount = dict.value(forKey: "spend_amount") as? String ?? ""
        self.total_amount = dict.value(forKey: "total_amount") as? String ?? ""
        
        // For left_amount, either use the provided value or calculate it
        if let leftAmount = dict.value(forKey: "left_amount") as? String, !leftAmount.isEmpty {
            self.left_amount = leftAmount
        } else {
            // Calculate left amount
            let spent = Double(self.spend_amount) ?? 0.0
            let total = Double(self.total_amount) ?? 1.0
            let left = max(0, total - spent)
            self.left_amount = String(format: "%.2f", left)
        }
        
        // For color, we need to handle it differently since Color isn't directly supported in NSDictionary
        if let colorObject = dict.value(forKey: "color") {
            if let colorValue = colorObject as? Color {
                self.color = colorValue
            } else {
                // Default to secondary color if we can't extract the color
                self.color = .secondaryC
            }
        }
        
        self.payPeriod = dict.value(forKey: "payPeriod") as? String
        
        // Calculate percentage spent
        let spent = Double(self.spend_amount) ?? 0.0
        let total = Double(self.total_amount) ?? 1.0
        self.perSpend = total > 0 ? spent / total : 0.0
    }
    
    // Alternative initializer for when we want to specify a color directly
    init(name: String, icon: String, spend_amount: String, total_amount: String, color: Color) {
        self.name = name
        self.icon = icon
        self.spend_amount = spend_amount
        self.total_amount = total_amount
        
        // Calculate left amount
        let spent = Double(spend_amount) ?? 0.0
        let total = Double(total_amount) ?? 1.0
        let left = max(0, total - spent)
        self.left_amount = String(format: "%.2f", left)
        
        self.color = color
        
        // Calculate percentage spent
        self.perSpend = total > 0 ? spent / total : 0.0
    }
    
    // Helper computed properties
    var spentAmount: Double {
        return Double(spend_amount) ?? 0.0
    }
    
    var totalAmount: Double {
        return Double(total_amount) ?? 0.0
    }
    
    var percentageSpent: Int {
        return Int(perSpend * 100)
    }
    
    // Function to update spent amount
    func updateSpentAmount(_ newAmount: Double) {
        print("💰 Starting updateSpentAmount with: \(newAmount)")
        
        let totalAmount = Double(total_amount) ?? 0
        let clampedSpent = min(newAmount, totalAmount)
        
        self.spend_amount = String(format: "%.2f", clampedSpent)
        self.left_amount = String(format: "%.2f", max(0, totalAmount - clampedSpent))
        self.perSpend = totalAmount > 0 ? clampedSpent / totalAmount : 0.0
        
        print("✅ Updated values:")
        print("- Spent: \(self.spend_amount)")
        print("- Left: \(self.left_amount)")
        print("- Percentage: \(self.perSpend * 100)%")
    }

        
        // Add a helper method to create a fresh copy
        func copy() -> BudgetModel {
            let newModel = BudgetModel(
                name: self.name,
                icon: self.icon,
                spend_amount: self.spend_amount,
                total_amount: self.total_amount,
                color: self.color
            )
            newModel.payPeriod = self.payPeriod
            return newModel
        }
    }

