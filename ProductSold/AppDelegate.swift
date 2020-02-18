//
//  AppDelegate.swift
//  ProductSold
//
//  Created by Rob Caraway on 2/12/20.
//  Copyright © 2020 Rob Caraway. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var appCoordinator: AppCoordinator?
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let coordinator = AppCoordinator()
        coordinator.setState(state: .begin)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = coordinator.navigationController
        window.makeKeyAndVisible()
        self.window = window
        appCoordinator = coordinator
        return true
    }

}

