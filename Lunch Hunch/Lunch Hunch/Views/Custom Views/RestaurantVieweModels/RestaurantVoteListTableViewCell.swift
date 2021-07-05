//
//  RestaurantVoteListTableViewCell.swift
//  Lunch Hunch
//
//  Created by Jacob Schvaneveldt on 6/24/21.
//

import UIKit

protocol RestaurantListCellDelegate: AnyObject {
    func addedToPickedTapped(restaurant: Restaurant, cell: RestaurantVoteListTableViewCell)
}

class RestaurantVoteListTableViewCell: UITableViewCell {
    
    //MARK: - OUTLETS
    @IBOutlet weak var restaurantNameTextLabel: UILabel!
    @IBOutlet weak var isPickedButton: UIButton!
    
    weak var delegate: RestaurantListCellDelegate?
    
    var restaurant: Restaurant?
    var wasPicked: Bool?
    
    //MARK: - ACTIONS
    @IBAction func isPickedButtonTapped(_ sender: Any) {
        guard let restaurant = restaurant else {return}
        delegate?.addedToPickedTapped(restaurant: restaurant, cell: self)
    }
    
    //MARK: - FUNCTIONS
    func configure(restaurant: Restaurant) {
        self.restaurant = restaurant
        guard let wasPicked = wasPicked else { return }
        let image = wasPicked ? UIImage(systemName: "minus") : UIImage(systemName: "plus")
        restaurantNameTextLabel.text = restaurant.name
        isPickedButton.setImage(image, for: .normal)
        isPickedButton.tintColor = .cyan
    }
    
}
