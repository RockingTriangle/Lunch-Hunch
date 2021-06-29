//
//  UserCell.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit

class UserCell: UITableViewCell {
    
    
    var cellVM = UserViewModel() { didSet {
        userImage.KFloadImage(url: cellVM.imageURL!)
        nameLabel.text = cellVM.name
        messageLabel.text = cellVM.username
        }
    }
    
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    
    
    private func initView() {
        userImage.layer.cornerRadius = 21
    }
    
}
