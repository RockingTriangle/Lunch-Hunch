//
//  LocationManager.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/23/21.
//
import Foundation
import CoreLocation
import MapKit

class LocationManager {
    
    // MARK: - Shared Instance
    static let shared = LocationManager()
        
    // Properties
    let locationManager = CLLocationManager()
    
    
    // MARK: - Functions
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            configureLocationManager()
        } else {
            print("location services off: fix in settings")
        }
    }

    func configureLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
    }

    func setDelegate(_ self: UIViewController) {
        locationManager.delegate = self as? CLLocationManagerDelegate
        locationManager.startUpdatingLocation()
    }

    func getAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .restricted:
            print("restricted: fix in settings")
        case .denied:
            print("denied: fix in settings")
        @unknown default:
            break
        }
    }
    
    func start() {
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        LocationManager.shared.getAuthorizationStatus()
    }

}


