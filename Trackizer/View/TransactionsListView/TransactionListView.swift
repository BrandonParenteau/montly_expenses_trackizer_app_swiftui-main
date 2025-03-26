//
//  TransactionListView.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-02-19.
//


import SwiftUI

struct TransactionListView: View {
    @StateObject var viewModel = TransactionViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading transactions...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let error = viewModel.error {
                VStack {
                    Text("Error loading transactions")
                        .foregroundColor(.red)
                    Text(error) // Display error string
                        .font(.caption)
                        .foregroundColor(.gray)
                    Button("Retry") {
                        viewModel.fetchTransactions()
                    }
                    .padding()
                }
            } else {
                List(viewModel.transactions) { transaction in
                    TransactionRowView(transaction: transaction)
                }
            }
        }
        .navigationTitle("Transactions")
        .onAppear {
            if viewModel.transactions.isEmpty && !viewModel.hasFetchedTransactions {
                viewModel.fetchTransactions()
            }
        }
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionListView()
        }
    }
}
