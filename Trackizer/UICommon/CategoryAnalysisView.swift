//
//  CategoryAnalysisView.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-23.
//

import SwiftUI
import Charts


struct CategoryAnalysisView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    let showBankTransactions: Bool
    
    // Break down the transactions computation
    var transactions: [Transaction] {
        showBankTransactions ? viewModel.transactions : viewModel.manualTransactions
    }
    
    // Break down the category grouping
    var groupedTransactions: [String: [Transaction]] {
        Dictionary(grouping: transactions) { transaction in
            transaction.category?.first ?? "Other"
        }
    }
    
    // Break down the analysis calculation
    var categoryAnalysis: [(category: String, amount: Double)] {
        groupedTransactions.map { category, transactions in
            let total = transactions.reduce(0) { $0 + abs($1.amount) }
            return (category: category, amount: total)
        }.sorted { $0.amount > $1.amount }
    }
    
    // Calculate total separately
    var totalSpending: Double {
        categoryAnalysis.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Enhanced Spending Card
                    SpendingCard(total: totalSpending)
                        .shadow(color: .blue.opacity(0.2), radius: 10)
                    
                    // Stylish Chart Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Spending Distribution")
                            .font(.customfont(.bold, fontSize: 22))
                            .foregroundColor(.white)  // Changed to secondaryC
                        
                        PieChartView(data: categoryAnalysis)
                            .frame(height: 250)
                            .padding(.vertical)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray60.opacity(0.3))
                            .shadow(color: .black.opacity(0.2), radius: 8)
                    )
                    
                    // Styled Category Rows
                    VStack(spacing: 16) {
                        ForEach(categoryAnalysis, id: \.category) { item in
                            CategoryRow(
                                category: item.category,
                                amount: item.amount,
                                total: totalSpending
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .padding()
            }
            .background(Color.grayC)  // Changed to match your app's theme
            .navigationTitle("Spending Analysis")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarTitleTextColor(.white)
        }
    }
}

extension View {
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(color)]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(color)]
        return self
    }
}



struct SpendingCard: View {
    let total: Double
    
    var body: some View {
        VStack {
            Text("Total Spending")
                .font(.customfont(.medium, fontSize: 14))
                .foregroundColor(.white)
            Text("$\(String(format: "%.2f", total))")
                .font(.customfont(.bold, fontSize: 28))
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray60.opacity(0.2))
        .cornerRadius(12)
    }
}



struct CategoryDetailRow: View {
    let category: String
    let amount: Double
    let total: Double
    
    var percentage: Double {
        (amount / total) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(category)
                    .font(.customfont(.bold, fontSize: 16))
                Spacer()
                Text("$\(String(format: "%.2f", abs(amount)))")
                    .font(.customfont(.medium, fontSize: 16))
            }
            Text("\(Int(percentage))% of total spending")
                .font(.customfont(.regular, fontSize: 12))
                .foregroundColor(.gray40)
        }
        .padding()
        .background(Color.gray60.opacity(0.2))
        .cornerRadius(12)
    }
}

struct CategoryRow: View {
    let category: String
    let amount: Double
    let total: Double
    
    var percentage: Double {
        (amount / total) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(category)
                    .font(.customfont(.semibold, fontSize: 16))
                    .foregroundColor(.white)
                Spacer()
                Text("$\(String(format: "%.2f", amount))")
                    .font(.customfont(.medium, fontSize: 14))
                    .foregroundColor(.white)
            }
            
            HStack {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray70)
                            .frame(width: geometry.size.width)
                        
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * CGFloat(amount / total))
                    }
                }
                .frame(height: 8)
                .cornerRadius(4)
                
                Text("\(Int(percentage))%")
                    .font(.customfont(.medium, fontSize: 12))
                    .foregroundColor(.white)
                    .frame(width: 40)
            }
        }
        .padding()
        .background(Color.gray60.opacity(0.2))
        .cornerRadius(12)
    }
}
 

struct CategoryAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}






