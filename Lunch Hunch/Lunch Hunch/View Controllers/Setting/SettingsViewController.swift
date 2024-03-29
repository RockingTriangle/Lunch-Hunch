//
//  SettingsViewController.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var HeaderView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    
    // MARK: - Properties
    let vm = SettingsViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        initView()
        initVM()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initVM()
        tableView.reloadData()
    }
    
    // MARK:- Init view and view model
    private func initView() {
        profileImage.layer.cornerRadius = 35
        statusView.layer.cornerRadius = 5
        statusView.layer.masksToBounds = true
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func initVM() {
        vm.loadInfoClosure = { [weak self] in
            guard let self = self else { return }
            guard let first = self.vm.user.first else { return }
            guard let last = self.vm.user.last else { return }
            self.titleLabel.text = first + " " + last
            if let image = self.vm.user.image {
                self.profileImage.image = image
            } else {
                guard let url = self.vm.user.imageURL else { return }
                self.profileImage.load(url: url)
            }
            let status = DefaultSettings.shared.availability()
            self.statusView.backgroundColor = status ?  .systemGreen : .gray
        }
        vm.loadInfo()
    }
    
}

// MARK:- TableView datasource and delegate
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return HeaderView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "status"
        } else if section == 2 {
            return "user management"
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 180
        } else if section == 1 || section == 2 || section == 3 {
            return 30
        } else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 1
        } else if section == 2{
            return 3
        } else if section == 3 {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let row = indexPath.row
        let section = indexPath.section
        if row == 0 && section == 0 {
            cell.textLabel?.text = "Edit Profile"
        } else if row == 1 && section == 0 {
            cell.textLabel?.text = "Change Password"
        } else if row == 0 && section == 1 {
            cell.textLabel?.text = "Available"
            let status = DefaultSettings.shared.availability()
            cell.detailTextLabel?.text = status ? "On" : "Off"
            cell.detailTextLabel?.textColor = .gray
        } else if row == 0 && section == 2 {
            cell.textLabel?.text = "Friends"
        } else if row == 1 && section == 2 {
            cell.textLabel?.text = "Friend Requests" 
        } else if row == 2 && section == 2 {
            cell.textLabel?.text = "Blocked"
        } else if row == 0 && section == 3 {
            cell.textLabel?.text = "Sign Out"
            cell.textLabel?.textColor = #colorLiteral(red: 1, green: 0.3032806202, blue: 0.02296007777, alpha: 1)
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 && indexPath.row == 0 {
            let alert = UIAlertController(title: "Are you sure to sign out?", message: nil, preferredStyle: .actionSheet)
            alert.overrideUserInterfaceStyle = .light
            alert.addAction(.init(title: "Sign Out", style: .destructive, handler: { [weak self](_) in
                guard let self = self else { return }
                FBAuthentication.shared.signOutUser { (isSuccess, error) in
                    if error != nil {
                        Alert.showAlert(at: self, title: "Sign Out Validation", message: error!)
                    } else {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC")
                        loginVC.modalTransitionStyle = .crossDissolve
                        self.present(loginVC, animated: true)
                    }
                }
            }))
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            alert.overrideUserInterfaceStyle = .light
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        } else if indexPath.section == 0 && indexPath.row == 0 {
            performSegue(withIdentifier: "editeProfile", sender: self)
        } else if indexPath.section == 0 && indexPath.row == 1 {
            performSegue(withIdentifier: "changePassword", sender: self)
        } else if indexPath.section == 1 && indexPath.row == 0 {
            performSegue(withIdentifier: "available", sender: self)
        } else if indexPath.section == 2 && indexPath.row == 0 {
            performSegue(withIdentifier: "toFriendsListVC", sender: self)
        } else if indexPath.section == 2 && indexPath.row == 1 {
            performSegue(withIdentifier: "toRequests", sender: self) 
        } else if indexPath.section == 2 && indexPath.row == 2 {
            performSegue(withIdentifier: "blockedUsers", sender: self)
        }
    }
    
}
