//
//  SceneDelegate.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/15/21.
//


import UIKit
import Firebase

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var viewController: UIViewController?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        if Auth.auth().currentUser != nil {
            viewController = storyboard.instantiateViewController(identifier: Identifiers.tabBar)
        } else {
            viewController = storyboard.instantiateViewController(identifier: "loginVC")
        }
        window?.rootViewController = viewController
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) { FBDatabase.shared.updateUserStatus(isOnline: false) }

    func sceneDidBecomeActive(_ scene: UIScene) { FBDatabase.shared.updateUserStatus(isOnline: true) }

    func sceneWillResignActive(_ scene: UIScene) { FBDatabase.shared.updateUserStatus(isOnline: false) }

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) { FBDatabase.shared.updateUserStatus(isOnline: false) }
}

