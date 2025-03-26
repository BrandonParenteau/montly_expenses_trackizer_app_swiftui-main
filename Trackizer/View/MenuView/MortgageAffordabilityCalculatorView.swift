//
//  MortgageAffordabilityCalculatorView.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-19.
//

import SwiftUI

struct MortgageAffordabilityCalculator: View {
    @State private var annualIncome = ""
    @State private var monthlyDebts = ""
    @State private var downPayment = ""
    @State private var interestRate = ""
    @State private var loanTerm = "30"
    @State private var propertyTaxRate = ""
    @State private var homeInsurance = ""
    
    @State private var maxHomePrice: Double?
    @State private var monthlyPayment: Double?
    @State private var monthlyTaxes: Double?
    @State private var totalMonthlyPayment: Double?
    
    let loanTermOptions = ["15", "25", "30"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Income Section
                    Group {
                        TextField("Annual Income", text: $annualIncome)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Monthly Debts", text: $monthlyDebts)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Down Payment", text: $downPayment)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Loan Details
                    Group {
                        TextField("Interest Rate (%)", text: $interestRate)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Picker("Loan Term (Years)", selection: $loanTerm) {
                            ForEach(loanTermOptions, id: \.self) { term in
                                Text("\(term) years").tag(term)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        TextField("Property Tax Rate (%)", text: $propertyTaxRate)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Annual Home Insurance", text: $homeInsurance)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Button("Calculate Affordability") {
                        calculateAffordability()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    if maxHomePrice != nil {
                        resultsSection
                    }
                }
                .padding()
                .navigationTitle("Mortgage Affordability")
            }
            .hideKeyboardWhenTappedAround()
        }
    }
    
    var resultsSection: some View {
        VStack(spacing: 16) {
            Text("Maximum Home Price")
                .font(.headline)
            Text("$\(maxHomePrice!, specifier: "%.0f")")
                .font(.title)
                .fontWeight(.bold)
            
            Divider()
            
            VStack(spacing: 12) {
                HStack {
                    Text("Monthly Payment:")
                    Spacer()
                    Text("$\(monthlyPayment!, specifier: "%.2f")")
                }
                
                HStack {
                    Text("Property Taxes:")
                    Spacer()
                    Text("$\(monthlyTaxes!, specifier: "%.2f")")
                }
                
                HStack {
                    Text("Total Monthly Cost:")
                    Spacer()
                    Text("$\(totalMonthlyPayment!, specifier: "%.2f")")
                        .fontWeight(.bold)
                }
            }
            Spacer(minLength: 100)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
        
    }
    
    func calculateAffordability() {
        guard let income = Double(annualIncome),
              let debts = Double(monthlyDebts),
              let downPaymentAmount = Double(downPayment),
              let rate = Double(interestRate),
              let term = Double(loanTerm),
              let taxRate = Double(propertyTaxRate),
              let insurance = Double(homeInsurance) else {
            return
        }
        
        // Maximum monthly payment (28% of monthly income)
        let monthlyIncome = income / 12
        let maxMonthlyPayment = monthlyIncome * 0.28
        
        // Debt-to-income ratio check (36% including all debts)
        let maxTotalMonthlyDebt = monthlyIncome * 0.36
        let availableForMortgage = maxTotalMonthlyDebt - debts
        
        // Use the lower of the two payment limits
        let maxAllowedPayment = min(maxMonthlyPayment, availableForMortgage)
        
        // Monthly insurance and tax estimates
        let monthlyInsurance = insurance / 12
        
        // Calculate maximum loan amount using payment, rate, and term
        let monthlyRate = rate / 100 / 12
        let numberOfPayments = term * 12
        
        let maxLoanAmount = maxAllowedPayment * (pow(1 + monthlyRate, numberOfPayments) - 1) / (monthlyRate * pow(1 + monthlyRate, numberOfPayments))
        
        // Calculate maximum home price including down payment
        let maximumHomePrice = maxLoanAmount + downPaymentAmount
        
        // Calculate monthly taxes
        let monthlyTaxAmount = (maximumHomePrice * (taxRate / 100)) / 12
        
        // Calculate actual monthly mortgage payment
        let actualLoanAmount = maximumHomePrice - downPaymentAmount
        let monthlyMortgagePayment = actualLoanAmount * (monthlyRate * pow(1 + monthlyRate, numberOfPayments)) / (pow(1 + monthlyRate, numberOfPayments) - 1)
        
        // Total monthly payment including taxes and insurance
        let totalMonthly = monthlyMortgagePayment + monthlyTaxAmount + monthlyInsurance
        
        withAnimation {
            maxHomePrice = maximumHomePrice
            monthlyPayment = monthlyMortgagePayment
            monthlyTaxes = monthlyTaxAmount
            totalMonthlyPayment = totalMonthly
        }
    }
}

struct MortgageAffordabilityCalculator_Previews: PreviewProvider {
    static var previews: some View {
        MortgageAffordabilityCalculator()
    }
}
