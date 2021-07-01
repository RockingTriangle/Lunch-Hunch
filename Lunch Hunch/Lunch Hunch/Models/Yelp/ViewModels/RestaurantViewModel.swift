//
//  RestaurantViewModel.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/23/21.
//

import UIKit
import CoreLocation

protocol RefreshData {
    func refreshData()
}

class RestaurantViewModel {
    
    static let shared = RestaurantViewModel()
    private let yelpService = YELPService()
    
    var businesses: [Business] = []
    var selectedBusiness: Set<Int> = []
    
    var delegate: RefreshData?
    
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
            if searchLocation.contains("My Location") {
                finalSearchLocation = currentLocation
            }
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
    
    func fetchBusinesses() {
        fetch(YELPEndpoint.shared)
    }
    
    private func fetch(_ endpoint: YELPEndpoint) {
        yelpService.fetch(Businesses.self, from: endpoint) { [weak self] result in
            switch result {
            case .success(let businesses):
                self?.businesses = businesses.businesses
                self?.delegate?.refreshData()
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n\(error)")
            }
        }
    }
    
} // End of class




