//
//  User.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit

struct User {
    var id: String?
    var email: String?
    var first: String?
    var last: String?
    var username: String?
    var country: String?
    var imageURL: String?
    var image: UIImage?
    var isOnline: Bool?
    var lastOnlineDate: Double?
}

struct currentUser {
    
    static private let defualts = UserDefaults.standard
    
    static var first      : String?  { return defualts.string(forKey: "first") }
    static var last       : String?  { return defualts.string(forKey: "last") }
    static var id         : String?  { return defualts.string(forKey: "id") }
    static var email      : String?  { return defualts.string(forKey: "email") }
    static var username   : String?  { return defualts.string(forKey: "id") }
    static var country    : String?  { return defualts.string(forKey: "country") }
    static var imageURL   : String?  { return defualts.string(forKey: "imageURL") }
    static var image      : UIImage? { return UIImage(data: defualts.data(forKey: "image") ?? Data()) ?? UIImage() }
    
}
