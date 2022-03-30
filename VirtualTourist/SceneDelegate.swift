//
//  SceneDelegate.swift
//  VirtualTourist
//
//  Created by Marcos Mejias on 12/3/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let dataController = DataController(modelName: "VirtualTourist")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let travelLocationViewController = navigationController.topViewController as! TravelLocationsMapViewController
        travelLocationViewController.dataController = dataController
    }
}

