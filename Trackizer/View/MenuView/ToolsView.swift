//
//  MenuView.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-09.
//

import SwiftUI

struct ToolsView: View {
    let tools = [
        ("Credit Score", "chart.bar.fill", Color.green),
        ("Financial Calculators", "doc.text.fill", Color.indigo),
        ("Net Worth", "dollarsign.circle.fill", Color.orange),
        ("Investments", "chart.pie.fill", Color.red),
        ("Budgeting", "wallet.pass.fill", Color.yellow),
        ("Subscriptions", "rectangle.stack.fill", Color.cyan),
        ("Loans", "banknote.fill", Color.pink),
        ("Spending Analysis", "magnifyingglass.circle.fill", Color.teal),
        
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                   
                    HStack {
                        NavigationLink(destination: SettingsView()) {
                                              Image(systemName: "gearshape.fill")
                                                  .font(.title)
                                                  .foregroundColor(.white)
                                          }
                        
                        Spacer()
                        
                        Image(systemName: "person.crop.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            // Notifications Action
                        }) {
                            Image(systemName: "bell.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 40)
                    .padding()
                    
                    // 🔹 Centered "Tools" Title
                    Text("Tools")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    
                    // 🔹 Grid Layout (2 Columns) - using IconButton for each tool
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(tools, id: \.0) { tool in
                            NavigationLink(destination: getToolView(for: tool.0)) {
                                IconButton(
                                    iconName: tool.1,
                                    backgroundColor: tool.2,
                                    foregroundColor: .white,
                                    iconSize: 32,
                                    label: tool.0
                                )
                            }
                        }
                    }
                    .padding()
                    .background(Color.clear)
                    
                    Spacer()
                }
                .background(Color.grayC)
                .cornerRadius(20)
                .padding(.horizontal, 0)
            }
            .background(Color.grayC)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 65)
            }
            .padding(0)
        }
    }
    
    @ViewBuilder
    private func getToolView(for name: String) -> some View {
        switch name {
        /* case "Credit Score":
            CreditScoreView()
        case "Net Worth":
            NetWorthView()
        case "Investments":
            InvestmentsView()
        case "Budgeting":
            BudgetingView()
        case "Subscriptions":
            SubscriptionsView()
        case "Loans":
            LoansView()
        case "Spending Analysis":
            SpendingAnalysisView() */
        case "Financial Calculators":
            FinancialCalculatorsView()
        default:
            Text("Coming Soon")
        }
    }
}

struct ToolsView_Previews: PreviewProvider {
    static var previews: some View {
        ToolsView()
    }
}


