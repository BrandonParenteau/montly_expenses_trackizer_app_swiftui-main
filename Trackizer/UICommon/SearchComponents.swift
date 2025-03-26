//
//  SearchComponents.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-03-23.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray40)
            
            TextField("Search transactions", text: $text)
                .font(.customfont(.medium, fontSize: 14))
                .foregroundColor(.white)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
        .background(Color.gray60.opacity(0.2))
        .cornerRadius(12)
    }
}

struct CategoryChip: View {
    let category: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category)
                .font(.customfont(.medium, fontSize: 12))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.secondaryC : Color.gray60.opacity(0.2))
                .foregroundColor(isSelected ? .white : .gray40)
                .cornerRadius(20)
        }
    }
}


