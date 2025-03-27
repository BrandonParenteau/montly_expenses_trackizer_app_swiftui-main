//
//  TokenModels.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-02-16.
//

import Foundation

struct PlaidLinkTokenResponse: Codable {
    let link_token: String
}
struct PlaidExchangeTokenResponse: Codable {
    let access_token: String
    let item_id: String
    let request_id: String
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case access_token
        case item_id
        case request_id
        case status
    }
}
