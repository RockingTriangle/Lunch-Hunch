//
//  FirebaseService.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import Foundation
import Firebase

class FBAuthentication {
    
    // MARK: - Properties
    public static let shared = FBAuthentication()
    public let ref = Database.database().reference()
    
    //MARK:- User authentications
    func FBSignInUser(withEmail email: String, password: String, completion: @escaping(Bool, String?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                completion(false, error?.localizedDescription)
            } else {
                guard let user = result?.user else {
                    completion(false, "There was a problem, please try again")
                    return
                }
                FBDatabase.shared.updateUserStatus(isOnline: true)
                FBDatabase.shared.loadUserInfo(for: user.uid) { (user, error) in
                    guard let user = user else { return }
                    DefaultSettings.shared.setUserDefauls(first: user.first, last: user.last, id: user.id, email: user.email, username: user.username, imageURL: user.imageURL, country: user.country)
                    completion(true, nil)
                }
            }
        }
    }
    
    // MARK: - Functions
    func FBSignUpUser(firstName: String, lasName: String, username: String, withEmail email: String, password: String, profileImage: UIImage?, completion: @escaping(Bool, String?) -> ()) {
        
        guard !firstName.trimmingCharacters(in: .whitespaces).isEmpty   &&
              !lasName.trimmingCharacters(in: .whitespaces).isEmpty     &&
              !username.trimmingCharacters(in: .whitespaces).isEmpty    &&
              !email.trimmingCharacters(in: .whitespaces).isEmpty       &&
              !password.trimmingCharacters(in: .whitespaces).isEmpty  else {
                  completion(false, "Please enter all required fields")
                  return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [unowned self] (result, error) in
            if error != nil {
                completion(false, error?.localizedDescription)
            } else {
                guard let FBUser = result?.user else {
                    completion(false, "There was a problem, Thanks to try again")
                    return
                }
                self.ref.child("users").queryOrdered(byChild: "username").queryEqual(toValue: username).observeSingleEvent(of: .value) { [unowned self] (snapshot) in
                    if snapshot.exists() {
                        FBUser.delete()
                        completion(false, "Sorry, The username is already exist")
                        return
                    } else {
                        guard let imageData = profileImage?.jpegData(compressionQuality: 0.5) else { return }
                        let uploadTask = Storage.storage().reference().child("profile").child("\(FBUser.uid).jpg")
                        uploadTask.putData(imageData, metadata: nil) { (metaData, error) in
                            if error != nil {
                                FBUser.delete()
                                completion(false, error?.localizedDescription)
                                return
                            } else {
                                uploadTask.downloadURL { [unowned self] (url, error) in
                                    if error != nil {
                                        uploadTask.delete(completion: nil)
                                        FBUser.delete()
                                        completion(false, error?.localizedDescription)
                                    } else {
                                        let DBUser =
                                            ["first": firstName,
                                             "last": lasName,
                                             "username": username,
                                             "email": email,
                                             "id": FBUser.uid,
                                             "imageULR": url?.absoluteString] // TODO: - spelling error in Firebase DB???
                                        self.ref.child("users").child(FBUser.uid).setValue(DBUser) { (error, data) in
                                            if error != nil {
                                                FBUser.delete()
                                                completion(false, "There was a problem, Thanks to try again")
                                            } else {
                                                DefaultSettings.shared.setUserDefauls(first: firstName, last: lasName, id: FBUser.uid, email: email, username: username, imageURL: url!.absoluteString, country: "")
                                                DefaultSettings.shared.defaults.set(true, forKey: "status")
                                                completion(true, nil)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func signOutUser(completion: @escaping(Bool, String?) -> ()) {
        do {
            FBDatabase.shared.updateUserStatus(isOnline: false)
            FBNetworkRequest.shared.friendsList.removeAll()
            FBNetworkRequest.shared.requestsRecived.removeAll()
            FBNetworkRequest.shared.requestsSent.removeAll()
            try Auth.auth().signOut()
            completion(true, nil)
        } catch {
            completion(false, error.localizedDescription)
        }
    }
    
    func changePassword(password: String, completion: @escaping(Bool, String?) -> ()) {
        Auth.auth().currentUser?.updatePassword(to: password, completion: { (error) in
            error == nil ? completion(true, nil) : completion(false, error?.localizedDescription) })
    }
    
    func resetPassword(email: String, completion: @escaping(Bool, String?) -> ()) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            error == nil ? completion(true, nil) : completion(false, error?.localizedDescription) }
    }
    
}
