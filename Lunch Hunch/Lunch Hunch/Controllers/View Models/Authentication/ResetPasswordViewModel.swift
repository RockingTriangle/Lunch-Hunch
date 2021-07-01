//
//  ResetPasswordViewModel.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import Foundation

class ResetPasswordViewModel {
    
    // MARK: - Properties
    var message     : String? { didSet { showAlertClosure?() }}
    var isSuccess   = true
    var showAlertClosure: (()->())?
    
    // MARK: - Functions
    func resetPassword(email: String) {
        FBAuthentication.shared.resetPassword(email: email) { (isSuccess, error) in
            if isSuccess {
                self.isSuccess = isSuccess
                self.message   = "We sent an email to reset your password, Thanks to check your email"
            } else {
                self.isSuccess = isSuccess
                self.message   = error
            }
        }
    }
    
}



