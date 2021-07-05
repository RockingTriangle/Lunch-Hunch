//
//  System Authorization.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import Photos
import CoreLocation

struct SystemAuthorization {
    
    static let shared = SystemAuthorization()
        
    func photoAuthorization(completion: @escaping(Bool, String?)->()) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
            case .authorized:
                completion(true, nil)
            case .denied, .notDetermined, .restricted:
                PHPhotoLibrary.requestAuthorization { (isAuth) in
                    if isAuth == .authorized {
                        completion(true, nil)
                    } else {
                        completion(false, "Please go to Settings>Lunch Hunch>Photos>Choose Read and Write to able access photos")
                    }
            }
            default:
                completion(false, "Please go to Settings>Lunch Hunch>Photos>Choose Read and Write to able access photos")
        }
    }
    
}
