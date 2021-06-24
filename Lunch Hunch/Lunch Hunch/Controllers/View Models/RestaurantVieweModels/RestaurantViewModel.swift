//
//  RestaurantViewModel.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/23/21.
//

import UIKit
import CoreLocation

class RestaurantViewModel {
    
    // Mark: - Static Instance
    static let shared = RestaurantViewModel()
    
    // Mark: - User location search options enum
    enum UserSearchChoice {
        case location
        case zipcode(String)
        
        var description: String {
            switch self {
            case .location:
                return "My Location"
            case .zipcode(let zipcode):
                return "Zipcode: \(zipcode)"
            }
        }
    }
    
    var searchLocation = "...searching"
    
    var userSearchChoice = UserSearchChoice.location {
        didSet {
            searchLocation = userSearchChoice.description
            print(searchLocation)
        }
    }
    
    var currentLocation: CLLocation? {
        didSet {
            searchLocation = userSearchChoice.description
        }
    }
    var zipcodeLocation: CLLocation?{
        didSet {
            searchLocation = userSearchChoice.description
        }
    }
    
    var radiusAmount: Int = 15
    
    var priceOptions: [Bool] = [true, false, false, false]
    
    // Mark: - Functions
    
    
} // End of class


