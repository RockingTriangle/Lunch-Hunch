//
//  EditProfileViewModel.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit


class EditProfileViewModel {

    // MARK: - Properties
    var userInfo: UserInfoViewModel? { didSet {loadUserInfoClosure?() }}
    var message : String? { didSet { showAlertClosure?() }}
    
    var loadUserInfoClosure: (()->())?
    var showAlertClosure   : (()->())?
    
    // MARK: - Functions
    func initFetch() {
        DefaultSettings.shared.initUserDefaults { [unowned self] (user) in
            self.userInfo = self.proccessCreateUser(user: user)
        }
    }
    
    func UpdateProfile(photo: UIImage, country: String) {
        FBDatabase.shared.editProfile(profileImage: photo, country: country) { [unowned self] (isSuccess, error) in
            self.message = isSuccess ?  "Profile Updated Successfully" : error
        }
    }
    
    private func proccessCreateUser(user: User) -> UserInfoViewModel{
        let country = user.country == "" ? "United States" : user.country
        return UserInfoViewModel(photo: user.image, country: country)
    }
    
}

struct UserInfoViewModel {
    var photo  : UIImage?
    var country: String?
}
