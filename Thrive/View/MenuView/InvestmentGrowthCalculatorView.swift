//
//  InvestmentGrowthCalculatorView.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-18.
//

import SwiftUI
import Charts

struct InvestmentGrowthCalculator: View {
    @State private var initialInvestment = ""
    @State private var monthlyContribution = ""
    @State private var annualReturn = ""
    @State private var investmentYears = ""
    @State private var growthData: [GrowthPoint] = []
    
    struct GrowthPoint: Identifiable {
        let id = UUID()
        let year: Int
        let totalValue: Double
        let principalValue: Double
        let interestValue: Double
    }
    
    var isValidInput: Bool {
        guard let initial = Double(initialInvestment),
              let monthly = Double(monthlyContribution),
              let returnRate = Double(annualReturn),
              let years = Int(investmentYears) else {
            return false
        }
        return initial >= 0 && monthly >= 0 && returnRate >= 0 && years > 0
    }
    
    var body: some View {
        NavigationView {
            List {
                inputSection
                if !growthData.isEmpty {
                    summarySection
                    chartSection
                }
            }
            .navigationTitle("Investment Calculator")
            .hideKeyboardWhenTappedAround()
        }
    }
    
    var inputSection: some View {
        Section(header: Text("Investment Details")) {
            TextField("Initial Investment", text: $initialInvestment)
                .keyboardType(.decimalPad)
            
            TextField("Monthly Contribution", text: $monthlyContribution)
                .keyboardType(.decimalPad)
            
            TextField("Annual Return %", text: $annualReturn)
                .keyboardType(.decimalPad)
            
            TextField("Investment Years", text: $investmentYears)
                .keyboardType(.numberPad)
            
            Text("Calculate Growth")
                .frame(maxWidth: .infinity)
                .padding()
                .background(isValidInput ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                .onTapGesture {
                    print("Tapped")
                    if isValidInput {
                        calculateGrowth()
                    }
                }
        }
    }

    
    var summarySection: some View {
        Section(header: Text("Summary")) {
            if let finalValues = growthData.last {
                HStack {
                    Text("Final Balance")
                    Spacer()
                    Text("$\(finalValues.totalValue, specifier: "%.2f")")
                        .fontWeight(.bold)
                }
                
                HStack {
                    Text("Total Contributions")
                    Spacer()
                    Text("$\(finalValues.principalValue, specifier: "%.2f")")
                }
                
                HStack {
                    Text("Total Interest Earned")
                    Spacer()
                    Text("$\(finalValues.interestValue, specifier: "%.2f")")
                        .foregroundColor(.green)
                }
            }
        }
    }
    
    var chartSection: some View {
        Section(header: Text("Growth Chart")) {
            if !growthData.isEmpty {
                Chart(growthData) { point in
                    AreaMark(
                        x: .value("Year", point.year),
                        y: .value("Interest", point.interestValue)
                    )
                    .foregroundStyle(.green.opacity(0.3))
                    
                    AreaMark(
                        x: .value("Year", point.year),
                        y: .value("Principal", point.principalValue)
                    )
                    .foregroundStyle(.blue.opacity(0.3))
                    
                    LineMark(
                        x: .value("Year", point.year),
                        y: .value("Total", point.totalValue)
                    )
                    .foregroundStyle(.purple)
                }
                .frame(height: 250)
                .padding()
            }
        }
    }
    
    func calculateGrowth() {
        print("starting calculation")
        guard let initial = Double(initialInvestment),
              let monthly = Double(monthlyContribution),
              let returnRate = Double(annualReturn),
              let years = Int(investmentYears) else {
            return
        }
        
        print("Values: Initial: \(initial), Monthly: \(monthly), Return: \(returnRate), Years: \(years)")
        
        var growthPoints: [GrowthPoint] = []
        let monthlyRate = returnRate / 100 / 12
        
        var totalValue = initial
        var totalContributions = initial
        
        for year in 0...years {
            if year > 0 {
                for _ in 1...12 {
                    totalValue *= (1 + monthlyRate)
                    totalValue += monthly
                    totalContributions += monthly
                }
            }
            
            let interestEarned = totalValue - totalContributions
            
            growthPoints.append(GrowthPoint(
                year: year,
                totalValue: totalValue,
                principalValue: totalContributions,
                interestValue: interestEarned
            ))
        }
        
        print("Growth Points Created: \(growthPoints.count)")  // Add this line
        
        withAnimation {
            self.growthData = growthPoints
        }
        print("Growth Data Updated: \(self.growthData.count)")  // And this line
    }
}

#Preview {
    InvestmentGrowthCalculator()
}
