//
//  IconGridView.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-22.
//

import SwiftUI

struct IconGridView: View {
    @Binding var selectedIcon: String
    
    let icons = [
        "house.fill",
        "car.fill",
        "cart.fill",
        "bag.fill",
        "fork.knife",
        "tv.fill",
        "gamecontroller.fill",
        "airplane",
        "tram.fill",
        "bus.fill",
        "medical.thermometer.fill",
        "gift.fill",
        "creditcard.fill",
        "dollarsign.circle.fill",
        "phone.fill",
        "wifi",
        "drop.fill",
        "bolt.fill",
        "film.fill",
        "book.fill",
        "hammer"
    ]
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 4)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(icons, id: \.self) { icon in
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 50, height: 50)
                    .background(selectedIcon == icon ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(selectedIcon == icon ? .white : .secondaryC)
                    .cornerRadius(10)
                    .onTapGesture {
                        selectedIcon = icon
                    }
            }
        }
        .padding()
    }
}

struct IconGridView_Previews: PreviewProvider {
    static var previews: some View {
        IconGridView(selectedIcon: .constant("house.fill"))
            .preferredColorScheme(.dark)
    }
}
