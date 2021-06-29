//
//  FromCell.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit

class FromCell: UITableViewCell {

    
    var msgVM = MessageViewModel() { didSet {
        messageLabel.text = msgVM.text
        timeLabel.text    = msgVM.timestamp?.getMessageTime()
        userImage.image   = currentUser.image
        seenImage.image   = msgVM.isSeen! ? UIImage(named: "Seen") : UIImage(named: "Unseen")
    }}
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubblle: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var seenImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        userImage.layer.cornerRadius = 10
        bubblle.image = UIImage(named: "chat_bubble_sent")!.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21),resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
        
    }


}
