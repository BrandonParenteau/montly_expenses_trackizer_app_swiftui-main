//
//  DebtPayoffCalculatorView.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-18.
//

// Add this function right after the deleteDebt function in DebtPayoffCalculatorView

import SwiftUI

struct DebtItem: Identifiable {
    let id = UUID()
    var type: DebtType
    var balance: Double
    var apr: Double
    var minimumPayment: Double
    var extraPayment: Double
    
    enum DebtType: String, CaseIterable {
        case creditCard = "Credit Card"
        case personalLoan = "Personal Loan"
        case autoLoan = "Auto Loan"
        case mortgage = "Mortgage"
    }
}

// MARK: - Main View
struct DebtPayoffCalculatorView: View {
    @State private var debts: [DebtItem] = []
    @State private var showingAddDebt = false
    @State private var extraPaymentFrequency: PaymentFrequency = .monthly
    @State private var extraPaymentAmount = ""
    @State private var payoffMonths: Int = 0
    @State private var totalInterestSaved: Double = 0
    @State private var estimatedPayoffDate: Date?
    @State private var totalInterestWithoutExtra: Double = 0
    @State private var totalInterestWithExtra: Double = 0
    @State private var showingPayoffProjection = false  // New state to control projection visibility
    
    enum PaymentFrequency: String, CaseIterable {
        case monthly = "Monthly"
        case annual = "Annual"
    }
    
    var totalDebt: Double {
        debts.reduce(0) { $0 + $1.balance }
    }
    
    var totalMonthlyPayment: Double {
        debts.reduce(0) { $0 + $1.minimumPayment + $1.extraPayment }
    }
    
    var monthlyExtraPayment: Double {
        guard let amount = Double(extraPaymentAmount) else { return 0 }
        return extraPaymentFrequency == .monthly ? amount : amount / 12
    }
    
    var body: some View {
        NavigationView {
            List {
                summarySection
                debtListSection
                extraPaymentSection
                
                if !debts.isEmpty && showingPayoffProjection {
                    payoffProjectionSection
                }
            }
            .navigationTitle("Debt Payoff Planner")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Debt") {
                        showingAddDebt = true
                    }
                }
            }
            .sheet(isPresented: $showingAddDebt) {
                AddDebtView(debts: $debts)
            }
            .hideKeyboardWhenTappedAround()
        }
    }
    
    var summarySection: some View {
        Section(header: Text("Summary")) {
            HStack {
                Text("Total Debt")
                Spacer()
                Text("$\(totalDebt, specifier: "%.2f")")
                    .fontWeight(.bold)
            }
            
            HStack {
                Text("Total Monthly Payment")
                Spacer()
                Text("$\(totalMonthlyPayment, specifier: "%.2f")")
                    .fontWeight(.bold)
            }
        }
    }
    
    var debtListSection: some View {
        Section(header: Text("Your Debts")) {
            if debts.isEmpty {
                Text("Add your debts to get started")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(debts) { debt in
                    DebtRowView(debt: debt)
                }
                .onDelete(perform: deleteDebt)
            }
        }
    }
    
    var extraPaymentSection: some View {
        Section(header: Text("Extra Payment Options")) {
            VStack(spacing: 12) {
                Picker("Frequency", selection: $extraPaymentFrequency) {
                    ForEach(PaymentFrequency.allCases, id: \.self) { frequency in
                        Text(frequency.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                HStack {
                    TextField("Extra Payment Amount", text: $extraPaymentAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text(extraPaymentFrequency == .monthly ? "per month" : "per year")
                        .foregroundColor(.secondary)
                }
                
                Text("Calculate Payoff")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(debts.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .onTapGesture {
                        if !debts.isEmpty {
                            calculatePayoff()
                        }
                    }
            }
            .padding(.vertical, 8)
        }
    }

    
    var payoffProjectionSection: some View {
        Section(header: Text("Payoff Projection")) {
            VStack(spacing: 16) {
                if let payoffDate = estimatedPayoffDate {
                    HStack {
                        Text("Debt-free Date:")
                        Spacer()
                        Text(payoffDate, style: .date)
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                    }
                }
                
                HStack {
                    Text("Months to Debt-free:")
                    Spacer()
                    Text("\(payoffMonths)")
                        .foregroundColor(.green)
                        .fontWeight(.bold)
                }
                
                HStack {
                    Text("Interest Without Extra Payment:")
                    Spacer()
                    Text("$\(totalInterestWithoutExtra, specifier: "%.2f")")
                }
                
                HStack {
                    Text("Interest With Extra Payment:")
                    Spacer()
                    Text("$\(totalInterestWithExtra, specifier: "%.2f")")
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Total Interest Saved:")
                    Spacer()
                    Text("$\(totalInterestWithoutExtra - totalInterestWithExtra, specifier: "%.2f")")
                        .foregroundColor(.green)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    func deleteDebt(at offsets: IndexSet) {
        debts.remove(atOffsets: offsets)
        
        // Recalculate or hide projection if no debts left
        if debts.isEmpty {
            showingPayoffProjection = false
        } else if showingPayoffProjection {
            calculatePayoff()
        }
    }
    
    func calculatePayoff() {
        guard !debts.isEmpty else { return }
        
        let monthlyExtra = extraPaymentFrequency == .monthly ?
            (Double(extraPaymentAmount) ?? 0) :
            (Double(extraPaymentAmount) ?? 0) / 12
        
        var remainingDebts = debts.map { $0 } // Create a deep copy
        var months = 0
        var interestWithExtra = 0.0
        var interestWithoutExtra = 0.0
        var remainingBalance = true
        
        // Calculate with extra payments
        while remainingBalance && months < 360 {
            var totalRemainingBalance = 0.0
            let extraPerDebt = monthlyExtra / Double(remainingDebts.count)
            
            for i in remainingDebts.indices {
                let monthlyRate = remainingDebts[i].apr / 1200
                let interest = remainingDebts[i].balance * monthlyRate
                let payment = remainingDebts[i].minimumPayment + extraPerDebt
                
                interestWithExtra += interest
                remainingDebts[i].balance = max(0, remainingDebts[i].balance - payment + interest)
                totalRemainingBalance += remainingDebts[i].balance
            }
            
            months += 1
            remainingBalance = totalRemainingBalance > 0.01 // Account for floating point precision
        }
        
        // Calculate without extra payments
        var originalDebts = debts.map { $0 } // Create another deep copy
        var monthsWithoutExtra = 0
        remainingBalance = true
        
        while remainingBalance && monthsWithoutExtra < 360 {
            var totalRemainingBalance = 0.0
            
            for i in originalDebts.indices {
                let monthlyRate = originalDebts[i].apr / 1200
                let interest = originalDebts[i].balance * monthlyRate
                
                interestWithoutExtra += interest
                originalDebts[i].balance = max(0, originalDebts[i].balance - originalDebts[i].minimumPayment + interest)
                totalRemainingBalance += originalDebts[i].balance
            }
            
            monthsWithoutExtra += 1
            remainingBalance = totalRemainingBalance > 0.01 // Account for floating point precision
        }
        
        // Update UI
        withAnimation {
            payoffMonths = months
            estimatedPayoffDate = Calendar.current.date(byAdding: .month, value: months, to: Date())
            totalInterestWithExtra = interestWithExtra
            totalInterestWithoutExtra = interestWithoutExtra
            showingPayoffProjection = true
        }
    }
}

// MARK: - Supporting Views
struct DebtRowView: View {
    let debt: DebtItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(debt.type.rawValue)
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Balance")
                        .font(.caption)
                    Text("$\(debt.balance, specifier: "%.2f")")
                }
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("APR")
                        .font(.caption)
                    Text("\(debt.apr, specifier: "%.1f")%")
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Payment")
                        .font(.caption)
                    Text("$\(debt.minimumPayment, specifier: "%.2f")")
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddDebtView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var debts: [DebtItem]
    
    @State private var selectedType: DebtItem.DebtType = .creditCard
    @State private var balance = ""
    @State private var apr = ""
    @State private var minimumPayment = ""
    @State private var extraPayment = ""
    
    var isValidInput: Bool {
        guard let balanceValue = Double(balance),
              let aprValue = Double(apr),
              let minimumValue = Double(minimumPayment) else {
            return false
        }
        return balanceValue > 0 && aprValue > 0 && minimumValue > 0
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Debt Details")) {
                    Picker("Type", selection: $selectedType) {
                        ForEach(DebtItem.DebtType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField("Balance", text: $balance)
                        .keyboardType(.decimalPad)
                        .onChange(of: balance) { newValue in
                            balance = newValue.filter { "0123456789.".contains($0) }
                            if balance.filter({ $0 == "." }).count > 1 {
                                balance.removeLast()
                            }
                        }
                    
                    TextField("APR %", text: $apr)
                        .keyboardType(.decimalPad)
                        .onChange(of: apr) { newValue in
                            apr = newValue.filter { "0123456789.".contains($0) }
                            if apr.filter({ $0 == "." }).count > 1 {
                                apr.removeLast()
                            }
                        }
                    
                    TextField("Minimum Payment", text: $minimumPayment)
                        .keyboardType(.decimalPad)
                        .onChange(of: minimumPayment) { newValue in
                            minimumPayment = newValue.filter { "0123456789.".contains($0) }
                            if minimumPayment.filter({ $0 == "." }).count > 1 {
                                minimumPayment.removeLast()
                            }
                        }
                    
                    TextField("Extra Payment", text: $extraPayment)
                        .keyboardType(.decimalPad)
                        .onChange(of: extraPayment) { newValue in
                            extraPayment = newValue.filter { "0123456789.".contains($0) }
                            if extraPayment.filter({ $0 == "." }).count > 1 {
                                extraPayment.removeLast()
                            }
                        }
                }
            }
            .navigationTitle("Add New Debt")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveDebt()
                    }
                    .disabled(!isValidInput)
                }
            }
        }
    }
    
    func saveDebt() {
        guard let balanceValue = Double(balance),
              let aprValue = Double(apr),
              let minimumValue = Double(minimumPayment) else {
            return
        }
        
        let extraValue = Double(extraPayment) ?? 0
        
        let newDebt = DebtItem(
            type: selectedType,
            balance: balanceValue,
            apr: aprValue,
            minimumPayment: minimumValue,
            extraPayment: extraValue
        )
        
        withAnimation {
            debts.append(newDebt)
        }
        dismiss()
    }
}


// MARK: - Preview
struct DebtPayoffCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        DebtPayoffCalculatorView()
    }
}
