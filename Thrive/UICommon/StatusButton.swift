//
//  StatusButton.swift
//  Trackizer
//
//  Created by CodeForAny on 13/07/23.
//

import SwiftUI

struct StatusButton: View {
    @State var title: String = "Title"
    @State var icon: String = "magnifyingglass"
    @State var color: Color = .secondaryC
    @State private var isPressed = false
    var onPressed: (()->())?
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                onPressed?()
            }
        } label: {
            ZStack(alignment: .top){
                VStack{
                    VStack(spacing: 12) {
                        Text(title)
                            .font(.customfont(.semibold, fontSize: 12))
                            .foregroundColor(.gray40)
                        
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(.top, 5)
                            .scaleEffect(isPressed ? 1.2 : 1.0)
                            .rotationEffect(isPressed ? .degrees(15) : .degrees(0))
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 68, maxHeight: 68)
                .background(Color.gray60.opacity(0.2))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray30.opacity(0.5), lineWidth: 1)
                }
                .cornerRadius(16)
                
                Rectangle()
                    .fill(color)
                    .frame(width: 60, height: 1, alignment: .center)
            }
        }
    }
}



struct StatusButton_Previews: PreviewProvider {
    static var previews: some View {
        StatusButton()
    }
}
