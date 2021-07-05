//
//  RestaurantSearchModel.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/23/21.
//

import UIKit
import CoreLocation
import Firebase

protocol RefreshData: AnyObject {
    func refreshData()
}

class RestaurantSearchModel {
    
    static let shared = RestaurantSearchModel()
    private let yelpService = YELPService()
    
    var businesses: [Business]      = []
    var selectedBusiness: Set<Int>  = []
    var businessesToSave: [String]  = []
    var theirBusinesses: [String]   = []
    weak var delegate: RefreshData?
    
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
    
    private func getSelectedBusinesses() {
        guard let firstBusiness = selectedBusiness.first else { return }
        businessesToSave.append(businesses[firstBusiness].name)
        selectedBusiness.removeFirst()
        guard let secondBusiness = selectedBusiness.first else { return }
        businessesToSave.append(businesses[secondBusiness].name)
        selectedBusiness.removeAll()
    }
    
    func addRestaurants(friendID: String, isRandom: Bool) {
        getSelectedBusinesses()
        FBDatabase.shared.FBAddRestaurants(friendID: friendID, businesses: businessesToSave)
        FBDatabase.shared.FBDetectRestaurants(friendsID: friendID) { (restaurants) in
            guard let restaurants = restaurants else { return }
            self.theirBusinesses = restaurants
        }
        if !isRandom {
            FBDatabase.shared.FBStartChoosing(friendID: friendID, status: .vote)
        } else {
            FBDatabase.shared.FBStartChoosing(friendID: friendID, status: .winner)
        }
    }
    
    func savePoints(friendID: String, restaurants: [Restaurant]) {
        FBDatabase.shared.FBAddPoints(friendID: friendID, restaurants: restaurants)
    }
    
} // End of class




