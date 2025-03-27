//
//  SearchTransactionsView.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-23.
//

import SwiftUI

struct SearchTransactionsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding()
                
                List(filteredTransactions) { transaction in
                    SubScriptionHomeRow(sObj: SubscriptionModel(dict: [
                        "name": transaction.merchantName ?? transaction.name,
                        "icon": transaction.selectedIcon,
                        "price": String(format: "%.2f", abs(transaction.amount)),
                        "isSystemIcon": true,
                        "isManual": false,
                        "category": transaction.category?.first ?? "General"
                    ]))
                }
            }
            .navigationTitle("Search Transactions")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
    
    var filteredTransactions: [Transaction] {
        if searchText.isEmpty {
            return viewModel.transactions
        }
        return viewModel.transactions.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            ($0.merchantName ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }
}


