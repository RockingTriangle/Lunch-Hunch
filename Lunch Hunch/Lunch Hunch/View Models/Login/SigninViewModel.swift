//
//  SigninViewModel.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import Foundation

class SigninViewModel {
    
    // MARK: - Properties
    private var isSignIn: Bool? { didSet { signInClosure?() }}
    public  var message : String? { didSet { showAlertClosure?() }}
    
    var signInClosure: (()->())?
    var showAlertClosure: (()->())?
    
    // MARK: - Functions
    func signInPressed(withEmail email: String, password: String) {
        FBAuthentication.shared.FBSignInUser(withEmail: email, password: password) { [weak self] (isSuccess, error) in
            guard let self = self else { return }
            if !isSuccess {
                self.message = error
            } else {
                self.isSignIn = isSuccess
            }
        }
    }
    
}
