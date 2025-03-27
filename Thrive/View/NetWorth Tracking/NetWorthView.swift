//
//  NetWorthTracking.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-26.
//
import Foundation
import SwiftUI
import Charts

struct NetWorthView: View {
    @StateObject private var netWorthManager = NetWorthManager()
    @State private var selectedPeriod: NetWorthManager.TimePeriod = .oneYear
    @State private var showAddAssetSheet = false
    @State private var showAddLiabilitySheet = false
    @State private var isBreakdownExpanded = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Net Worth Summary
                    VStack {
                        Text("Total Net Worth")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("$\(netWorthManager.netWorth, specifier: "%.2f")")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(netWorthManager.netWorth >= 0 ? .green : .red)
                    }
                    .padding()
                    
                    // Chart
                    Chart {
                        ForEach(netWorthManager.filterNetWorthData(for: selectedPeriod)) { dataPoint in
                            LineMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Net Worth", dataPoint.value)
                            )
                            .interpolationMethod(.cardinal)
                        }
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .month)) { _ in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(format: .dateTime.month(.abbreviated))
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) {
                            AxisGridLine()
                            AxisValueLabel(format: Decimal.FormatStyle.number.precision(.fractionLength(0)))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Time Period Buttons
                    HStack {
                        ForEach(NetWorthManager.TimePeriod.allCases, id: \.self) { period in
                            Button(period.rawValue) {
                                selectedPeriod = period
                            }
                            .padding()
                            .background(selectedPeriod == period ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Asset & Liability Breakdown Dropdown
                    VStack {
                        HStack {
                            Text("Asset & Liability Breakdown")
                                .font(.headline)
                            Spacer()
                            Image(systemName: isBreakdownExpanded ? "chevron.up" : "chevron.down")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .onTapGesture {
                            withAnimation {
                                isBreakdownExpanded.toggle()
                            }
                        }
                        
                        if isBreakdownExpanded {
                            VStack(spacing: 20) {
                                // Assets Pie Chart
                                Text("Assets")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                let assetData = Asset.AssetCategory.allCases.compactMap { category -> (category: String, amount: Double)? in
                                    let categoryTotal = netWorthManager.assets
                                        .filter { $0.category == category }
                                        .reduce(0) { $0 + $1.value }
                                    
                                    if categoryTotal > 0 {
                                        return (category: category.rawValue, amount: categoryTotal)
                                    } else {
                                        return nil
                                    }
                                }
                                
                                if !assetData.isEmpty {
                                    PieChartView(data: assetData)
                                        .frame(height: 250)
                                } else {
                                    Text("No assets to display")
                                        .foregroundColor(.secondary)
                                        .padding()
                                }
                                
                                // Liabilities Pie Chart
                                Text("Liabilities")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 10)
                                
                                let liabilityData = Liability.LiabilityCategory.allCases.compactMap { category -> (category: String, amount: Double)? in
                                    let categoryTotal = netWorthManager.liabilities
                                        .filter { $0.category == category }
                                        .reduce(0) { $0 + $1.amount }
                                    
                                    if categoryTotal > 0 {
                                        return (category: category.rawValue, amount: categoryTotal)
                                    } else {
                                        return nil
                                    }
                                }
                                
                                if !liabilityData.isEmpty {
                                    PieChartView(data: liabilityData)
                                        .frame(height: 250)
                                } else {
                                    Text("No liabilities to display")
                                        .foregroundColor(.secondary)
                                        .padding()
                                }
                            }
                            .transition(.slide)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Assets and Liabilities List
                    VStack(spacing: 0) {
                        // Assets Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Assets")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.top, 10)
                            
                            if netWorthManager.assets.isEmpty {
                                Text("No assets added yet")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(netWorthManager.assets) { asset in
                                    HStack {
                                        Text(asset.name)
                                        Spacer()
                                        Text("$\(asset.value, specifier: "%.2f")")
                                            .foregroundColor(.green)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.05))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        
                        
                        // Liabilities Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Liabilities")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.top, 20)
                            
                            if netWorthManager.liabilities.isEmpty {
                                Text("No liabilities added yet")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(netWorthManager.liabilities) { liability in
                                    HStack {
                                        Text(liability.name)
                                        Spacer()
                                        Text("$\(liability.amount, specifier: "%.2f")")
                                            .foregroundColor(.red)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.05))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .background(Color.black)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 80)
                }
            }
            .navigationTitle("Net Worth")
            .navigationBarItems(
                leading: Button("Add Asset") { showAddAssetSheet = true },
                trailing: Button("Add Liability") { showAddLiabilitySheet = true }
            )
            .sheet(isPresented: $showAddAssetSheet) {
                AddAssetView(netWorthManager: netWorthManager)
            }
            .sheet(isPresented: $showAddLiabilitySheet) {
                AddLiabilityView(netWorthManager: netWorthManager)
            }
            .onAppear {
                // Record initial net worth
                netWorthManager.recordNetWorthSnapshots()
            }
        }
    }
}

    
    // Helper functions for category colors
    private func colorForAssetCategory(_ category: Asset.AssetCategory) -> Color {
        switch category {
        case .cash: return .green
        case .investments: return .blue
        case .realEstate: return .orange
        case .retirement: return .purple
        case .cryptocurrency: return .yellow
        case .other: return .gray
        }
    }
    
    private func colorForLiabilityCategory(_ category: Liability.LiabilityCategory) -> Color {
        switch category {
        case .mortgage: return .red
        case .studentLoans: return .blue
        case .creditCard: return .orange
        case .personalLoans: return .purple
        case .other: return .gray
        }
    }




struct AddAssetView: View {
    @ObservedObject var netWorthManager: NetWorthManager
    @State private var name = ""
    @State private var value = ""
    @State private var category = Asset.AssetCategory.cash
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Asset Name", text: $name)
                TextField("Value", text: $value)
                    .keyboardType(.decimalPad)
                
                Picker("Category", selection: $category) {
                    ForEach(Asset.AssetCategory.allCases, id: \.self) { category in
                        Text(category.rawValue.capitalized)
                    }
                }
            }
            .navigationTitle("Add Asset")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save") {
                    if let value = Double(value), !name.isEmpty {
                        netWorthManager.addAsset(name: name, value: value, category: category)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                    .disabled(name.isEmpty || value.isEmpty)
            )
        }
    }
}

struct AddLiabilityView: View {
    @ObservedObject var netWorthManager: NetWorthManager
    @State private var name = ""
    @State private var amount = ""
    @State private var category = Liability.LiabilityCategory.creditCard
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Liability Name", text: $name)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                
                Picker("Category", selection: $category) {
                    ForEach(Liability.LiabilityCategory.allCases, id: \.self) { category in
                        Text(category.rawValue.capitalized)
                    }
                }
            }
            .navigationTitle("Add Liability")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save") {
                    if let amount = Double(amount), !name.isEmpty {
                        netWorthManager.addLiability(name: name, amount: amount, category: category)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(name.isEmpty || amount.isEmpty)
            )
        }
    }
}


struct NetWorthView_Previews: PreviewProvider {
    static var previews: some View {
        NetWorthView()
    }
}

