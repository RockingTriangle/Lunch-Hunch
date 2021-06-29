//
//  RestaurantSearchResultsTableViewController.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/25/21.
//

import UIKit

class RestaurantSearchResultsTableViewController: UITableViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var results = RestaurantViewModel.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        results.delegate = self
        results.businesses = []
        saveButton.isEnabled = false
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.businesses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell",
                                                       for: indexPath) as? RestaurantTableViewCell
                                                       else { return UITableViewCell() }
        cell.alpha = 0
        cell.prepareForReuse()
        cell.checkCountDelegate = self
        cell.tooManyDelegate = self
        cell.business = results.businesses[indexPath.row]
        cell.index = indexPath.row
        return cell
    }
    
    @IBAction func sortButtonTapped(_ sender: Any) {
        showAlert(with: "Sorting Options", and: "Please choose an option below:")
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        print("")
    }
    
    // MARK: - Functions
    func showErorrAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default) { [weak self] (action) -> Void in
            self?.dismiss(animated: false, completion: nil)
        }
        alert.addAction(dismissAction)
        present(alert, animated: true)
    }
}

// MARK: - Extensions
extension RestaurantSearchResultsTableViewController: RefreshData {
    func refreshData() {
        tableView.reloadData()
        if results.businesses.count == 0 {
            showErorrAlert(with: "No results", and: "Please change your settings and try again.")
        }
    }
}

extension RestaurantSearchResultsTableViewController: CheckSelectionCountDelegate {
    func checkSelectionCount(_ index: Int) {
        if results.selectedBusiness.count < 2 {
            saveButton.isEnabled = false
        } else if results.selectedBusiness.count == 2 {
            saveButton.isEnabled = true
        }
    }
}

extension RestaurantSearchResultsTableViewController: TooManySelectedDelegate {
    func showTooManySelectedMessage() {
        let alert = UIAlertController(title: "Sorry", message: "You can only select two restaurants. To select this restaurant, please deselect on of your other choices first.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

extension RestaurantSearchResultsTableViewController {
    func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let sortByDistanceAction = UIAlertAction(title: "Distance", style: .default) { [weak self] (action) -> Void in
            YELPEndpoint.shared.sortingOption = .distance
            self?.results.fetchBusinesses()
            self?.refreshData()
            self?.dismiss(animated: false, completion: nil)
        }
        let sortByRatingAction = UIAlertAction(title: "Rating", style: .default) { [weak self] (action) -> Void in
            YELPEndpoint.shared.sortingOption = .rating
            self?.results.fetchBusinesses()
            self?.refreshData()
            self?.dismiss(animated: false, completion: nil)
        }
        let sortByBestMatchAction = UIAlertAction(title: "Best Match", style: .default) { [weak self] (action) -> Void in
            YELPEndpoint.shared.sortingOption = .bestMatch
            self?.results.fetchBusinesses()
            self?.refreshData()
            self?.dismiss(animated: false, completion: nil)
        }
        alert.addAction(sortByDistanceAction)
        alert.addAction(sortByRatingAction)
        alert.addAction(sortByBestMatchAction)
        present(alert, animated: true)
    }
}
