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
    var photoURL: String?
    var latitude: Double?
    var longitude: Double?
    var videoURL:  String?
    var voiceURL:  String?
    var voiceSec:  Double?
}

struct RecentMessage {
    var to: String?
    var text: String?
    var timestamp: Double?
    var unreadCount: Int?
    var user: User?
}
