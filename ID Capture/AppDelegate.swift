//
//  AppDelegate.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 11/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        UserDefaults.standard.register(defaults: [SettingsViewController.useBlinkIdKey: true])
        if ExecutionParams.isTesting {
            UserDefaults.standard.set(false, forKey: SettingsViewController.useBlinkIdKey)
        }
        return true
    }
}
