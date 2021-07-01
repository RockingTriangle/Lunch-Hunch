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
    
    //---------------------------------------------------------------------------------------------
    
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
    
    //---------------------------------------------------------------------------------------------
    
    func cameraAuthorization(completion: @escaping(Bool, String?)->()) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
            case .authorized:
                completion(true, nil)
            case .denied, .notDetermined, .restricted:
                AVCaptureDevice.requestAccess(for: .video) { (isAuth) in
                    if isAuth {
                        completion(true, nil)
                    } else {
                        completion(false, "Please go to Settings>Lunch Hunch>Camera>Press On to able access camera")
                    }
            }
            default:
                completion(false, "Please go to Settings>Lunch Hunch>Camera>Press On to able access camera")
        }
    }
    
    //---------------------------------------------------------------------------------------------
    
    func locationAuthorization(completion: @escaping(Bool, String?)->()) {
        let locManager = CLLocationManager.authorizationStatus()
        switch locManager {
            case .notDetermined, .denied, .restricted:
                completion(false, nil)
            case .authorizedAlways, .authorizedWhenInUse:
                completion(true, nil)
            default:
                completion(false, "Please enable Location Services in your Settings")
        }
    }
    
    //---------------------------------------------------------------------------------------------
    
    func recordAuthorization(completion: @escaping(Bool, String?)->()) {
        let recordingSession = AVAudioSession.sharedInstance()
        recordingSession.requestRecordPermission() { (isAuth) in
            return isAuth ? completion(true, nil) : completion(false, "Please enable Microphone in your Settings")
        }
    }
}
