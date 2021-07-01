//
//  Message.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import Foundation

struct Message {
    var key : String?
    var to: String?
    var text: String?
    var timestamp: Double?
    var msgKind: String?
}

struct RecentMessage {
    var to: String?
    var text: String?
    var timestamp: Double?
    var unreadCount: Int?
    var user: User?
}
