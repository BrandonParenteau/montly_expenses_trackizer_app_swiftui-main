//
//  TransactionRowView.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-02-22.
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: transaction.date) else { return transaction.date }
        
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(transaction.merchantName ?? transaction.name)
                        .font(.headline)
                    
                    if let category = transaction.category?.first {
                        Text(category.capitalized)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Text(String(format: "$%.2f", abs(transaction.amount)))
                    .font(.headline)
                    .foregroundColor(transaction.amount < 0 ? .red : .green)
            }
            
            Text(formattedDate)
                .font(.caption)
                .foregroundColor(.gray)
            
            if transaction.pending {
                Text("Pending")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        List {
            TransactionRowView(transaction: Transaction(
                id: "tx1",
                amount: -50.25,
                date: "2024-02-22",
                name: "Coffee Shop",
                merchantName: "Starbucks",
                category: ["Food and Drink", "Restaurants"],
                pending: false,
                accountId: "acc123",
                paymentChannel: "in_store",
                isManual: false,
                selectedIcon: "house.fill"
            ))
            
            TransactionRowView(transaction: Transaction(
                id: "tx2",
                amount: 2000.00,
                date: "2024-02-21",
                name: "Direct Deposit",
                merchantName: "COMPANY PAYROLL",
                category: ["Transfer", "Deposit"],
                pending: true,
                accountId: "acc123",
                paymentChannel: "online",
                isManual: false,
                selectedIcon: "dollarsign.fill"
            ))
            
            TransactionRowView(transaction: Transaction(
                id: "tx3",
                amount: -125.50,
                date: "2024-02-20",
                name: "Grocery Store",
                merchantName: "Whole Foods",
                category: ["Food and Drink", "Groceries"],
                pending: false,
                accountId: "acc123",
                paymentChannel: "in_store",
                isManual: false,
                selectedIcon: "phone.fill"
            ))
        }
    }
}
