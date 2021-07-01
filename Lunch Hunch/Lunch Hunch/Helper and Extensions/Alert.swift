//
//  Alert.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit

struct Alert {
    static func showAlert(at viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }
}
