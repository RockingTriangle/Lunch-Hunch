//
//  ChangePassword.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import Foundation

class ChangePasswordViewModel {
    
    var message = String() { didSet { changePasswordClosure?() }}
    
    
    var changePasswordClosure: (()->())?
    
    
    func chnagePassword(password: String, repassword: String) {
        if password == repassword {
            FBAuthentication.shared.changePassword(password: password) { [weak self] (isSuccess, error) in
                guard let self = self else { return }
                self.message = isSuccess ? "Password Updated" : error!
            }
        } else {
            message = "The Password and Re-password not similar"
        }
    }
    
}
