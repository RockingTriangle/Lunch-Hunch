//
//  RestaurantController.swift
//  Lunch Hunch
//
//  Created by Jacob Schvaneveldt on 6/24/21.
//

import Foundation

class RestaurantController {
    
    // MARK: - Properties
    static let shared = RestaurantController()
    var sections: [[Restaurant]] {[selectedList, restaurantList]}
    var restaurantList: [Restaurant] = [] 
    var selectedList: [Restaurant] = []
    
    // MARK: - Initializer
    private init() {}
    
    //MARK: - FUNCTIONS
    func createTest(name: String, isPicked: Bool) {
        let restaurant = Restaurant(name: name, isPicked: isPicked)
        restaurantList.append(restaurant)
    }
    
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
    
}//End of class
