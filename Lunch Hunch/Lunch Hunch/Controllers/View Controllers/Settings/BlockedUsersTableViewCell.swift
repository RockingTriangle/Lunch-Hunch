//
//  BlockedUsersTableViewCell.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit

class BlockedUsersTableViewCell: UITableViewCell {

    // MARK: - Properties
    let vm     = BlockedViewModel()
    var userVM = UserViewModel() { didSet {
        profileImage.KFloadImage(url: userVM.imageURL!)
        nameLabel.text = userVM.name!
        usernameLabel.text = userVM.username!
        }}
    
    // MARK: - IBOutlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var unblockButton: UIButton!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = 21
    }
    
    // MARK: - IBActions
    @IBAction func unlockPressed(_ sender: UIButton) {
        vm.unblockUser(uid: userVM.uid!)
        sender.isHidden = true
    }
    
}
