//
//  AutoLoanCalculatorView.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-18.
//


import SwiftUI

enum PaymentFrequency: String, CaseIterable {
    case monthly = "Monthly"
    case biWeekly = "Bi-Weekly"
    case weekly = "Weekly"
}
struct AutoLoanCalculatorView: View {
    @State private var vehiclePrice = ""
    @State private var downPayment = ""
    @State private var downPaymentType = "$"
    @State private var interestRate = ""
    @State private var loanTerm = ""
    @State private var tradeInValue = ""
    @State private var salesTax = ""
    @State private var fees = ""
    @State private var paymentFrequency = PaymentFrequency.monthly
    @State private var monthlyPayment: Double?
    @State private var totalInterest: Double?
    @State private var totalCost: Double?
    
    let downPaymentOptions = ["$", "%"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Group {
                        TextField("Vehicle Price", text: $vehiclePrice)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        HStack {
                            TextField("Down Payment", text: $downPayment)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Picker("", selection: $downPaymentType) {
                                ForEach(downPaymentOptions, id: \.self) { option in
                                    Text(option)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 60)
                        }
                        .padding(.horizontal)
                        
                        TextField("Interest Rate (%)", text: $interestRate)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        TextField("Loan Term (months)", text: $loanTerm)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        TextField("Trade-in Value", text: $tradeInValue)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        TextField("Sales Tax (%)", text: $salesTax)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        TextField("Fees", text: $fees)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                    Picker("Payment Frequency", selection: $paymentFrequency) {
                        ForEach(PaymentFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    Button("Calculate") {
                        calculateLoan()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    if monthlyPayment != nil {
                        resultsSection
                    }
                }
                .padding(.vertical)
                .navigationTitle("Auto Loan Calculator")
                .navigationBarTitleDisplayMode(.inline)
            }
            .hideKeyboardWhenTappedAround()
        }
    }
    
    var resultsSection: some View {
        VStack(spacing: 12) {
            if let monthlyPayment = monthlyPayment {
                Group {
                    switch paymentFrequency {
                    case .monthly:
                        Text("Monthly Payment: $\(monthlyPayment, specifier: "%.2f")")
                    case .biWeekly:
                        Text("Bi-Weekly Payment: $\(monthlyPayment * 12 / 26, specifier: "%.2f")")
                    case .weekly:
                        Text("Weekly Payment: $\(monthlyPayment * 12 / 52, specifier: "%.2f")")
                    }
                }
                .font(.title2)
                .fontWeight(.bold)
            }
            
            if let totalInterest = totalInterest {
                Text("Total Interest: $\(totalInterest, specifier: "%.2f")")
                    .font(.headline)
            }
            
            if let totalCost = totalCost {
                Text("Total Cost: $\(totalCost, specifier: "%.2f")")
                    .font(.headline)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    func calculateLoan() {
        guard let price = Double(vehiclePrice),
              let rate = Double(interestRate),
              let term = Double(loanTerm),
              price > 0,
              rate > 0,
              term > 0 else {
            return
        }
        
        let tradeIn = Double(tradeInValue) ?? 0
        let taxRate = Double(salesTax) ?? 0
        let additionalFees = Double(fees) ?? 0
        
        var downPaymentAmount = 0.0
        if let dp = Double(downPayment) {
            if downPaymentType == "%" {
                downPaymentAmount = price * (dp / 100)
            } else {
                downPaymentAmount = dp
            }
        }
        
        let taxableAmount = max(price - tradeIn, 0)
        let taxAmount = taxableAmount * (taxRate / 100)
        
        let totalAmount = price + taxAmount + additionalFees - tradeIn - downPaymentAmount
        
        let monthlyRate = rate / 100 / 12
        let monthlyPaymentAmount = totalAmount * (monthlyRate * pow(1 + monthlyRate, term)) /
            (pow(1 + monthlyRate, term) - 1)
        
        let totalPayments = monthlyPaymentAmount * term
        let totalInterestPaid = totalPayments - totalAmount
        
        DispatchQueue.main.async {
            self.monthlyPayment = monthlyPaymentAmount
            self.totalInterest = totalInterestPaid
            self.totalCost = totalAmount + totalInterestPaid
        }
    }
}

struct AutoLoanCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        AutoLoanCalculatorView()
    }
}
