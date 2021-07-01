//
//  RestaurantSettingsTableViewController.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/23/21.
//

import UIKit
import CoreLocation

class RestaurantSettingsTableViewController: UITableViewController {
    
    // MARK: - Properties
    var viewModel = RestaurantViewModel.shared
    var locationManager = LocationManager.shared
    var endPoint = YELPEndpoint.shared
    var buttonArray: [UIButton] = []
    
    // MARK: - IBOutlets
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var foodTypeCellLabel: UILabel!
    @IBOutlet weak var priceButtonOne: UIButton!
    @IBOutlet weak var priceButtonTwo: UIButton!
    @IBOutlet weak var priceButtonThree: UIButton!
    @IBOutlet weak var priceButtonFour: UIButton!
   
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCells()
        configureLocationManager()
        if CLLocationManager.authorizationStatus() == .denied ||
            CLLocationManager.authorizationStatus() == .notDetermined ||
            CLLocationManager.authorizationStatus() == .restricted {
            locationManager.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureCells()
    }
    
    // MARK: - IBActions
    @IBAction func radiusSliderValueChanged(_ sender: UISlider) {
        let step: Float = 1
        let value = round(sender.value / step) * step
        radiusLabel.text = "Radius: \(Int(value)) miles"
    }
    
    @IBAction func priceButtonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            viewModel.priceOptions[0].toggle()
        case 1:
            viewModel.priceOptions[1].toggle()
        case 2:
            viewModel.priceOptions[2].toggle()
        case 3:
            viewModel.priceOptions[3].toggle()
        default:
            break
        }
        updatePriceButtons()
    }
    
    // MARK: - Functions
    func configureCells() {
        locationLabel.text = viewModel.searchLocation.description
        radiusLabel.text = "Radius: \(viewModel.radiusAmount) miles"
        radiusSlider.value = Float(viewModel.radiusAmount)
        var didSelectCustomFoodSelection = false
        for index in (1...19) {
            if viewModel.foodTypes[index] == true {
                didSelectCustomFoodSelection = true
            }
        }
        foodTypeCellLabel.text = didSelectCustomFoodSelection ? "Custom food type search, tap to edit." : "Search all options, tap to edit."
        buttonArray = [priceButtonOne, priceButtonTwo, priceButtonThree, priceButtonFour]
        updatePriceButtons()
    }
    
    func configureLocationManager() {
        locationManager.checkLocationServices()
        locationManager.setDelegate(self)
    }
    
    func updatePriceButtons() {
        for index in 0...3 {
            buttonArray[index].setTitleColor(viewModel.priceOptions[index] == true ? .white : .darkText, for: .normal)
            buttonArray[index].backgroundColor = viewModel.priceOptions[index] == true ? .darkText : .lightText
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLocation" {
            guard let destinationVC = segue.destination as? LocationViewController else { return }
            destinationVC.updateSettingsDelegate = self
        }
        if segue.identifier == "toResultsVC" {
            
            if viewModel.priceOptions.contains(true) {
                guard let location = viewModel.finalSearchLocation else { return }
                let searchLatitude = URLQueryItem(name: "latitude", value: String(location.coordinate.latitude))
                let searchLongitude = URLQueryItem(name: "longitude", value: String(location.coordinate.longitude))
                
                endPoint.locationQueries = [searchLatitude, searchLongitude]
                
                endPoint.parameters = []
                
                endPoint.parameters.append(YELPEndpoint.Parameters.radius(Int(viewModel.radiusAmount * 1600)).parameterQueryItem)
                
                for index in (1...19) {
                    if viewModel.foodTypes[index] {
                        endPoint.parameters.append(YELPEndpoint.Parameters.categories(FoodTypeOptions.options[index]).parameterQueryItem)
                    }
                }
                
                var priceQuery: [Int] = []
                for index in (0...3) {
                    if viewModel.priceOptions[index] == true {
                        priceQuery.append(viewModel.priceValues[index])
                    }
                }
                let priceString = priceQuery.map { String($0) }
                let finalPriceString = priceString.joined(separator: ",")
                
                endPoint.parameters.append(YELPEndpoint.Parameters.price(finalPriceString).parameterQueryItem)
                
                RestaurantViewModel.shared.fetchBusinesses()
            } else {
                showAlert(with: "Sorry", and: "You must select one or more of the pricing options to proceed.")
            }
        }
    }
    
}

// Mark: - Extension
extension RestaurantSettingsTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            viewModel.currentLocation = location
            if locationLabel.text == "...searching" {
                locationLabel.text = viewModel.searchLocation.description
            }
        }
    }
}

extension RestaurantSettingsTableViewController: UpdateSettings {
    func updateSettings() {
        configureCells()
    }
}

extension RestaurantSettingsTableViewController {
    func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            self.dismiss(animated: false, completion: nil)
        }
        alert.addAction(okAction)
        alert.overrideUserInterfaceStyle = .light
        present(alert, animated: true)
    }
}
