//
//  Restaurant.swift
//  Lunch Hunch
//
//  Created by Jacob Schvaneveldt on 6/24/21.
//

import Foundation

class Restaurant {
    
    let name: String
    var voteCount: Int
    let isPicked: Bool
    let uuid: String
    
    init(name: String, voteCount: Int = 0, isPicked: Bool, uuid: String = UUID().uuidString) {
        self.name = name
        self.voteCount = voteCount
        self.isPicked = isPicked
        self.uuid = uuid
    }
}//End of class

extension Restaurant: Equatable {
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}//End of extension
