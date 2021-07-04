//
//  RestaurantVoteModel.swift
//  Lunch Hunch
//
//  Created by Jacob Schvaneveldt on 6/24/21.
//

import Foundation

class RestaurantVoteModel {
    
    // MARK: - Properties
    static let shared = RestaurantVoteModel()
    var sections: [[Restaurant]] {[selectedList, restaurantList]}
    var restaurantList: [Restaurant] = [] 
    var selectedList: [Restaurant] = []
    
    // MARK: - Initializer
    private init() {}
    
    //MARK: - FUNCTIONS
    func updateIsPicked(isPicked: Bool, restaurant: Restaurant) {
        if isPicked && selectedList.count < 3 {
            if let index = restaurantList.firstIndex(of: restaurant) {
                restaurantList.remove(at: index)
                selectedList.append(restaurant)
            }
        } else {
            if let index = selectedList.firstIndex(of: restaurant) {
                selectedList.remove(at: index)
                restaurantList.append(restaurant)
            }
        }
    }
    
    func createRestaurants(with restaurants: [String]) {
        for restaurant in restaurants {
            restaurantList.append(Restaurant(name: restaurant))
        }
        let tempList = restaurantList.sorted(by: { $0.name < $1.name })
        restaurantList = []
        for restaurant in tempList {
            if !restaurantList.contains(restaurant) {
                restaurantList.append(restaurant)
            }
        }
    }
    
}//End of class
