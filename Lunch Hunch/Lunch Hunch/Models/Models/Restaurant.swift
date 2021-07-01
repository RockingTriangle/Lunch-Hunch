//
//  Restaurant.swift
//  Lunch Hunch
//
//  Created by Jacob Schvaneveldt on 6/24/21.
//

import Foundation

struct Restaurant {
    
    var name: String
    var voteCount: Int
    let isPicked: Bool
    let uuid: String
    
    init(name: String, voteCount: Int = 0, isPicked: Bool = false, uuid: String = UUID().uuidString) {
        self.name = name
        self.voteCount = voteCount
        self.isPicked = isPicked
        self.uuid = uuid
    }
    
    init(data: Data) {
        self.init(name: String(data: data, encoding: .utf8) ?? "nope")
    }
}

extension Restaurant: Equatable {
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

extension Restaurant: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

class RestaurantModel { //JWR
    let name: String
    let address: String
    init(name: String, address: String) {
        self.name = name
        self.address = address
    }
}

