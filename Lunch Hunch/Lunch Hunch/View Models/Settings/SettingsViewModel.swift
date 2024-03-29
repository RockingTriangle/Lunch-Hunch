//
//  SettingsViewModel.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import Foundation
import Firebase


class SettingsViewModel {
    
    // MARK: - Properties
    let defaults = UserDefaults.standard
    var user = User() {
        didSet {
            loadInfoClosure?()
        }
    }
    
    var loadInfoClosure: (()->())?
    
    // MARK: - Functions
    func loadInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if self.defaults.string(forKey: "id") == uid  {
            DefaultSettings.shared.initUserDefaults { (user) in
                self.user = user
            }
        } else {
        FBDatabase.shared.loadUserInfo(for: uid) { [weak self] (user, error) in
                guard let self = self else { return }
                if error != nil {
                    print(error!)
                } else {
                    guard let user = user else { return }
                    self.user = user
                    DefaultSettings.shared.setUserDefauls(first: user.first, last: user.last, id: user.id, email: user.email, username: user.username, imageURL: user.imageURL, country: user.country)
                }
            }
        }
    }
    
}
