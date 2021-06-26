//
//  RestaurantSettingsTableViewController.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/23/21.
//

import UIKit
import CoreLocation

class RestaurantSettingsTableViewController: UITableViewController {
    
    var viewModel = RestaurantViewModel.shared
    var locationManager = LocationManager.shared
    var endPoint = YELPEndpoint.shared
    
    var buttonArray: [UIButton] = []
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var priceButtonOne: UIButton!
    @IBOutlet weak var priceButtonTwo: UIButton!
    @IBOutlet weak var priceButtonThree: UIButton!
    @IBOutlet weak var priceButtonFour: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCells()
        configureLocationManager()
    }
    
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
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        
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
        var priceString = priceQuery.map { String($0) }
        let finalPriceString = priceString.joined(separator: ",")
        
        //
        //  I am here!!!!
        //
        
        
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
    
    func configureCells() {
        locationLabel.text = viewModel.searchLocation.description
        radiusLabel.text = "Radius: \(viewModel.radiusAmount) miles"
        radiusSlider.value = Float(viewModel.radiusAmount)
        buttonArray = [priceButtonOne, priceButtonTwo, priceButtonThree, priceButtonFour]
        updatePriceButtons()
    }
    
    func configureLocationManager() {
        locationManager.checkLocationServices()
        locationManager.setDelegate(self)
    }
    
    func updatePriceButtons() {
        for index in 0...3 {
            buttonArray[index].setTitleColor(viewModel.priceOptions[index] == true ? .lightText : .darkText, for: .normal)
            buttonArray[index].backgroundColor = viewModel.priceOptions[index] == true ? .darkText : .lightText
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLocation" {
            guard let destinationVC = segue.destination as? LocationViewController else { return }
            destinationVC.updateSettingsDelegate = self
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
