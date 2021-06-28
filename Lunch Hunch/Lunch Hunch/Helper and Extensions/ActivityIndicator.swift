//
//  ActivityIndecator.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit


struct ActivityIndicator {
    private static let activityIndicator = UIActivityIndicatorView()
    
    public static func initActivityIndecator(view: UIView) {
        activityIndicator.color = UIColor(named: "ActivityIndecatorColor")
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
    }
    
    public static func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    public static func stopAnimating() {
        activityIndicator.stopAnimating()
    }    
}

