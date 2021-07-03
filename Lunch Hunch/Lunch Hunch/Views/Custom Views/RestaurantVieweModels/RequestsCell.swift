//
//  RequestsCell.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit

class RequestsCell: UITableViewCell {
    
    // MARK: - Properties
    private let vm   = RequestsViewModel()
    public  var user = UserViewModel() { didSet {
        nameLabel.text      = user.name
        usernameLabel.text  = user.username!
        userImage.load(url: user.imageURL!)
        }}
    
    // MARK: - IBOutlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var buttonsStack: UIStackView!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    private func initView() {
        userImage.layer.cornerRadius     = 21
        confirmButton.layer.cornerRadius = 4
        declineButton.layer.cornerRadius = 4
        
        confirmButton.addTarget(self, action: #selector(confirmPressed), for: .touchUpInside)
        declineButton.addTarget(self, action: #selector(declinePressed), for: .touchUpInside)
    }
    
    // MARK:- Actions
    @objc private func confirmPressed() {
        vm.confirmRequest(uid: user.uid!)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.buttonsStack.alpha = 0
            }
        }
    }
    
    @objc private func declinePressed() {
        vm.declineRequest(uid: user.uid!)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.buttonsStack.alpha = 0
            }
        }
    }
    
}