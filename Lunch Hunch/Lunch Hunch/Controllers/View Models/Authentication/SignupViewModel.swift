//
//  SignupViewModel.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit

class SignupViewModel {
    
    private var isSignup     : Bool?   { didSet { signupClosure?()    }}
    public  var messageAlert : String? { didSet { showAlertClosure?() }}
    
    var signupClosure   : (()->())?
    var showAlertClosure: (()->())?
    
    func signUpPressed(firstName: String, lasName: String, username: String, withEmail email: String, password: String, profileImage: UIImage?) {
        FBAuthentication.shared.FBSignUpUser(firstName: firstName, lasName: lasName, username: username, withEmail: email, password: password, profileImage: profileImage) { [weak self] (isSuccess, error) in
            guard let self = self else { return }
            if !isSuccess {
                self.messageAlert = error
            } else {
                self.isSignup = isSuccess
            }
        }
    }
}
