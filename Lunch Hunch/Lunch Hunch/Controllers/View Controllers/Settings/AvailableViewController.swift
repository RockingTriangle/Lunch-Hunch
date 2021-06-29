//
//  AvailableViewController.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit

class AvailableViewController: UIViewController {

    let defaults = DefaultSettings.shared.defaults
    
    @IBOutlet weak var statusSwitch: UISwitch!
    
    
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        let status = defaults.bool(forKey: "status")
        statusSwitch.isOn = status
    }
    
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        let database = FBDatabase.shared
        let status = sender.isOn
        defaults.set(status, forKey: "status")
        status ? database.updateUserStatus(isOnline: status) : database.updateUserStatus(isOnline: status)
    }
    
    

}
