//
//  SubscriptionModel.swift
//  Trackizer
//
//  Created by CodeForAny on 13/07/23.
//

import SwiftUI

struct SubscriptionModel: Identifiable, Equatable{
    var id = UUID().uuidString
    var name: String = ""
    var icon: String = ""
    var price: String = ""
    var isSystemIcon: Bool = true
    var isManual: Bool = false
    var category: String = "General"
    
    init(dict: [String: Any]) {
        if let name = dict["name"] as? String {
            self.name = name
        }
        if let icon = dict["icon"] as? String {
            self.icon = icon
        }
        if let price = dict["price"] as? String {
            self.price = price
        }
        if let isSystemIcon = dict["isSystemIcon"] as? Bool {
            self.isSystemIcon = isSystemIcon
        }
        if let isManual = dict["isManual"] as? Bool {
            self.isManual = isManual
        }
        if let category = dict["category"] as? String {
            self.category = category
        }
    }


    
    static func == (lhs: SubscriptionModel, rhs: SubscriptionModel) -> Bool {
        return lhs.id == rhs.id
    }
}

