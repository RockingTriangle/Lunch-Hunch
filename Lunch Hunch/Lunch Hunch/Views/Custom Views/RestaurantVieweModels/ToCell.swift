//
//  ToCell.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//
import UIKit

class ToCell: UITableViewCell {

    // MARK: - Properties
    var msgVM = MessageViewModel() { didSet {
        messageLabel.text = msgVM.text
        timeLabel.text    = msgVM.timestamp?.getMessageTime()
    }}
    
    // MARK: - IBOutlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubble: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }

    // MARK: - Functions
    private func initView() {
        contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        userImage.layer.cornerRadius = 12.5
        userImage.image = UIImage(data: UserDefaults.standard.data(forKey: "image")!)
        bubble.image = UIImage(named: "chat_bubble_recived")!.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21),resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
        bubble.tintColor = UIColor(named: "BubbleRecived")
    }
    
}
