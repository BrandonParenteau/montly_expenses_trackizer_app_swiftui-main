//
//  FinancialCalculatorsView.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-17.
//

import SwiftUI

struct FinancialCalculatorsView: View {
    let calculators = [
        ("Mortgage Calculator", "house.fill", Color.blue),
        ("Auto Loan Calculator", "car.fill", Color.green),
        ("Debt Payoff Calculator", "creditcard.fill", Color.red),
        ("Investment Growth Calculator", "chart.bar.fill", Color.orange),
        ("Mortgage Affordability Calculator", "clock.fill", Color.purple)
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            Color.grayC.ignoresSafeArea()
                VStack {
                    Spacer()
                    Text("Financial Calculators")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(calculators, id: \ .0) { calculator in
                            NavigationLink(destination: getCalculatorView(for: calculator.0)) {
                                IconButton(
                                    iconName: calculator.1,
                                    backgroundColor: calculator.2,
                                    foregroundColor: .white,
                                    iconSize: 32,
                                    label: calculator.0
                                )
                            }
                        }
                    }
                    .padding()
                    Spacer()
                    
                }
                .background(Color.grayC)
                .ignoresSafeArea()
            }
        }
        
        @ViewBuilder
        private func getCalculatorView(for name: String) -> some View {
            switch name {
            case "Mortgage Calculator":
                MortgageCalculatorView()
                case "Auto Loan Calculator":
                AutoLoanCalculatorView()
                 case "Debt Payoff Calculator":
                 DebtPayoffCalculatorView()
                case "Investment Growth Calculator":
                InvestmentGrowthCalculator()
                 case "Mortgage Affordability Calculator":
                 MortgageAffordabilityCalculator()
            default:
                Text("Coming Soon")
            }
        }
    }

struct FinancialCalculatorsView_Previews: PreviewProvider {
    static var previews: some View {
        FinancialCalculatorsView()
    }
}

