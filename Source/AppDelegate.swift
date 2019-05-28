//
//  AppDelegate.swift
//  VerIDIDCaptureTest
//
//  Created by Jakub Dolejs on 26/10/2016.
//  Copyright © 2016 Applied Recognition, Inc. All rights reserved.
//

import UIKit
import VerIDCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ErrorViewControllerDelegate, VerIDFactoryDelegate {
    
    var window: UIWindow?
    var verid: VerID?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Load Ver-ID, this will speed up the startup of live face capture
        let defaults: [String:AnyObject] = ["securityLevel":NSNumber(value: 4.0),"intellicheck":NSNumber(value: false)]
        UserDefaults.standard.register(defaults: defaults)
        NotificationCenter.default.addObserver(self, selector: #selector(self.defaultsDidChange), name: UserDefaults.didChangeNotification, object: nil)
        reload()
        return true
    }
    
    @objc func defaultsDidChange() {
        self.verid?.faceRecognition.authenticationScoreThreshold = NSNumber(value: UserDefaults.standard.float(forKey: "securityLevel"))
    }
    
    func reload() {
        let veridFactory = VerIDFactory()
        veridFactory.delegate = self
        guard self.verid != nil else {
            veridFactory.createVerID()
            return
        }
        loadMainViewController()
    }
    
    func loadMainViewController() {
        guard let verid = self.verid else {
            reload()
            return
        }
        guard let viewController = (self.window?.rootViewController as? UINavigationController)?.viewControllers.first as? ViewController else {
            return
        }
        viewController.verid = verid
        viewController.scanIdCardButton.isHidden = false
        viewController.activityIndicator.stopAnimating()
    }
    
    func loadErrorViewController(text: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let errorViewController = storyboard.instantiateViewController(withIdentifier: "error") as? ErrorViewController else {
            fatalError()
        }
        errorViewController.labelText = text
        (self.window?.rootViewController as? UINavigationController)?.setViewControllers([errorViewController], animated: false)
    }
    
    func didReceiveReloadRequest(from viewController: ErrorViewController) {
        self.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
        self.reload()
    }
    
    // MARK: - Ver-ID factory delegate
    
    func veridFactory(_ factory: VerIDFactory, didCreateVerID instance: VerID) {
        self.verid = instance
        self.verid?.faceRecognition.authenticationScoreThreshold = NSNumber(value: UserDefaults.standard.float(forKey: "securityLevel"))
        self.loadMainViewController()
    }
    
    func veridFactory(_ factory: VerIDFactory, didFailWithError error: Error) {
        self.loadErrorViewController(text: error.localizedDescription)
    }
    
    // MARK: -
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

