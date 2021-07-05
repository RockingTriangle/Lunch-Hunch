//
//  Business.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/25/21.
//

import Foundation

struct Businesses: Codable, Hashable {
    let businesses: [Business]
}

struct Business: Codable, Hashable {
    let id: String
    let name: String
    let imageURL: String
    let url: String
    let rating: Double
    let reviewCount: Int
    let coordinates: Coordinates
    let price: String?
    let location: Location
    let displayPhone: String
    
    var isSelected: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, name, url, rating, coordinates, price, location
        case imageURL = "image_url"
        case reviewCount = "review_count"
        case displayPhone = "display_phone"
    }
}

struct Coordinates: Codable, Hashable {
    let latitude: Double
    let longitude: Double
}

struct Location: Codable, Hashable {
    let displayAddress: [String]
    
    enum CodingKeys: String, CodingKey {
        case displayAddress = "display_address"
    }
}
