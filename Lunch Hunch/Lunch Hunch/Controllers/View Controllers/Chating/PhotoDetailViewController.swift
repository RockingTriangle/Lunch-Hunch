//
//  PhotoDetailViewController.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit

class PhotoDetailViewController: UIViewController {

    var photoURL = String()
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet var swipeGesture: UISwipeGestureRecognizer!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.KFloadImage(url: photoURL)
        swipeGesture.direction = .down
        swipeGesture.addTarget(self, action: #selector(dismissVC))
    }

    @objc func dismissVC() {
        dismiss(animated: true)
    }
    
}
