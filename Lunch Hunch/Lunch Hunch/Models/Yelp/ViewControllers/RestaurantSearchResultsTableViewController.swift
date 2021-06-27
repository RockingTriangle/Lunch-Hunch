//
//  RestaurantSearchResultsTableViewController.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/25/21.
//

import UIKit

class RestaurantSearchResultsTableViewController: UITableViewController {
    
    var results = RestaurantViewModel.shared
    
    var selectedCount = 0
    var selectedBusinesses: [Int] = []
    
    // Mark: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        results.delegate = self
        results.businesses = []
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.businesses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell",
                                                       for: indexPath) as? RestaurantTableViewCell
                                                       else { return UITableViewCell()}
        cell.prepareForReuse()
        cell.delegate = self
        cell.business = results.businesses[indexPath.row]
        return cell
    }
        
    // Mark: - Functions
    func showErorrAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default) { [weak self] (action) -> Void in
            self?.dismiss(animated: false, completion: nil)
        }
        alert.addAction(dismissAction)
        present(alert, animated: true)
    }
}

extension RestaurantSearchResultsTableViewController: RefreshData {
    func refreshData() {
        tableView.reloadData()
        if results.businesses.count == 0 {
            showErorrAlert(with: "No results", and: "Please change your settings and try again.")
        }
    }
}

// BUG BUG BUG

extension RestaurantSearchResultsTableViewController: SelectBusinessDelegate {
    func updateBusinessSelection(_ business: inout Business) {
//        guard let index = results.businesses.firstIndex(of: business) else { return }
//        let indexPath = IndexPath(row: index, section: 0)
//        results.businesses[index].isSelected.toggle()
//        selectedCount += 1
//        selectedBusinesses.append(index)
//        self.tableView.reloadRows(at: [indexPath], with: .automatic)
//        if selectedCount > 2 {
//            let removedIndex = selectedBusinesses[1]
//            results.businesses[removedIndex].isSelected.toggle()
//            selectedBusinesses.remove(at: 1)
//            selectedCount -= 1
//            self.tableView.reloadRows(at: [IndexPath(row: removedIndex, section: 0)], with: .automatic)
//        }
    }
}
