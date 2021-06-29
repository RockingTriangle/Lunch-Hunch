//
//  Group.swift
//  Lunch Hunch
//
//  Created by Jaymond Richardson on 6/28/21.
//

import UIKit
import FirebaseAuth
import Firebase



private let RECENT_M_REF = FBAuthentication.shared.ref.child("recent_messages")
private let GROUP_M_REF = FBAuthentication.shared.ref.child("group_messages")
private let GROUP_D_REF = FBAuthentication.shared.ref.child("group_details")

let ref = Database.database().reference()

struct Groups {
    var groups: [String] //GroupID's
    
}

struct GroupDetail { //What attributes eachh group will have
    var membersID: [String] = [] //Remove member from here to remove from Group
    var groupName: String
    var groupID: String
    var messages: String
    
}

class GroupMessage { //Attributes each message can contain -> add poll?
    var senderID: String
    var timestamp: Date = Date()
    var text: String
    init (senderID: String, timestamp: Date = Date(), text: String) {
        self.senderID = senderID
        self.timestamp = timestamp
        self.text = text
    }
    
}

class RecentGroupMessage { // not sure if this is necessary. We might be able to just use observer function on GroupMessages
    var message = GroupMessage(senderID: String(), timestamp: Date(), text: String()) // if there are no messages set this to a default text?
    init(message: GroupMessage) {
    self.message = message
        
    }
}


//MARK: - Observer Function
/*
func observer(recentMessage: RecentGroupMessage) { //Does this go in the chats view??
    ref.child("users").child(id).child("recentMessages").observe(.childAdded) { (snapshot) -> Void in
        //Need to fill out
        //self.refreshData()?
    }
}
 */





