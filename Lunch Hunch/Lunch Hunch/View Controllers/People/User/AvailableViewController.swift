//
//  AvailableViewController.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit

class AvailableViewController: UIViewController {

    // MARK: - Properties
    let defaults = DefaultSettings.shared.defaults
    
    // MARK: - IBOutlets
    @IBOutlet weak var statusSwitch: UISwitch!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        let status = defaults.bool(forKey: "status")
        statusSwitch.isOn = status
    }
    
    // MARK: - IBActions
    @IBAction func switchPressed(_ sender: UISwitch) {
        let database = FBDatabase.shared
        let status = sender.isOn
        defaults.set(status, forKey: "status")
        status ? database.updateUserStatus(isOnline: status) : database.updateUserStatus(isOnline: status)
    }

}
