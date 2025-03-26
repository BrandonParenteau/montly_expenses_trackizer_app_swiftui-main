//
//  BudgetRow.swift
//  Trackizer
//
//  Created by CodeForAny on 13/07/23.
//

import SwiftUI

struct BudgetRow: View {
    @ObservedObject var budget: BudgetModel
    
    var body: some View {
        VStack(spacing: 8) {
            let _ = print("🔄 BudgetRow rendering for \(budget.name) with spent: \(budget.spend_amount)")
            HStack {
                ZStack {
                    Circle()
                        .fill(budget.color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: budget.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(budget.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(budget.name)
                            .font(.customfont(.medium, fontSize: 14))
                            .foregroundColor(.white)
                        
                        if let payPeriod = budget.payPeriod {
                            Text("(\(payPeriod))")
                                .font(.customfont(.regular, fontSize: 10))
                                .foregroundColor(.gray30)
                        }
                    }
                    
                    Text("$\(budget.spend_amount) of $\(budget.total_amount)")
                        .font(.customfont(.regular, fontSize: 12))
                        .foregroundColor(.gray30)
                }
                
                Spacer()
                
                Text("\(budget.percentageSpent)%")
                    .font(.customfont(.bold, fontSize: 16))
                    .foregroundColor(budget.percentageSpent > 90 ? .red : .white)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.2))
                        .frame(height: 3)
                    
                    Rectangle()
                        .foregroundColor(budget.color)
                        .frame(width: geometry.size.width * budget.perSpend, height: 3)
                }
                .cornerRadius(1.5)
            }
            .frame(height: 3)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .background(Color.grayC)
        .cornerRadius(16)
    }
}

struct BudgetRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Regular budget with partial spending
            BudgetRow(budget: BudgetModel(
                name: "Groceries",
                icon: "cart.fill",
                spend_amount: "75.00",
                total_amount: "100.00",
                color: .blue
            ))
            
            // Budget with high spending
            BudgetRow(budget: BudgetModel(
                name: "Entertainment",
                icon: "tv.fill",
                spend_amount: "95.00",
                total_amount: "100.00",
                color: .purple
            ))
            
            // Budget with no spending
            BudgetRow(budget: BudgetModel(
                name: "Savings",
                icon: "dollarsign.circle.fill",
                spend_amount: "0.00",
                total_amount: "500.00",
                color: .green
            ))
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.black)
    }
}
