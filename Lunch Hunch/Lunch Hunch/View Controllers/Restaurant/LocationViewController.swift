//
//  LocationViewController.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/23/21.
//

import UIKit
import MapKit

protocol UpdateSettings: AnyObject {
    func updateSettings()
}

class LocationViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Properties
    var viewModel = RestaurantSearchModel.shared
    var locationManager = LocationManager.shared
    weak var updateSettingsDelegate: UpdateSettings?
    var mapRange: Float = 4000
    var mapSpan: MKCoordinateSpan?
    let categories: [MKPointOfInterestCategory] = [.bakery, .brewery, .cafe, .foodMarket, .nightlife, .restaurant, .winery]
    var filter: MKPointOfInterestFilter?
    
    // Mark: - IBOutlets
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var zipcodeButton: UIButton!
    @IBOutlet weak var setLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        mapView.delegate = self
        configureViews()
        mapView.layer.borderColor = UIColor.white.cgColor
        mapView.layer.borderWidth = 8
        filter = MKPointOfInterestFilter.init(including: categories)
        mapView.pointOfInterestFilter = filter
        setLocationButton.setTitleColor(.white, for: .normal)
    }
    
    // Mark: - IBActions
    @IBAction func myLocationButtonTapped(_ sender: Any) {
        viewModel.userSearchChoice = .location
        configureViews()
        updateSettingsDelegate?.updateSettings()
    }
    
    @IBAction func cityButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "City", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter city name..."
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let searchAction = UIAlertAction(title: "Enter", style: .default) { [self] _ in
            guard let city = alertController.textFields?.first?.text,
                  !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            
            self.viewModel.userSearchChoice = .city(city.capitalized)
            self.getCoordinats(from: city)            
        }
        alertController.addAction(searchAction)
        alertController.addAction(cancelAction)
        alertController.overrideUserInterfaceStyle = .light
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func zipcodeButtonTappd(_ sender: Any) {
        let alertController = UIAlertController(title: "ZIP CODE", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "Enter 5 digit zip Code..."
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let searchAction = UIAlertAction(title: "Enter", style: .default) { [self] _ in
            guard let zipcode = alertController.textFields?.first?.text,
                  !zipcode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  zipcode.count == 5 else { return }
            if Int(zipcode) != nil {
                self.viewModel.userSearchChoice = .zipcode(zipcode)
                self.getCoordinats(from: zipcode)
            }
        }
        alertController.addAction(searchAction)
        alertController.addAction(cancelAction)
        alertController.overrideUserInterfaceStyle = .light
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func setButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Functions
    func configureViews() {
        myLocationButton.setTitleColor(viewModel.userSearchChoice.description.contains("My Location") ? .white : .darkText, for: .normal)
        myLocationButton.backgroundColor = viewModel.userSearchChoice.description.contains("My Location") ? .darkText : .lightText
        cityButton.setTitleColor(viewModel.userSearchChoice.description.contains("City") ? .white : .darkText, for: .normal)
        cityButton.backgroundColor = viewModel.userSearchChoice.description.contains("City") ? .darkText : .lightText
        zipcodeButton.setTitleColor(viewModel.userSearchChoice.description.contains("Zipcode") ? .white : .darkText, for: .normal)
        zipcodeButton.backgroundColor = viewModel.userSearchChoice.description.contains("Zipcode") ? .darkText : .lightText
        centerMapView()
    }
    
    func getCoordinats(from location: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { placemarks, error in
            guard let placemark = placemarks?.first,
                  let coordinates = placemark.location?.coordinate else { return }
            if self.viewModel.userSearchChoice.description.contains("City") {
                self.viewModel.cityLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            } else if self.viewModel.userSearchChoice.description.contains("Zip") {
                self.viewModel.zipcodeLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            } else {
                self.viewModel.finalSearchLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            }
            DispatchQueue.main.async {
                self.configureViews()
                self.mapView.setNeedsDisplay()
                self.updateSettingsDelegate?.updateSettings()
            }
        }
    }
    
    // Mark: - Map View Configuration
    func centerMapView() {
        switch viewModel.userSearchChoice {
        case .location:
            guard let location = viewModel.currentLocation?.coordinate else { return }
            setMapRegion(with: location)
        case .city(_):
            guard let location = viewModel.cityLocation?.coordinate else { return }
            setMapRegion(with: location)
        case .zipcode(_):
            guard let location = viewModel.zipcodeLocation?.coordinate else { return }
            setMapRegion(with: location)
        case .custom:
            guard let location = viewModel.customLocation?.coordinate else { return }
            setMapRegion(with: location)
        }
    }
    
    func setMapRegion(with location: CLLocationCoordinate2D) {
        if mapSpan == nil {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: CLLocationDistance(mapRange), longitudinalMeters: CLLocationDistance(mapRange))
            mapView.setRegion(region, animated: true)
        } else {
            let region = MKCoordinateRegion.init(center: location, span: mapSpan!)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.checkLocationServices()
        } else {
            let alert = UIAlertController(title: "User Location Not Enabled", message: "To allow user location, go to Settings -> Privacy -> Location", preferredStyle: .alert)
            alert.overrideUserInterfaceStyle = .light
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let mapCenter = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        switch viewModel.userSearchChoice {
        case .location:
            if (viewModel.currentLocation?.distance(from: mapCenter)) ?? 0 > 200 {
                viewModel.customLocation = mapCenter
                viewModel.userSearchChoice = .custom
                setMapRegion(with: CLLocationCoordinate2D(latitude: mapCenter.coordinate.latitude, longitude: mapCenter.coordinate.longitude))
            }
        case .city(_):
            if (viewModel.cityLocation?.distance(from: mapCenter)) ?? 0 > 200 {
                viewModel.customLocation = mapCenter
                viewModel.userSearchChoice = .custom
                setMapRegion(with: CLLocationCoordinate2D(latitude: mapCenter.coordinate.latitude, longitude: mapCenter.coordinate.longitude))
            }
        case .zipcode(_):
            if (viewModel.zipcodeLocation?.distance(from: mapCenter)) ?? 0 > 200 {
                viewModel.customLocation = mapCenter
                viewModel.userSearchChoice = .custom
                setMapRegion(with: CLLocationCoordinate2D(latitude: mapCenter.coordinate.latitude, longitude: mapCenter.coordinate.longitude))
            }
        case .custom:
            if (viewModel.finalSearchLocation?.distance(from: mapCenter)) ?? 0 > 200 {
                viewModel.customLocation = mapCenter
                viewModel.userSearchChoice = .custom
                setMapRegion(with: CLLocationCoordinate2D(latitude: mapCenter.coordinate.latitude, longitude: mapCenter.coordinate.longitude))
            }
        }
        configureViews()
        updateSettingsDelegate?.updateSettings()
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        mapSpan = mapView.region.span
    }
}
