//
//  AppDelegate.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/15/21.
//

import UIKit
import Firebase

@available(iOS 13.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        if currentUser.id == nil { FBAuthentication.shared.signOutUser { (_, _) in } }
        FBDatabase.shared.updateUserStatus(isOnline: true)
        let status = DefaultSettings.shared.defaults.value(forKey: "status") as? Bool
        if status == nil { DefaultSettings.shared.ChangeAvailability(status: true)}
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

