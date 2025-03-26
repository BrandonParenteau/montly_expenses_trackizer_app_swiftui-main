//
//  BudgetRowModel.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-23.
//

import Foundation
import SwiftUI

class BudgetRowModel: Identifiable, ObservableObject {
    let id = UUID()
    @Published var name: String
    @Published var icon: String
    @Published var budgetAmount: Double
    @Published var spentAmount: Double
    @Published var color: Color
    @Published var payPeriod: String?
    
    init(from budget: BudgetModel) {
        self.name = budget.name
        self.icon = budget.icon
        // Use the model's computed properties for accurate values
        self.spentAmount = budget.spentAmount
        self.budgetAmount = budget.totalAmount
        self.color = budget.color
        self.payPeriod = budget.payPeriod
        
        // Add these prints to verify correct initialization
        print("BudgetRowModel initialized with:")
        print("- Spent Amount: \(self.spentAmount)")
        print("- Budget Amount: \(self.budgetAmount)")
        print("- Percentage: \(self.percentageSpent)%")
    }
    
    var percentageSpent: Int {
        return budgetAmount > 0 ? Int((spentAmount / budgetAmount) * 100) : 0
    }
    
    var progressValue: Double {
        return budgetAmount > 0 ? spentAmount / budgetAmount : 0
    }
}

