//
//  AddCategoryView.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-23.
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var categoryTitle: String = ""
    @State private var categoryAmount: String = ""
    @State private var selectedIcon: String = ""
    @State private var frequency: String = "Monthly"
    
    let onSave: (BudgetModel) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create a Budget Category")
                    .font(.title2)
                    .bold()
                
                TextField("Category Title", text: $categoryTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Amount", text: $categoryAmount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Picker("Frequency", selection: $frequency) {
                    Text("Monthly").tag("Monthly")
                    Text("Bi-Weekly").tag("Bi-Weekly")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                IconGridView(selectedIcon: $selectedIcon)
                    .padding(.horizontal)
                
                Button(action: addCategory) {
                    Text("Add Category")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedIcon.isEmpty || categoryTitle.isEmpty || categoryAmount.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(selectedIcon.isEmpty || categoryTitle.isEmpty || categoryAmount.isEmpty)
                .padding()
                
                Spacer()
            }
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
        }
    }
    
    func addCategory() {
        if let amount = Double(categoryAmount) {
            let newCategory = BudgetModel(dict: [
                "name": categoryTitle,
                "icon": selectedIcon,
                "spend_amount": "0.00",
                "total_amount": "\(amount)",
                "left_amount": "\(amount)",
                "color": Color.secondaryG
            ])
            onSave(newCategory)
            dismiss()
        }
    }
}
 


struct AddCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        AddCategoryView(onSave: { _ in })
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
