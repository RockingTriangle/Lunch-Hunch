//
//  LocationViewController.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/23/21.
//

import UIKit
import MapKit

protocol UpdateSettings {
    func updateSettings()
}

class LocationViewController: UIViewController, MKMapViewDelegate {
    
    var viewModel = RestaurantViewModel.shared
    var locationManager = LocationManager.shared
    var pinLocation: CLLocation?
    var updateSettingsDelegate: UpdateSettings?
    
    // Mark: - IBOutlets
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var zipcodeButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        configureViews()
    }
    
    // Mark: - IBActions
    @IBAction func myLocationButtonTapped(_ sender: Any) {
        viewModel.userSearchChoice = .location
        configureViews()
        updateSettingsDelegate?.updateSettings()
    }
    
    @IBAction func zipcodeButtonTappd(_ sender: Any) {
        let alertController = UIAlertController(title: "ZIP CODE", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter 5 digit Zip Code..."
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let searchAction = UIAlertAction(title: "Enter", style: .default) { [self] _ in
            guard let zipcode = alertController.textFields?.first?.text,
                  !zipcode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  zipcode.count == 5 else { return }
            if Int(zipcode) != nil {
                self.viewModel.userSearchChoice = .zipcode(zipcode)
                self.getCoordinats(from: zipcode)
                print(zipcode)
            }
        }
        alertController.addAction(searchAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func configureViews() {
        myLocationButton.setTitleColor(viewModel.userSearchChoice.description == "My Location" ? .lightGray : .darkGray, for: .normal)
        myLocationButton.backgroundColor = viewModel.userSearchChoice.description == "My Location" ? .darkGray : .lightGray
        zipcodeButton.setTitleColor(viewModel.userSearchChoice.description == "My Location" ? .darkGray : .lightGray, for: .normal)
        zipcodeButton.backgroundColor = viewModel.userSearchChoice.description == "My Location" ? .lightGray : .darkGray
        viewModel.userSearchChoice.description == "My Location" ? centerViewOnUserLocation() : centerViewOnZipcodeLocation()
    }
    
    func getCoordinats(from zipcode: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(zipcode) { placemarks, error in
            guard let placemark = placemarks?.first,
                  let coordinates = placemark.location?.coordinate else { return }
            self.viewModel.zipcodeLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            DispatchQueue.main.async {
                self.configureViews()
                self.mapView.setNeedsDisplay()
                self.updateSettingsDelegate?.updateSettings()
            }
        }
    }
    
    // Mark: - Map View Configuration    
    func centerViewOnUserLocation() {
        if let location = viewModel.currentLocation?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 80000, longitudinalMeters: 80000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func centerViewOnZipcodeLocation() {
        if let location = viewModel.zipcodeLocation?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 80000, longitudinalMeters: 80000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.checkLocationServices()
        } else {
            let alert = UIAlertController(title: "User Location", message: "To allow user location, go to Settings -> Privacy -> Location", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
