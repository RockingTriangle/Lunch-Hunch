//
//  BlockedUsersTableViewController.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit

class BlockedUsersTableViewController: UITableViewController {

    // MARK: - Properties
    private let vm = BlockedViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initFetch()
    }
    
    // MARK:- Fetch users
    func initFetch() {
        vm.reloadTableViewClouser = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
        vm.initFetch()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return vm.numberOfCells!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockCell", for: indexPath) as! BlockedUsersTableViewCell
        cell.userVM = vm.userViewModel[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

}
