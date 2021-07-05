//
//  BlockedViewModel.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import Foundation

class BlockedViewModel {
    
    // MARK: - Properties
    var userViewModel = [UserViewModel]() { didSet { reloadTableViewClosure?() }}
    var numberOfCells : Int? { return userViewModel.count}
    
    var reloadTableViewClosure: (()->())?
    
    // MARK:- Fetch Blocked Users
    func initFetch() {
        if FBNetworkRequest.shared.blockedList.isEmpty {
            FBNetworkRequest.shared.fetchBlockedList { (_) in
                FBNetworkRequest.shared.fetchBlockedUsers { [weak self] (users) in
                    guard let self = self else { return }
                    guard let users = users else { return }
                    self.createUserViewModel(users: users)
                }
            }
        } else {
            FBNetworkRequest.shared.fetchBlockedUsers { [weak self] (users) in
                guard let self = self else { return }
                self.createUserViewModel(users: users!)
            }
        }
    }
    
    private func createUserViewModel(users: [User]) {
        var vms = [UserViewModel]()
        for user in users {
            vms.append(proccessFetchUsers(user: user))
        }
        userViewModel.append(contentsOf: vms)
    }
    
    private func proccessFetchUsers(user: User) -> UserViewModel {
        let name = user.first! + " " + user.last!
        return UserViewModel(name: name, username: user.username!, imageURL: user.imageURL!, uid: user.id!)
    }
    
    // MARK:- Block Action
    func unblockUser(uid: String) {
        FBNetworkRequest.shared.unblockUser(uid: uid)
    }
    
}
