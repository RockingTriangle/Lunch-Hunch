//
//  SentCell.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit

protocol RefreshSentCellProtocol: AnyObject {
    func refreshCell()
}

class SentCell: UITableViewCell {
    
    // MARK: - Properties
    weak var delegate: RefreshSentCellProtocol?
    private let vm   = RequestsViewModel()
    public  var user = UserViewModel() { didSet {
        nameLabel.text      = user.name
        usernameLabel.text  = user.username
        userImage.load(url: user.imageURL!)
        }}
    
    // MARK: - IBOutlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    private func initView() {
        userImage.layer.cornerRadius     = 21
        cancelButton.layer.cornerRadius = 4
        cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
    }
    
    // MARK:- Actions
    @objc private func cancelPressed() {
        vm.removeRequest(uid: user.uid!)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.cancelButton.alpha = 0
            }
        }
        //delegate?.refreshCell()
    }
    
}
