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
    let locationManager = LocationManager.shared
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
        radiusLabel.text = "Radius: \(Int(value))"
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
