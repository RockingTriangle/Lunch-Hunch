//
//  AddFriendTableViewController.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit

class AddFriendTableViewController: UITableViewController {

    // MARK: - Properties
    private var users = [User]()
    private let searchController = UISearchController()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        initView()
        initFetch()
    }
    
    private func initView() {
        tableView.tableFooterView = UIView()
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.searchController = searchController
        navigationController?.overrideUserInterfaceStyle = .light
        searchController.overrideUserInterfaceStyle = .light
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    private func initFetch() {
        FBDatabase.shared.loadAllUsers { [weak self] (users, error) in
            guard let self = self else { return }
            if error == nil {
                self.users = users!
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Suggest"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as! AddFriendCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

}

