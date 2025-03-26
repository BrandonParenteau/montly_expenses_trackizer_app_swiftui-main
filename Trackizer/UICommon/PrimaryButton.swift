//
//  PrimaryButton.swift
//  Trackizer
//
//  Created by CodeForAny on 11/07/23.
//

import SwiftUI

struct PrimaryButton: View {
    var title: String // Title passed as a parameter
    var onPressed: (() -> Void)? // Optional action closure
    
    var body: some View {
        Button {
            onPressed?() // Call the action when pressed
        } label: {
            ZStack {
                Image("primary_btn") // Customize the background image
                    .resizable()
                    .scaledToFill()
                    .padding(.horizontal, 20)
                    .frame(width: .screenWidth, height: 48) // Use screen width for responsiveness
                
                Text(title)
                    .font(.customfont(.semibold, fontSize: 14))
                    .padding(.horizontal, 20)
            }
        }
        .foregroundColor(.white)
        .shadow(color: .secondaryC.opacity(0.3), radius: 5, y: 3)
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a default closure for preview purposes
        PrimaryButton(title: "Sample Button", onPressed: {
            // No action in preview, just to avoid crashing
            print("Button Pressed!")
        })
        .previewLayout(.sizeThatFits) // Adjust for better previewing
    }
}
