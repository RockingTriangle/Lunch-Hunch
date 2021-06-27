//
//  RestaurantTableViewCell.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/25/21.
//

protocol SelectBusinessDelegate {
    func updateBusinessSelection(_ business: inout Business)
}

import UIKit

class RestaurantTableViewCell: UITableViewCell {
    
    private let service = YELPService()
    
    // Mark: - IBOutlets
    @IBOutlet weak var userSelectionButton: UIButton!
    @IBOutlet weak var businessImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var numberOfRatingsLabel: UILabel!
    
    // Mark: - Properties
    var delegate: SelectBusinessDelegate?
    var business: Business? {
        didSet {
            fetchimage()
        }
    }
    
    // Mark: - IBActions
    @IBAction func userSelectionButtonTapped(_ sender: Any) {
        guard let _ = business else { return }
        business!.isSelected.toggle()
        delegate?.updateBusinessSelection(&business!)
    }

    @IBAction func readReviewsButtonTapped(_ sender: Any) {
        print("go to yelp business page")
        //Todo: - add link to Yelp business page
        //Todo: - add link to Buisness model
    }
    
    // Mark: - Functions
    func updateViews() {
        guard let business = business else { return }
        userSelectionButton.layer.cornerRadius = userSelectionButton.frame.height / 2
        userSelectionButton.setBackgroundImage(business.isSelected ?
                                                UIImage(systemName: "checkmark.circle.fill") :
                                                UIImage(systemName: "checkmark.circle"), for: .normal)
        nameLabel.text = business.name
        addressLabel.text = "\(business.location.displayAddress.first ?? "No address")\n\(business.location.displayAddress.last ?? "")"
        phoneLabel.text = business.displayPhone
        priceLabel.text = business.price
        // Todo: - add other ratings
        switch business.rating {
        case 1..<2:
            ratingImageView.image = UIImage(named: "regular_1")
        case 2..<3:
            ratingImageView.image = UIImage(named: "regular_2")
        case 3..<4:
            ratingImageView.image = UIImage(named: "regular_3")
        case 4..<5:
            ratingImageView.image = UIImage(named: "regular_4")
        case 5:
            ratingImageView.image = UIImage(named: "regular_5")
        default:
            ratingImageView.image = UIImage(named: "regular_0")
        }
        // ToDo: - add review count to business model
        numberOfRatingsLabel.text = "123 reviews"
    }
    
    func fetchimage() {
        guard let url = business?.imageURL else { return }
        service.downloadImage(fromUrlString: url) { [weak self] result in
            switch result {
            case .some(let image):
                DispatchQueue.main.async {
                    self?.businessImageView.image = image
                    self?.updateViews()
                }
            case .none:
                print("Error downloading image.")
            }
        }
    }
    
} // End of class
