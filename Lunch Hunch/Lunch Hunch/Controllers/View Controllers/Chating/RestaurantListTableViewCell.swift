//
//  RestaurantListTableViewCell.swift
//  Lunch Hunch
//
//  Created by Jacob Schvaneveldt on 6/24/21.
//

import UIKit

protocol RestaurantListCellDelegate: AnyObject {
    func addedToPickedTapped(isPicked: Bool, restaurant: Restaurant, cell: RestaurantListTableViewCell)
}

class RestaurantListTableViewCell: UITableViewCell {
    
    //MARK: - OUTLETS
    @IBOutlet weak var restaurantNameTextLabel: UILabel!
    @IBOutlet weak var isPickedButton: UIButton!
    
    weak var delegate: RestaurantListCellDelegate?
    
    var restaurant: Restaurant?
    private var wasPicked: Bool = false
    
    //MARK: - ACTIONS
    @IBAction func isPickedButtonTapped(_ sender: Any) {
        guard let restaurant = restaurant else {return}
        
        wasPicked.toggle()
        delegate?.addedToPickedTapped(isPicked: wasPicked, restaurant: restaurant, cell: self)
    }
    
    //MARK: - FUNCTIONS
    func configure(restaurant: Restaurant) {
        self.restaurant = restaurant
        
        let image = wasPicked ? UIImage(systemName: "minus") : UIImage(systemName: "plus")
        restaurantNameTextLabel.text = restaurant.name
        isPickedButton.setImage(image, for: .normal)
        isPickedButton.tintColor = .cyan
    }
}
