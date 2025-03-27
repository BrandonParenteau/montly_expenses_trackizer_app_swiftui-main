//
//  HomeView.swift
//  Trackizer
//
//  Created by CodeForAny on 12/07/23.
//

import SwiftUI
import Foundation

struct HomeView: View {
    @State var showBankTransactions: Bool = true
    @State private var showManualEntrySheet = false
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var showSearchView = false
    @State private var showCategoryView = false
    @EnvironmentObject var appController: AppController
    @StateObject private var transactionViewModel = TransactionViewModel()
    
    let categoryIcons = [
        "FOOD_AND_DRINK": "fork.knife",
        "TRANSPORTATION": "car.fill",
        "SHOPPING": "cart.fill",
        "PAYMENT": "dollarsign.circle.fill",
        "ENTERTAINMENT": "tv.fill",
        "GENERAL": "creditcard.fill",
        "TRANSFER": "arrow.left.arrow.right",
        "TRAVEL": "airplane",
        "RENT": "house.fill",
        "MEDICAL": "cross.fill",
        "SUBSCRIPTION": "repeat.circle.fill"
    ]
    
    var totalMonthlySpend: String {
        let transactions = showBankTransactions ?
            transactionViewModel.transactions : transactionViewModel.manualTransactions
        
        let total = transactions
            .filter { $0.amount < 0 }
            .reduce(0) { $0 + abs($1.amount) }
        return String(format: "$%.2f", total)
    }
    
    var highestAmount: String {
        let transactions = showBankTransactions ?
            transactionViewModel.transactions : transactionViewModel.manualTransactions
            
        let amount = transactions.max(by: { $0.amount < $1.amount })?.amount ?? 0.0
        return String(format: "$%.2f", abs(amount))
    }
    
    var lowestAmount: String {
        let transactions = showBankTransactions ?
            transactionViewModel.transactions : transactionViewModel.manualTransactions
            
        let amount = transactions.min(by: { $0.amount < $1.amount })?.amount ?? 0.0
        return String(format: "$%.2f", abs(amount))
    }
    
    func getCategoryIcon(for category: String) -> String {
        return categoryIcons[category] ?? "creditcard.fill"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                ZStack(alignment: .center) {
                    Rectangle()
                        .foregroundColor(.gray70.opacity(0.5))
                        .frame(width: .screenWidth, height: .widthPer(per: 1.1))
                        .cornerRadius(25)
                    
                    Image("home_bg")
                        .resizable()
                        .scaledToFit()
                    
                    ZStack {
                        ArcShape()
                            .foregroundColor(.gray.opacity(0.2))
                        
                        ArcShape(start: 0, end: 230)
                            .foregroundColor(.secondaryC)
                            .shadow(color: .secondaryC.opacity(0.5), radius: 7)
                    }
                    .frame(width: .widthPer(per: 0.72), height: .widthPer(per: 0.72))
                    .padding(.bottom, 18)
                    
                    VStack(spacing: .widthPer(per: 0.07)) {
                        Image("FortifyLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: .widthPer(per: 0.25))
                        
                        Text(totalMonthlySpend)
                            .font(.customfont(.bold, fontSize: 40))
                            .foregroundColor(.white)
                        
                        Text("This month bills")
                            .font(.customfont(.semibold, fontSize: 12))
                            .foregroundColor(.gray40)
                        
                        NavigationLink(destination: BudgetsView()) {
                            Text("See your budget")
                                .font(.customfont(.semibold, fontSize: 12))
                        }
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.gray60.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray70, lineWidth: 1)
                        }
                        .cornerRadius(16)
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            StatusButton(
                                title: "Search Transactions",
                                icon: "magnifyingglass",
                                color: .secondaryC
                            ) {
                                showSearchView = true
                            }
                            
                            StatusButton(
                                title: "Spending Analysis",
                                icon: "chart.pie.fill",
                                color: .primary10
                            ) {
                                showCategoryView = true
                            }
                            
                            StatusButton(
                                title: "Money Left Over",
                                icon: "dollarsign.circle.fill",
                                color: .secondaryG
                            ) { }
                        }

                    }
                    .padding()
                    // Add these modifiers to your StatusButtons' sheets
                    .sheet(isPresented: $showSearchView) {
                        SearchTransactionsView(viewModel: transactionViewModel)
                            .transition(.move(edge: .bottom))
                            .animation(.spring(), value: showSearchView)
                    }
                    .sheet(isPresented: $showCategoryView) {
                        CategoryAnalysisView(viewModel: transactionViewModel, showBankTransactions: showBankTransactions)
                            .transition(.move(edge: .bottom))
                            .animation(.spring(), value: showCategoryView)
                    }

                }
                .frame(width: .screenWidth, height: .widthPer(per: 1.1))
                
                // Transaction Type Selector - Renamed to Bank/Manual
                HStack {
                    SegmentButton(title: "Bank Connected", isActive: showBankTransactions) {
                        showBankTransactions = true
                    }
                    SegmentButton(title: "Manual Budget", isActive: !showBankTransactions) {
                        showBankTransactions = false
                    }
                }
                .padding(8)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                .background(Color.black)
                .cornerRadius(15)
                .padding()
                
                

                
                // Add Manual Transaction Button (only show for manual transactions)
                if !showBankTransactions {
                    Button(action: { showManualEntrySheet.toggle() }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Add Manual Transaction")
                                .font(.customfont(.semibold, fontSize: 14))
                        }
                        .foregroundColor(.white)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray60.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray70, lineWidth: 1)
                        }
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $showManualEntrySheet) {
                        ManualBudgetEntryView(viewModel: transactionViewModel)
                    }
                }
                
                // Transaction List
                LazyVStack(spacing: 15) {
                    if showBankTransactions {
                        if transactionViewModel.transactions.isEmpty {
                            Text("No bank transactions available")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(transactionViewModel.transactions, id: \.id) { transaction in
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
                    } else {
                        if transactionViewModel.manualTransactions.isEmpty {
                            Text("No manual transactions added yet")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(transactionViewModel.manualTransactions, id: \.id) { transaction in
                                SubScriptionHomeRow(sObj: SubscriptionModel(dict: [
                                    "name": transaction.name,
                                    "icon": transaction.selectedIcon,
                                    "price": String(format: "%.2f", abs(transaction.amount)),
                                    "isSystemIcon": true,
                                    "isManual": true,
                                    "category": transaction.category?.first ?? "General"
                                ]))
                            }
                        }
                    }
                    Spacer(minLength:100)
                }
                .padding(.horizontal, 20)

            }
            .background(Color.grayC)
            .ignoresSafeArea()
            .onAppear {
                print("Fetching Transactions....")
                transactionViewModel.fetchTransactions()
                print("API transactions: \(transactionViewModel.transactions.count)")
                print("Manual transactions: \(transactionViewModel.manualTransactions.count)")
            }
        }
    }
}

struct CategoryChartView: View {
    @ObservedObject var viewModel: TransactionViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Spending by Category")
                .font(.customfont(.bold, fontSize: 18))
                .foregroundColor(.white)
                .padding(.bottom, 5)
            
            ForEach(viewModel.categoryTotals.sorted(by: { $0.value > $1.value }), id: \.key) { category, amount in
                CategoryRow(
                    category: category,
                    amount: amount,
                    total: viewModel.categoryTotals.values.reduce(0, +)
                )
            }
        }
        .padding()
        .background(Color.gray60.opacity(0.2))
        .cornerRadius(12)
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}
