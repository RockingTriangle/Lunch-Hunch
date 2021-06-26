//
//  RestaurantTableViewCell.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/25/21.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {
    
    // Mark: - IBOutlets
    @IBOutlet weak var userSelectionButton: UIButton!
    @IBOutlet weak var businessImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var numberOfRatingsLabel: UILabel!
    
    
    
    @IBAction func userSelectionButtonTapped(_ sender: Any) {
        
    }

} // End of class
