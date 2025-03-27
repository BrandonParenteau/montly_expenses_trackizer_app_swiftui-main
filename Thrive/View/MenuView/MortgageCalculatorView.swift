//
//  MortgageCalculatorView.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-17.
//

import SwiftUI

struct AmortizationRow: Identifiable {
    let id = UUID()
    let year: Int
    let principalPaid: Double
    let interestPaid: Double
    let remainingBalance: Double
}

struct MortgageCalculatorView: View {
    @State private var principal = ""
    @State private var rate = ""
    @State private var years = ""
    @State private var downPayment = ""
    @State private var downPaymentType = "%"
    @State private var paymentFrequency = "Monthly"
    @State private var estimatedPayment: Double?
    @State private var amortizationSchedule: [AmortizationRow] = []
    @State private var payoffTime: String? = nil
    @State private var lumpSumAmount: String = ""
    @State private var lumpSumFrequency: String = "Annually"
    @State private var interestSavings: Double? = nil
    
    let paymentFrequencies = ["Monthly", "Bi-Weekly", "Accelerated Bi-Weekly"]
    let downPaymentOptions = ["%", "$"]
    let lumpSumFrequencies = ["Monthly", "Quarterly", "Annually"]
   
    func calculateMortgage() {
        print("Calculating Mortgage...")

        guard let p = Double(principal),
              let r = Double(rate),
              let y = Double(years),
              let d = Double(downPayment) else {
            print("Invalid input detected.")
            return
        }
        
        // Make lump sum optional - use 0 if empty
        let lumpSum = Double(lumpSumAmount) ?? 0

        let loanAmount: Double
        if downPaymentType == "%" {
            loanAmount = p - (p * d / 100)
        } else {
            loanAmount = p - d
        }

        let downPaymentPercentage = (p - loanAmount) / p
        var cmhcPremiumRate = 0.0

        if downPaymentPercentage < 0.20 {
            if downPaymentPercentage >= 0.15 {
                cmhcPremiumRate = 0.028
            } else if downPaymentPercentage >= 0.10 {
                cmhcPremiumRate = 0.031
            } else if downPaymentPercentage >= 0.05 {
                cmhcPremiumRate = 0.04
            }
        }

        let cmhcPremium = loanAmount * cmhcPremiumRate
        let totalLoan = loanAmount + cmhcPremium
        let annualRate = r / 100
        let monthlyRate = annualRate / 12
        let n = y * 12 // Number of months

        let monthlyPayment = (totalLoan * monthlyRate) / (1 - pow(1 + monthlyRate, -n))

        DispatchQueue.main.async {
            // Set payment based on frequency
            switch self.paymentFrequency {
            case "Bi-Weekly":
                self.estimatedPayment = (monthlyPayment * 12) / 26
            case "Accelerated Bi-Weekly":
                self.estimatedPayment = (monthlyPayment / 2)
            default:
                self.estimatedPayment = monthlyPayment
            }
            
            // Generate amortization schedule first
            self.generateAmortizationSchedule(
                loanAmount: totalLoan,
                monthlyRate: monthlyRate,
                monthlyPayment: monthlyPayment,
                years: Int(y),
                paymentFrequency: self.paymentFrequency,
                lumpSumAmount: lumpSum,
                lumpSumFrequency: self.lumpSumFrequency
            )
            
            // Calculate payoff time from amortization schedule
            if let lastRow = self.amortizationSchedule.last {
                if lastRow.remainingBalance > 0 {
                    // Not fully paid off within the term
                    self.payoffTime = "\(Int(y)) years"
                } else {
                    // Find the actual payoff year
                    let payoffYear = self.amortizationSchedule.count
                    
                    // Calculate partial year if needed
                    if payoffYear < Int(y) && payoffYear > 0 {
                        let prevRowBalance = payoffYear > 1 ?
                            self.amortizationSchedule[payoffYear - 2].remainingBalance :
                            totalLoan
                        
                        let currentRowBalance = self.amortizationSchedule[payoffYear - 1].remainingBalance
                        
                        // If last row has zero balance, find out how much of the year was needed
                        if currentRowBalance == 0 && prevRowBalance > 0 {
                            let yearlyPayment = self.amortizationSchedule[payoffYear - 1].principalPaid +
                                                self.amortizationSchedule[payoffYear - 1].interestPaid
                            
                            let monthlyPaymentAmount = yearlyPayment / 12
                            let monthsNeeded = ceil(prevRowBalance / monthlyPaymentAmount)
                            
                            if monthsNeeded < 12 {
                                self.payoffTime = "\(payoffYear - 1) years, \(Int(monthsNeeded)) months"
                            } else {
                                self.payoffTime = "\(payoffYear) years"
                            }
                        } else {
                            self.payoffTime = "\(payoffYear) years"
                        }
                    } else {
                        self.payoffTime = "\(payoffYear) years"
                    }
                }
            } else {
                // Default if no amortization schedule
                self.payoffTime = "\(Int(y)) years"
            }
            
            print("Estimated Payment: \(self.estimatedPayment ?? 0)")
            print("Payoff Time: \(self.payoffTime ?? "N/A")")
        }
    }
    
    func calculateTotalInterest(loanAmount: Double, monthlyRate: Double, monthlyPayment: Double, years: Int) -> Double {
        let totalPayments = Double(years * 12) * monthlyPayment
        return totalPayments - loanAmount
    }

    
    func generateAmortizationSchedule(loanAmount: Double, monthlyRate: Double, monthlyPayment: Double, years: Int, paymentFrequency: String, lumpSumAmount: Double, lumpSumFrequency: String) {
        var balance = loanAmount
        amortizationSchedule.removeAll()
        
        // Adjust payment and rate based on frequency
        var paymentAmount = monthlyPayment
        var periodRate = monthlyRate
        var paymentsPerYear = 12
        
        switch paymentFrequency {
        case "Bi-Weekly":
            paymentAmount = (monthlyPayment * 12) / 26
            periodRate = monthlyRate * 12 / 26
            paymentsPerYear = 26
        case "Accelerated Bi-Weekly":
            paymentAmount = monthlyPayment / 2
            periodRate = monthlyRate * 12 / 26
            paymentsPerYear = 26
        default:
            break
        }
        
        // Determine how many lump sum payments per year
        var lumpSumPaymentsPerYear = 0
        switch lumpSumFrequency {
        case "Monthly":
            lumpSumPaymentsPerYear = 12
        case "Quarterly":
            lumpSumPaymentsPerYear = 4
        case "Annually":
            lumpSumPaymentsPerYear = 1
        default:
            lumpSumPaymentsPerYear = 0
        }
        
        // Use the same logic for full years as in the payoff time calculation
        for year in 1...years {
            var principalPaidYearly = 0.0
            var interestPaidYearly = 0.0
            
            // For each payment period in the year
            for period in 1...paymentsPerYear {
                // Apply lump sum if applicable
                if lumpSumAmount > 0 {
                    let lumpSumPeriod = paymentsPerYear / lumpSumPaymentsPerYear
                    if lumpSumPeriod > 0 && period % lumpSumPeriod == 0 {
                        let lumpSumPayment = min(lumpSumAmount, balance)
                        balance -= lumpSumPayment
                        principalPaidYearly += lumpSumPayment
                    }
                }
                
                // Skip if balance is already zero
                if balance <= 0 {
                    break
                }
                
                // Calculate interest for this period
                let interestForPeriod = balance * periodRate
                interestPaidYearly += interestForPeriod
                
                // Calculate principal for this period
                let principalForPeriod = min(paymentAmount - interestForPeriod, balance)
                principalPaidYearly += principalForPeriod
                
                // Reduce balance
                balance -= principalForPeriod
                
                // If balance is paid off, break
                if balance <= 0.01 {
                    balance = 0
                    break
                }
            }
            
            // Add year to amortization schedule
            amortizationSchedule.append(AmortizationRow(
                year: year,
                principalPaid: principalPaidYearly,
                interestPaid: interestPaidYearly,
                remainingBalance: balance
            ))
            
            // If balance is paid off, break
            if balance <= 0.01 {
                break
            }
        }
        
        // Calculate interest savings
        let normalTotalInterest = monthlyPayment * Double(years * 12) - loanAmount
        let actualTotalInterest = amortizationSchedule.reduce(0.0) { $0 + $1.interestPaid }
        interestSavings = normalTotalInterest - actualTotalInterest
    }
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    TextField("Home Price", text: $principal)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
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
                    }
                    
                    TextField("Interest Rate (%)", text: $rate)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Loan Term (Years)", text: $years)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Payment Frequency", selection: $paymentFrequency) {
                        ForEach(paymentFrequencies, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    // Lump Sum Payment Section
                    VStack(alignment: .leading) {
                        Text("Lump Sum Payments")
                            .font(.headline)
                            .padding(.top, 5)
                        
                        HStack {
                            TextField("Amount", text: $lumpSumAmount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Picker("Frequency", selection: $lumpSumFrequency) {
                                ForEach(lumpSumFrequencies, id: \.self) { option in
                                    Text(option)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                    
                    Button("Calculate") {
                        calculateMortgage()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Spacer(minLength: 20)
                    
                    if let payment = estimatedPayment {
                        Text("Estimated \(paymentFrequency) Payment: $\(payment, specifier: "%.2f")")
                            .font(.title2)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                    }

                    if let payoffTime = payoffTime {
                        Text("Mortgage Paid Off In: \(payoffTime)")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.bottom)
                    }
                    
                    if let savings = interestSavings, savings > 0 {
                        Text("Interest Savings: $\(savings, specifier: "%.2f")")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.bottom)
                    }
                    
                    if !amortizationSchedule.isEmpty {
                        Text("Amortization Schedule")
                            .font(.headline)
                            .padding(.top)
                        
                        ScrollView {
                            VStack(alignment: .leading) {
                                ForEach(amortizationSchedule) { row in
                                    HStack {
                                        Text("Year \(row.year):")
                                            .bold()
                                        Spacer()
                                        Text("Principal Paid: $\(row.principalPaid, specifier: "%.2f")")
                                        Spacer()
                                        Text("Interest Paid: $\(row.interestPaid, specifier: "%.2f")")
                                        Spacer()
                                        Text("Remaining: $\(row.remainingBalance, specifier: "%.2f")")
                                    }
                                    .padding()
                                }
                            }
                        }
                        .frame(height: 300)
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
                .hideKeyboardWhenTappedAround()
            }
            .navigationTitle("Mortgage Calculator")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MortgageCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        MortgageCalculatorView()
    }
    
    
}
