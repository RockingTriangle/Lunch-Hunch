//
//  RestaurantTableViewCell.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/25/21.
//

protocol CheckSelectionCountDelegate {
    func checkSelectionCount(_ index: Int)
}

protocol TooManySelectedDelegate {
    func showTooManySelectedMessage()
}

import UIKit

class RestaurantTableViewCell: UITableViewCell {
    
    private let service = YELPService()
    var results = RestaurantViewModel.shared
    
    // Mark: - IBOutlets
    @IBOutlet weak var userSelectionButton: UIButton!
    @IBOutlet weak var businessImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var numberOfRatingsLabel: UILabel!
    @IBOutlet weak var view: UIView!
    
    // Mark: - Properties
    var checkCountDelegate: CheckSelectionCountDelegate?
    var tooManyDelegate: TooManySelectedDelegate?
    var index: Int?
    var business: Business? {
        didSet {
            fetchimage()
            view.alpha = 0
        }
    }
    
    // Mark: - IBActions
    @IBAction func userSelectionButtonTapped(_ sender: UIButton) {
        guard let _ = business, let index = index else { return }
        if results.selectedBusiness.count < 2 {
            results.businesses[index].isSelected = results.businesses[index].isSelected ? false : true
            if results.selectedBusiness.contains(index) {
                results.selectedBusiness.remove(index)
                userSelectionButton.setBackgroundImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            } else {
                results.selectedBusiness.insert(index)
                userSelectionButton.setBackgroundImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            }
        } else if results.selectedBusiness.contains(index) {
            results.businesses[index].isSelected = false
            userSelectionButton.setBackgroundImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            results.selectedBusiness.remove(index)
        } else {
            tooManyDelegate?.showTooManySelectedMessage()
        }
        checkCountDelegate?.checkSelectionCount(index)
    }

    @IBAction func readReviewsButtonTapped(_ sender: Any) {
        guard let business = business, let url = URL(string: business.url) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func yelpLogoButtonTapped(_ sender: Any) {
        guard let url = URL(string: "https://www.yelp.com/") else { return }
        UIApplication.shared.open(url)
    }
    
    // Mark: - Functions
    func updateViews() {
        guard let business = business, let index = index else { return }
        userSelectionButton.layer.cornerRadius = userSelectionButton.frame.height / 2
        if results.selectedBusiness.contains(index) {
            userSelectionButton.setBackgroundImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            userSelectionButton.setBackgroundImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        }
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
                    self!.businessImageView.image = image
                    self!.updateViews()
                    UIView.animate(withDuration: 0.5) {
                        self!.view.alpha = 1
                    }
                }
            case .none:
                print("Error downloading image.")
            }
        }
    }
    
} // End of class
