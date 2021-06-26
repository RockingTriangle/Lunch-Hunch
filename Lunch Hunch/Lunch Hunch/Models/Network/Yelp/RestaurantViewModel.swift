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
    
    enum UserSearchChoice {
        case location
        case city(String)
        case zipcode(String)
        case custom
        
        var description: String {
            switch self {
            case .location:
                return "My Location"
            case .city(let city):
                return "City: \(city)"
            case .zipcode(let zipcode):
                return "Zipcode: \(zipcode)"
            case .custom:
                return "Custom Location"
            }
        }
    }
    
    var searchLocation = "...searching"
    
    var finalSearchLocation: CLLocation?
    
    var userSearchChoice = UserSearchChoice.location {
        didSet {
            searchLocation = userSearchChoice.description
        }
    }
    
    var currentLocation: CLLocation? {
        didSet {
            searchLocation = userSearchChoice.description
            finalSearchLocation = currentLocation
        }
    }
    
    var cityLocation: CLLocation? {
        didSet {
            searchLocation = userSearchChoice.description
            finalSearchLocation = cityLocation
        }
    }
    
    var zipcodeLocation: CLLocation?{
        didSet {
            searchLocation = userSearchChoice.description
            finalSearchLocation = zipcodeLocation
        }
    }
    
    var customLocation: CLLocation? {
        didSet {
            searchLocation = userSearchChoice.description
            finalSearchLocation = customLocation
        }
    }
        
    var radiusAmount: Int = 15
    
    var foodTypes: [Bool] = [true, false, false, false, false,
                             false, false, false, false, false,
                             false, false, false, false, false,
                             false, false, false, false, false]
    
    var priceOptions: [Bool] = [true, false, false, false]
    var priceValues: [Int] = [1, 2, 3, 4]
    
} // End of class




