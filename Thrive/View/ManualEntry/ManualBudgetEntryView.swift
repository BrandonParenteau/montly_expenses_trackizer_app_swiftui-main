//
//  ManualBudgetEntryView.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-22.
//
import SwiftUI

struct ManualBudgetEntryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TransactionViewModel
    
    @State private var amount = ""
    @State private var category = "General"
    @State private var date = Date()
    @State private var note = ""
    @State private var selectedIcon = "creditcard.fill"
    @State private var showingCustomCategorySheet = false
    @State private var newCategoryName = ""
    @State private var categories = ["Food", "Transport", "Shopping", "Bills", "Entertainment", "General"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Transaction Details")) {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                    Button("+ Add New Category") {
                        showingCustomCategorySheet = true
                        }
                    
                    .sheet(isPresented: $showingCustomCategorySheet) {
                        NavigationView {
                            Form {
                            TextField("New Category Name", text: $newCategoryName)
                                                    
                                    Button("Add Category") {
                                        if
                                            !newCategoryName.isEmpty {
                                                categories.append(newCategoryName)
                                                            category = newCategoryName
                                                            newCategoryName = ""
                                                            showingCustomCategorySheet = false
                                                        }
                                                    }
                                                }
                                                .navigationTitle("New Category")
                                                .navigationBarItems(trailing: Button("Cancel") {
                                                    showingCustomCategorySheet = false
                                                })
                                            }
                                        }

                    
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Note", text: $note)
                }
                
                Section(header: Text("Select Icon")) {
                    IconGridView(selectedIcon: $selectedIcon)
                }
                
                Button(action: saveTransaction) {
                    Text("Add Transaction")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    func saveTransaction() {
        guard let amountValue = Double(amount) else { return }
        
        viewModel.addManualTransaction(
            amount: amountValue,
            name: note.isEmpty ? category : note,
            category: category,
            selectedIcon: selectedIcon
        )
        
        clearForm()
        dismiss()
    }
    
    private func clearForm() {
        amount = ""
        category = "General"
        date = Date()
        note = ""
        selectedIcon = "creditcard.fill"
    }
}

#Preview {
    ManualBudgetEntryView(viewModel: TransactionViewModel())
}
