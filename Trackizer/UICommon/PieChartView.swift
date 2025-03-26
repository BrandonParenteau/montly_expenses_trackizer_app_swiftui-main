//
//  PieChartView.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-23.
//

import SwiftUI

struct PieChartView: View {
    let data: [(category: String, amount: Double)]
    @State private var selectedSlice: String?
    
    var body: some View {
        VStack {
            ZStack {
                // Pie Slices
                PieSlicesView(data: data, selectedSlice: $selectedSlice)
                
                // Center Circle
                CenterCircleView(data: data, selectedSlice: selectedSlice)
            }
            
            // Legend
            ChartLegendView(data: data)
        }
    }
}

struct PieSlicesView: View {
    let data: [(category: String, amount: Double)]
    @Binding var selectedSlice: String?
    
    var body: some View {
        ForEach(data.indices, id: \.self) { index in
            PieSliceView(
                data: data,
                index: index,
                selectedSlice: $selectedSlice
            )
        }
    }
}

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let category: String
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle - .degrees(90), endAngle: endAngle - .degrees(90), clockwise: false)
        path.closeSubpath()
        return path
    }
}

extension PieSliceView {
    func startAngle(for index: Int) -> Angle {
        let prior = data[..<index].reduce(0) { $0 + $1.amount }
        return .degrees(prior / totalAmount * 360)
    }
    
    func endAngle(for index: Int) -> Angle {
        let current = data[..<(index + 1)].reduce(0) { $0 + $1.amount }
        return .degrees(current / totalAmount * 360)
    }
    
    private var totalAmount: Double {
        data.reduce(0) { $0 + $1.amount }
    }
}


struct PieSliceView: View {
    let data: [(category: String, amount: Double)]
    let index: Int
    @Binding var selectedSlice: String?
    
    var body: some View {
        PieSlice(
            startAngle: startAngle(for: index),
            endAngle: endAngle(for: index),
            category: data[index].category
        )
        .fill(sliceGradient(for: index))
        .scaleEffect(data[index].category == selectedSlice ? 1.1 : 1.0)
        .animation(.spring(), value: selectedSlice)
        .onTapGesture {
            selectedSlice = selectedSlice == data[index].category ? nil : data[index].category
        }
    }
    
    private func sliceGradient(for index: Int) -> LinearGradient {
        let colors: [(Color, Color)] = [
            (.secondaryC, .purple),
            (.blue, .cyan),
            (.orange, .yellow),
            (.green, .mint),
            (.pink, .red)
        ]
        let (color1, color2) = colors[index % colors.count]
        return LinearGradient(colors: [color1, color2], startPoint: .top, endPoint: .bottom)
    }
}

struct CenterCircleView: View {
    let data: [(category: String, amount: Double)]
    let selectedSlice: String?
    
    var body: some View {
        Circle()
            .fill(Color.gray60.opacity(0.3))
            .frame(width: 120, height: 120)
            .overlay(
                Group {
                    if let category = selectedSlice,
                       let amount = data.first(where: { $0.category == category })?.amount {
                        VStack(spacing: 8) {
                            Text(category)
                                .font(.customfont(.bold, fontSize: 16))
                                .foregroundColor(.white)
                            Text("$\(String(format: "%.2f", amount))")
                                .font(.customfont(.bold, fontSize: 22))
                                .foregroundColor(.secondaryC)
                        }
                    }
                }
            )
            .shadow(color: .black.opacity(0.2), radius: 5)
    }
}

struct ChartLegendView: View {
    let data: [(category: String, amount: Double)]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(data.indices, id: \.self) { index in
                    LegendItem(
                        category: data[index].category,
                        color: legendColor(for: index)
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func legendColor(for index: Int) -> Color {
        let colors: [Color] = [.secondaryC, .blue, .orange, .green, .pink]
        return colors[index % colors.count]
    }
}

struct LegendItem: View {
    let category: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(category)
                .font(.customfont(.medium, fontSize: 12))
                .foregroundColor(.white)
        }
    }
}

 




