//
//  Enums.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import Foundation

enum MessageType {
    case incoming
    case outgoing
}

enum MessageKind {
    case text
}

enum RequestType {
    case sent
    case recived
}

enum HatStatus: String {
    case open = "open"
    case poll = "poll"
    case rando = "rando"
    case vote = "vote"
    case winner = "winner"
}
