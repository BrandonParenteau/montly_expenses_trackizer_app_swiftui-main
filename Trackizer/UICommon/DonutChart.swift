//
//  DonutChart.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-26.
//

import SwiftUI

struct DonutSegment: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var innerRadiusRatio: CGFloat = 0.6
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let innerRadius = radius * innerRadiusRatio
        
        var path = Path()
        
        // Outer arc
        path.addArc(center: center,
                   radius: radius,
                   startAngle: startAngle,
                   endAngle: endAngle,
                   clockwise: false)
        
        // Line to inner arc
        let endRadialPoint = CGPoint(
            x: center.x + radius * CGFloat(cos(endAngle.radians)),
            y: center.y + radius * CGFloat(sin(endAngle.radians))
        )
        let endInnerPoint = CGPoint(
            x: center.x + innerRadius * CGFloat(cos(endAngle.radians)),
            y: center.y + innerRadius * CGFloat(sin(endAngle.radians))
        )
        path.addLine(to: endInnerPoint)
        
        // Inner arc
        path.addArc(center: center,
                   radius: innerRadius,
                   startAngle: endAngle,
                   endAngle: startAngle,
                   clockwise: true)
        
        // Close path
        path.closeSubpath()
        
        return path
    }
}

struct DonutChart: View {
    var segments: [(value: Double, color: Color, label: String)]
    var innerRadiusRatio: CGFloat = 0.6
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<segments.count, id: \.self) { index in
                    let total = segments.reduce(0) { $0 + $1.value }
                    let startAngle = self.startAngle(at: index)
                    let endAngle = self.endAngle(at: index)
                    
                    DonutSegment(startAngle: startAngle,
                                endAngle: endAngle,
                                innerRadiusRatio: innerRadiusRatio)
                        .fill(segments[index].color)
                    
                    // Add label
                    if segments[index].value > 0 {
                        let midAngle = startAngle + (endAngle - startAngle) / 2
                        let labelRadius = min(geometry.size.width, geometry.size.height) / 2 *
                                         (1 + innerRadiusRatio) / 2
                        let x = geometry.size.width / 2 + labelRadius * CGFloat(cos(midAngle.radians))
                        let y = geometry.size.height / 2 + labelRadius * CGFloat(sin(midAngle.radians))
                        
                        Text(segments[index].label)
                            .font(.caption)
                            .foregroundColor(.white)
                            .position(x: x, y: y)
                    }
                }
            }
        }
    }
    
    private func startAngle(at index: Int) -> Angle {
        let total = segments.reduce(0) { $0 + $1.value }
        let proportions = segments.map { $0.value / total }
        let cumulativeProportion = proportions.prefix(index).reduce(0, +)
        return Angle(radians: 2 * .pi * cumulativeProportion - .pi / 2)
    }
    
    private func endAngle(at index: Int) -> Angle {
        let total = segments.reduce(0) { $0 + $1.value }
        let proportions = segments.map { $0.value / total }
        let cumulativeProportion = proportions.prefix(index + 1).reduce(0, +)
        return Angle(radians: 2 * .pi * cumulativeProportion - .pi / 2)
    }
}


struct DonutChart_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Liability Breakdown")
                .font(.headline)
                .padding(.bottom, 10)
            
            DonutChart(segments: [
                (value: 250000, color: .red, label: "$250k"),
                (value: 45000, color: .orange, label: "$45k"),
                (value: 12500, color: .yellow, label: "$12.5k"),
                (value: 8000, color: .purple, label: "$8k")
            ])
            .frame(height: 250)
            .padding()
            
            VStack(alignment: .leading, spacing: 8) {
                LegendItem(category: "Loans", color: .orange)
                LegendItem(category: "creditcards", color: .blue)
                LegendItem(category: "mortgage", color: .purple )
            }
            .padding()
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}


