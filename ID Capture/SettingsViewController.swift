//
//  SettingsViewController.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 12/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit
import VerIDCore

class SettingsViewController: UITableViewController {
    
    static let useBlinkIdKey = "use_blinkid"
    
    @IBOutlet var microblinkSwitch: UISwitch!
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var veridVersionLabel: UILabel!
    @IBOutlet var intellicheckApiKeyTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let useBlinkId = UserDefaults.standard.bool(forKey: SettingsViewController.useBlinkIdKey)
        self.microblinkSwitch.isOn = useBlinkId
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            self.versionLabel.text = version
        } else {
            self.versionLabel.text = "Unknown"
        }
        let bundle = Bundle(for: VerID.self)
        if let veridVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            self.veridVersionLabel.text = veridVersion
        } else {
            self.veridVersionLabel.text = "Unknown"
        }
        // TODO: Get Intellicheck API key from secure key store
    }
    
    @IBAction func toggleMicroblink(_ toggle: UISwitch) {
        UserDefaults.standard.set(toggle.isOn, forKey: SettingsViewController.useBlinkIdKey)
    }
    
    @IBAction func intellicheckApiKeyDidChange(_ textField: UITextField) {
        // TODO: Save Intellicheck API key in secure key store
    }
}
