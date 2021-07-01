//
//  AddFriendCell.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit

class AddFriendCell: UITableViewCell {

    // MARK: - Properties
    var user = User() {
        didSet {
            userImage.KFloadImage(url: user.imageURL!)
            nameLabel.text = user.first! + " " + user.last!
            usernameLabel.text = user.username!
            let status = FBNetworkRequest.shared.requestsSent.contains { (element) -> Bool in return user.id! == element }
            updateButtonUI(status: status)
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
        addButton.addTarget(self, action: #selector(addPressed), for: .touchUpInside)
    }

    func initView() {
        userImage.layer.cornerRadius = 21
        addButton.layer.cornerRadius = 4
    }
    
    @objc private func addPressed() {
        if addButton.titleLabel?.text == "Add Friend" {
            addButton.setTitle("Undo", for: .normal)
            addButton.backgroundColor = .darkGray
            FBNetworkRequest.shared.addFriend(uid: user.id!)
        } else {
            addButton.setTitle("Add Friend", for: .normal)
            addButton.backgroundColor = .systemBlue
            FBNetworkRequest.shared.cancelRequestFriend(uid: user.id!)
        }
    }

    private func updateButtonUI(status: Bool) {
        if !status {
            addButton.setTitle("Add Friend", for: .normal)
            addButton.backgroundColor = .systemBlue
        } else {
            addButton.setTitle("Undo", for: .normal)
            addButton.backgroundColor = .darkGray
        }
    }
    
}
