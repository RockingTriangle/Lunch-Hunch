//
//  RestaurantController.swift
//  Lunch Hunch
//
//  Created by Jacob Schvaneveldt on 6/24/21.
//

import Foundation

class RestaurantController {
    
    static let shared = RestaurantController()
    
    
    var sections: [[Restaurant]] {[selectedList, restaurantList]}
    var restaurantList: [Restaurant] = []
    var selectedList: [Restaurant] = []
    
    private init() {}
    
    //MARK: - FUNCTIONS
    func createTest(name: String, isPicked: Bool) {
        let restaurant = Restaurant(name: name, isPicked: isPicked)
        restaurantList.append(restaurant)
    }
    
    func updateIsPicked(isPicked: Bool, restaurant: Restaurant) {
        if isPicked {
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
