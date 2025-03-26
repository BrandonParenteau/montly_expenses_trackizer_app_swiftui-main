//
//  ArcShape.swift
//  Trackizer
//
//  Created by CodeForAny on 13/07/23.
//

import SwiftUI

struct ArcShape: Shape {
    
    var start: Double = 0
    var end: Double = 270
    var width: Double = 15
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let startVal = (start + 135)
        
        p.addArc(center: CGPoint(x: rect.width / 2, y: rect.height / 2), radius: rect.width / 2, startAngle: .degrees(startVal.truncatingRemainder(dividingBy: 360)), endAngle: .degrees((startVal + end).truncatingRemainder(dividingBy: 360)) , clockwise: false)
        
        return p.strokedPath(.init(lineWidth: width, lineCap:  .round))
    }
}

struct ArcShape180: Shape {
    var start: Double = 0
    var end: Double = 180
    var width: CGFloat = 15
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let radius = rect.width / 2
        
        // Convert degrees to radians
        let startAngle = Angle(degrees: start - 180)
        let endAngle = Angle(degrees: end - 180)
        
        // Create outer arc
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        // Create inner arc
        path.addArc(center: center, radius: radius - width, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        
        path.closeSubpath()
        return path
    }
}

