//
//  RestaurantSearchResultsTableViewController.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/25/21.
//

import UIKit
import FirebaseDatabase

protocol PopViewController: AnyObject {
    func popViewController()
}

class RestaurantSearchResultsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var results = RestaurantSearchModel.shared
    weak var delegate: PopViewController?
    var isRandom = false
    @IBOutlet weak var tableView: UITableView!
    
    public var uid: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        results.delegate = self
        results.businesses = []
        results.selectedBusiness = []
        saveButton.isEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: - Properties
    private let RESTAURANT_REF = FBAuthentication.shared.ref.child("restaurants")

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.businesses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell",
                                                       for: indexPath) as? RestaurantSearchTableViewCell
                                                       else { return UITableViewCell() }
        cell.prepareForReuse()
        if let _ = uid {
            cell.fromChat = true
        } else {
            cell.fromChat = false
        }
        cell.checkCountDelegate = self
        cell.tooManyDelegate = self
        cell.business = results.businesses[indexPath.row]
        cell.index = indexPath.row
        return cell
    }
    
    @IBAction func sortButtonTapped(_ sender: Any) {
        results.selectedBusiness = []
        showAlert(with: "Sorting Options", and: "Please choose an option below:")
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        if let uid = uid {
            results.addRestaurants(friendID: uid, isRandom: isRandom)
            navigationController?.popViewController(animated: true)
            delegate?.popViewController()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Functions
    func showErorrAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default) { [weak self] (action) -> Void in
            self?.dismiss(animated: false, completion: nil)
        }
        alert.addAction(dismissAction)
        alert.overrideUserInterfaceStyle = .light
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
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let sortByDistanceAction = UIAlertAction(title: "Distance", style: .default) { [weak self] (action) -> Void in
            YELPEndpoint.shared.sortingOption = .distance
            self?.results.fetchBusinesses()
        }
        let sortByRatingAction = UIAlertAction(title: "Rating", style: .default) { [weak self] (action) -> Void in
            YELPEndpoint.shared.sortingOption = .rating
            self?.results.fetchBusinesses()
        }
        let sortByBestMatchAction = UIAlertAction(title: "Best Match", style: .default) { [weak self] (action) -> Void in
            YELPEndpoint.shared.sortingOption = .bestMatch
            self?.results.fetchBusinesses()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(sortByDistanceAction)
        alert.addAction(sortByRatingAction)
        alert.addAction(sortByBestMatchAction)
        alert.addAction(cancelAction)
        alert.overrideUserInterfaceStyle = .light
        present(alert, animated: true)
    }
    
}
