//
//  IconButton.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-09.
//

import SwiftUI

struct IconButton: View {
    var iconName: String
    var backgroundColor: Color
    var foregroundColor: Color
    var iconSize: CGFloat
    var label: String
    
    var body: some View {
        VStack {
            Image(systemName: iconName)
                .font(.system(size: iconSize))
                .foregroundColor(foregroundColor)
                .padding()
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(label)
                .foregroundColor(foregroundColor)
                .font(.headline)
        }
        .frame(maxWidth: 200, minHeight: 200)
        .background(Color.gray70) // Optional background to match design
        .cornerRadius(30)
    }
}

struct IconButton_Previews: PreviewProvider {
    static var previews: some View {
        IconButton(iconName: "briefcase", backgroundColor: .blue, foregroundColor: .white, iconSize: 40, label: "credit")
    }
}
