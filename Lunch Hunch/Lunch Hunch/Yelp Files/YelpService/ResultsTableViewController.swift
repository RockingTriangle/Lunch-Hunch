//
//  ResultsTableViewController.swift
//  Yelp
//
//  Created by Mike Conner on 6/14/21.
//

import UIKit

protocol SearchCriteria {
    func getBusinessesBasedOnCriteria(criteria: String)
}

class ResultsTableViewController: UITableViewController, RefreshData {
    
    var settings = SettingsViewModelController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        YelpBusinessModelController.shared.fetchBusinesses()
        YelpBusinessModelController.shared.delegate = self
        navigationItem.backButtonTitle = "Cancel"
    }
    
    func refreshData() {
        tableView.reloadData()
        if YelpBusinessModelController.shared.businesses.count == 0 {
            showErorrAlert(with: "No results", and: "Please change your settings and try again.")
        }
    }
    
    @IBAction func sortButtonTapped(_ sender: Any) {
        showAlert(with: "Sorting Options", and: "Please choose an option below:")
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return YelpBusinessModelController.shared.businesses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "businessCell", for: indexPath)
        cell.textLabel?.text = YelpBusinessModelController.shared.businesses[indexPath.row].name
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? SettingsViewController else { return }
        destinationVC.updateUIDelegate = self
    }
}

extension ResultsTableViewController: UpdateSettings {
    func updateUIandReload() {
        YELPEndpoint.shared.parameters = []
        if settings.locationSelection == 0 {
            YELPEndpoint.shared.searchArea = .location(settings.locationName)
        } else {
            YELPEndpoint.shared.searchArea = .latLon(Coordinates(latitude: Double(settings.locationLat)!, longitude: Double(settings.locationLon)!))
        }
        YELPEndpoint.shared.parameters.append(YELPEndpoint.Parameters.radius(Int(settings.radius * 1600)).parameterQueryItem)
        
        var count = 0
        for setting in settings.toggleSelection {
            if count != 0 {
                if setting {
                    YELPEndpoint.shared.parameters.append(YELPEndpoint.Parameters.categories(Options.foodOptions[count]).parameterQueryItem)
                }
            }
            count += 1
        }
        
        YELPEndpoint.shared.parameters.append(YELPEndpoint.Parameters.limit(settings.limit).parameterQueryItem)
        switch settings.price {
        case 0:
            YELPEndpoint.shared.parameters.append(YELPEndpoint.Parameters.price(settings.price + 1).parameterQueryItem)
        case 1:
            YELPEndpoint.shared.parameters.append(YELPEndpoint.Parameters.price(settings.price + 1).parameterQueryItem)
        case 2:
            YELPEndpoint.shared.parameters.append(YELPEndpoint.Parameters.price(settings.price + 1).parameterQueryItem)
        default:
            YELPEndpoint.shared.parameters.append(YELPEndpoint.Parameters.price(settings.price + 1).parameterQueryItem)
        }
        YelpBusinessModelController.shared.fetchBusinesses()
    }
}

extension ResultsTableViewController {
    func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let sortByDistanceAction = UIAlertAction(title: "Distance", style: .default) { [weak self] (action) -> Void in
            YELPEndpoint.shared.sortingOption = .distance
            self?.updateUIandReload()
            self?.dismiss(animated: false, completion: nil)
        }
        let sortByRatingAction = UIAlertAction(title: "Rating", style: .default) { [weak self] (action) -> Void in
            YELPEndpoint.shared.sortingOption = .rating
            self?.updateUIandReload()
            self?.dismiss(animated: false, completion: nil)
        }
        let sortByBestMatchAction = UIAlertAction(title: "Best Match", style: .default) { [weak self] (action) -> Void in
            YELPEndpoint.shared.sortingOption = .bestMatch
            self?.updateUIandReload()
            self?.dismiss(animated: false, completion: nil)
        }
        alert.addAction(sortByDistanceAction)
        alert.addAction(sortByRatingAction)
        alert.addAction(sortByBestMatchAction)
        present(alert, animated: true)
    }
    
    func showErorrAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default) { [weak self] (action) -> Void in
            self?.dismiss(animated: false, completion: nil)
        }
        alert.addAction(dismissAction)
        present(alert, animated: true)
    }
}

