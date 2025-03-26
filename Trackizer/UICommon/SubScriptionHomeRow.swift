//
//  SubScriptionHomeRow.swift
//  Trackizer
//
//  Created by CodeForAny on 13/07/23.
//

import SwiftUI

struct SubScriptionHomeRow: View {
    @State var sObj: SubscriptionModel
    
    let categoryColors: [String: Color] = [
        "Food": .orange,
        "Transport": .blue,
        "Shopping": .green,
        "Bills": .red,
        "Entertainment": .purple,
        "General": .secondaryC,
        "FOOD_AND_DRINK": .orange,
        "TRANSPORTATION": .blue,
        "SHOPPING": .green,
        "PAYMENT": .red,
        "ENTERTAINMENT": .purple,
        "GENERAL": .secondaryC,
        "TRANSFER": .yellow,
        "TRAVEL": .blue,
        "RENT": .pink,
        "MEDICAL": .red,
        "SUBSCRIPTION": .purple
    ]
    
    var iconColor: Color {
        categoryColors[sObj.category] ?? .white
    }
    
    var body: some View {
        HStack {
            Group {
                if sObj.isSystemIcon {
                    Image(systemName: sObj.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .padding(5)
                        .foregroundStyle(iconColor)
                        .background(iconColor.opacity(0.2))
                        .clipShape(Circle())
                } else {
                    Image(sObj.icon)
                        .resizable()
                        .frame(width: 40, height: 40)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(sObj.name)
                    .font(.customfont(.semibold, fontSize: 14))
                    .foregroundColor(.white)
                
                if sObj.isManual {
                    Text("Manual Entry")
                        .font(.customfont(.regular, fontSize: 11))
                        .foregroundColor(.gray40)
                } else {
                    Text(sObj.category)
                        .font(.customfont(.regular, fontSize: 11))
                        .foregroundColor(.gray40)
                }
            }
            
            Spacer()
            
            Text("$\(sObj.price)")
                .font(.customfont(.semibold, fontSize: 14))
                .foregroundColor(.white)
        }
        .padding(15)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 64, maxHeight: 64)
        .background(Color.gray60.opacity(0.2))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray70, lineWidth: 1)
        }
        .cornerRadius(12)
    }
}

struct SubScriptionHomeRow_Previews: PreviewProvider {
    static var previews: some View {
        SubScriptionHomeRow(sObj: SubscriptionModel(dict: [
            "name": "Netflix",
            "icon": "play.tv.fill",
            "price": "14.99",
            "isSystemIcon": true,
            "category": "Entertainment"
        ]))
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.black)
    }
}
