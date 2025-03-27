//
//  BudgetsView.swift
//  Trackizer
//
//  Created by CodeForAny on 13/07/23.
//

import SwiftUI
import UIKit

struct BudgetsView: View {
   @State private var listArr: [BudgetModel] = []
   @State private var showAddCategory = false
   @State private var newCategoryName = ""
   @State private var newCategoryAmount = ""
   @State private var selectedIcon = "house.fill"
   @State private var categoryPayPeriod = PayPeriod.monthly
   @State private var income: Double = 0
   @State private var refreshID = UUID()
    @State private var inputIncome: String = ""
    @State private var payPeriod: PayPeriod = .monthly
    @State private var showIncomeInput = false

       
       
       
       // Computed property to calculate total budgeted amount
       var totalBudgeted: Double {
           listArr.reduce(0.0) { $0 + (Double($1.total_amount) ?? 0) }
       }
       
       // Computed property to calculate remaining unallocated amount
       var remainingUnallocated: Double {
           max(0, income - totalBudgeted)
       }
       
       // Computed property to calculate budget progress percentage
       var budgetProgressPercentage: Double {
           income > 0 ? min((totalBudgeted / income) * 100, 100) : 0
       }
       
       // Computed property to calculate progress in degrees for arc
       var progressDegrees: Double {
           income > 0 ? min((totalBudgeted / income) * 180, 180) : 0
       }
       
       var listView: some View {
           ScrollView {
               LazyVStack(spacing: 15) {
                   ForEach(listArr) { budget in
                       BudgetRow(budget: budget)
                           .onTapGesture {
                               updateSpentAmount(for: budget)
                           }
                   }
               }
               .padding(.horizontal, 20)
               .padding(.vertical, 15)
           }
           .id(refreshID)
       }


       
       var body: some View {
           VStack {
               ScrollView {
                   VStack {
                       // Budget Arc Display
                       VStack {
                           ZStack(alignment: .bottom) {
                               ZStack {
                                   ArcShape180(start: 0, end: 180, width: 10)
                                       .foregroundColor(.gray.opacity(0.2))
                                   
                                   // Show progress based on budgeted vs income
                                   if income > 0 {
                                       ArcShape180(start: 0, end: progressDegrees, width: 14)
                                           .foregroundColor(.primary10)
                                           .shadow(color: Color.primary10.opacity(0.5), radius: 7)
                                   }
                               }
                               .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.width * 0.3)
                               
                               VStack {
                                   // Show total budgeted amount
                                   Text("$\(totalBudgeted, specifier: "%.2f")")
                                       .font(.customfont(.bold, fontSize: 24))
                                       .foregroundColor(.white)
                                   
                                   // Show total income amount
                                   if income > 0 {
                                       Text("of $\(income, specifier: "%.2f") \(payPeriod.rawValue) Income")
                                           .font(.customfont(.medium, fontSize: 12))
                                           .foregroundColor(.gray30)
                                       
                                       // Show remaining unallocated amount
                                       Text("Remaining: $\(remainingUnallocated, specifier: "%.2f")")
                                           .font(.customfont(.medium, fontSize: 10))
                                           .foregroundColor(remainingUnallocated > 0 ? .green : .red)
                                           .padding(.top, 4)
                                       
                                       // Show budget progress percentage
                                       Text("\(budgetProgressPercentage, specifier: "%.1f")% Budgeted")
                                           .font(.customfont(.medium, fontSize: 10))
                                           .foregroundColor(.gray30)
                                   }
                               }
                           }
                           .padding(.top, 64)
                           .padding(.bottom, 30)
                           
                           // Add spacer to prevent overlap
                           Spacer()
                               .frame(height: 20)
                           
                           // Set Income Button - moved with added spacing
                           PrimaryButton(title: income > 0 ? "Update Income" : "Set Income") {
                               showIncomeInput.toggle()
                           }
                           .padding(.horizontal, 20)
                       }
                       
                       // Add New Category Button
                       Button(action: {
                           showAddCategory.toggle()
                       }) {
                           HStack {
                               Text("Add new category")
                                   .font(.customfont(.semibold, fontSize: 14))
                               
                               Image(systemName: "plus.circle.fill")
                                   .resizable()
                                   .frame(width: 14, height: 14)
                           }
                       }
                       .foregroundColor(.gray30)
                       .frame(maxWidth: .infinity, minHeight: 64, maxHeight: 64)
                       .background(RoundedRectangle(cornerRadius: 16)
                           .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                           .foregroundColor(.gray30.opacity(0.5)))
                       .cornerRadius(16)
                       .padding(.horizontal, 20)
                       .padding(.vertical, 10)
                       
                       // List of Budget Categories
                       LazyVStack(spacing: 15) {
                           ForEach(listArr, id: \.id) { bObj in
                               BudgetRow(budget: bObj)
                                   .contextMenu {
                                       Button(action: {
                                           updateSpentAmount(for: bObj)
                                       }) {
                                           Label("Update Spent Amount", systemImage: "pencil")
                                       }
                                   }
                           }
                       }
                       .padding(.horizontal, 20)
                   }
               }
               .background(Color.grayC)
               .ignoresSafeArea(edges: .bottom)
           }
           .sheet(isPresented: $showIncomeInput) {
               incomeInputView
           }
           .sheet(isPresented: $showAddCategory) {
               addCategoryView
           }
       }
       
       // Income Input View
       var incomeInputView: some View {
           NavigationView {
               VStack(spacing: 20) {
                   Text("Set your income to help with budgeting")
                       .font(.headline)
                       .multilineTextAlignment(.center)
                       .padding(.top)
                   
                   TextField("Enter Income Amount", text: $inputIncome)
                       .keyboardType(.decimalPad)
                       .padding()
                       .background(Color(.systemGray6))
                       .cornerRadius(10)
                       .padding(.horizontal)
                   
                   Picker("Pay Period", selection: $payPeriod) {
                       ForEach(PayPeriod.allCases) { period in
                           Text(period.rawValue).tag(period)
                       }
                   }
                   .pickerStyle(SegmentedPickerStyle())
                   .padding(.horizontal)
                   
                   Spacer()
                   
                   Button(action: {
                       if let enteredIncome = Double(inputIncome) {
                           income = enteredIncome
                           showIncomeInput = false
                           inputIncome = ""
                       }
                   }) {
                       Text("Save")
                           .font(.headline)
                           .foregroundColor(.white)
                           .frame(maxWidth: .infinity)
                           .padding()
                           .background(Color.blue)
                           .cornerRadius(10)
                   }
                   .padding(.horizontal)
                   .disabled(inputIncome.isEmpty)
                   .opacity(inputIncome.isEmpty ? 0.5 : 1)
               }
               .padding(.bottom)
               .navigationTitle("Set Income")
               .navigationBarItems(trailing: Button("Cancel") {
                   showIncomeInput = false
                   inputIncome = ""
               })
           }
       }
       
       // Add Category View
       var addCategoryView: some View {
           NavigationView {
               ScrollView {
                   VStack(spacing: 20) {
                       TextField("Category Name", text: $newCategoryName)
                           .padding()
                           .background(Color(.systemGray6))
                           .cornerRadius(10)
                           .padding(.horizontal)
                       
                       TextField("Budget Amount", text: $newCategoryAmount)
                           .keyboardType(.decimalPad)
                           .padding()
                           .background(Color(.systemGray6))
                           .cornerRadius(10)
                           .padding(.horizontal)
                       
                       // Pay period selection for the category
                       Picker("Expense Frequency", selection: $categoryPayPeriod) {
                           ForEach(PayPeriod.allCases) { period in
                               Text(period.rawValue).tag(period)
                           }
                       }
                       .pickerStyle(SegmentedPickerStyle())
                       .padding(.horizontal)
                       
                       // Display remaining unallocated budget
                       if income > 0 {
                           VStack(alignment: .leading, spacing: 5) {
                               Text("Unallocated Budget: $\(remainingUnallocated, specifier: "%.2f")")
                                   .font(.subheadline)
                                   .foregroundColor(.blue)
                               
                               if let newAmount = Double(newCategoryAmount), newAmount > 0 {
                                   let afterAllocation = max(0, remainingUnallocated - newAmount)
                                   Text("Will remain: $\(afterAllocation, specifier: "%.2f")")
                                       .font(.caption)
                                       .foregroundColor(afterAllocation >= 0 ? .green : .red)
                               }
                           }
                           .padding(.horizontal)
                       }
                       
                       Text("Select an Icon")
                           .font(.headline)
                           .padding(.top)
                       
                       // Icon selection grid
                       LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 15) {
                           ForEach(availableIcons, id: \.self) { icon in
                               ZStack {
                                   Circle()
                                       .fill(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.clear)
                                       .frame(width: 60, height: 60)
                                   
                                   Image(systemName: icon)
                                       .font(.system(size: 24))
                                       .foregroundColor(selectedIcon == icon ? .blue : .primary)
                               }
                               .frame(width: 60, height: 60)
                               .onTapGesture {
                                   selectedIcon = icon
                               }
                           }
                       }
                       .padding()
                       
                       Spacer(minLength: 50)
                       
                       // Add button
                       Button(action: {
                           addNewCategory()
                           showAddCategory = false
                           resetInputFields()
                           // Dismiss keyboard
                           UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                       }) {
                           Text("Add Category")
                               .font(.headline)
                               .foregroundColor(.white)
                               .frame(maxWidth: .infinity)
                               .padding()
                               .background(Color.blue)
                               .cornerRadius(10)
                       }
                       .padding(.horizontal)
                       .disabled(newCategoryName.isEmpty || newCategoryAmount.isEmpty)
                       .opacity(newCategoryName.isEmpty || newCategoryAmount.isEmpty ? 0.5 : 1)
                       
                       // Extra space at bottom to ensure content isn't hidden by keyboard
                       Spacer(minLength: 100)
                   }
                   .padding(.bottom)
               }
               .navigationTitle("Add New Category")
               .navigationBarItems(trailing: Button("Cancel") {
                   showAddCategory = false
                   resetInputFields()
                   // Dismiss keyboard
                   UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
               })
               .hideKeyboardWhenTappedAround()
           }
       }

       
       
       func updateSpentAmount(for budget: BudgetModel) {
           print("⚡️ Alert opening for: \(budget.name)")
           
           let alert = UIAlertController(
               title: "Update Spent Amount",
               message: "Enter the amount spent for \(budget.name)",
               preferredStyle: .alert
           )
           
           alert.addTextField { textField in
               textField.keyboardType = .decimalPad
               textField.placeholder = "Enter amount"
               textField.text = budget.spend_amount
           }
           
           let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
               print("🎯 Update button tapped")
               if let textField = alert.textFields?.first {
                   print("📝 Text field value: \(textField.text ?? "nil")")
                   if let amountText = textField.text,
                      let newSpent = Double(amountText) {
                       print("💰 Converting to number: \(newSpent)")
                       
                       if let index = listArr.firstIndex(where: { $0.id == budget.id }) {
                           print("✅ Found budget at index: \(index)")
                           budget.updateSpentAmount(newSpent)
                       }
                   }
               }
           }
           
           alert.addAction(updateAction)
           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
           
           if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController {
               rootViewController.present(alert, animated: true)
           }
       }


       func addNewCategory() {
           guard let budgetAmount = Double(newCategoryAmount) else { return }
           
           // Generate a random color for the category
           let colors: [Color] = [.red, .blue, .green, .orange, .purple, .pink, .yellow]
           let randomColor = colors.randomElement() ?? .blue
           
           // Create a new budget model directly
           let newBudgetItem = BudgetModel(
               name: newCategoryName,
               icon: selectedIcon,
               spend_amount: "0.00",
               total_amount: String(format: "%.2f", budgetAmount),
               color: randomColor
           )
           
           // Set the pay period
           newBudgetItem.payPeriod = categoryPayPeriod.rawValue
           
           // Add to list and force UI update
           listArr.append(newBudgetItem)
           
           // Force UI update
           listArr = Array(listArr)
       }


       
       // Reset input fields after adding or canceling
       func resetInputFields() {
           newCategoryName = ""
           newCategoryAmount = ""
           selectedIcon = "cart.fill"
           categoryPayPeriod = .monthly
       }
   }
   // Available icons
   let availableIcons = [
       "cart.fill", "car.fill", "house.fill", "creditcard.fill",
       "fork.knife", "gamecontroller.fill", "gift.fill", "airplane",
       "heart.fill", "pills.fill", "tv.fill", "dog.fill"
   ]
   
   // PayPeriod enum
   enum PayPeriod: String, CaseIterable, Identifiable {
       case biweekly = "Bi-Weekly"
       case monthly = "Monthly"
       
       var id: String { self.rawValue }
   }

