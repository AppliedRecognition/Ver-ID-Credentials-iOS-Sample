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
    @IBOutlet var testButton: UIButton!
    @IBOutlet var passwordCheckActivityIndicator: UIActivityIndicatorView!

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
        do {
            if let intellicheckPassword = try SecureStorage.getString(forKey: SecureStorage.commonKeys.intellicheckPassword.rawValue) {
                self.intellicheckApiKeyTextField.text = intellicheckPassword
                self.testButton.isEnabled = true
            }
        } catch {
            
        }
    }
    
    @IBAction func toggleMicroblink(_ toggle: UISwitch) {
        UserDefaults.standard.set(toggle.isOn, forKey: SettingsViewController.useBlinkIdKey)
    }
    
    @IBAction func intellicheckApiKeyDidChange(_ textField: UITextField) {
        if let newPassword = textField.text, !newPassword.isEmpty {
            self.testButton.isEnabled = true
            try? SecureStorage.setString(newPassword, forKey: SecureStorage.commonKeys.intellicheckPassword.rawValue)
        } else {
            self.testButton.isEnabled = false
            try? SecureStorage.deleteValue(forKey: SecureStorage.commonKeys.intellicheckPassword.rawValue)
        }
    }
    
    @IBAction func testIntellicheckPassword() {
        self.passwordCheckActivityIndicator.startAnimating()
        self.testButton.alpha = 0
        self.intellicheckApiKeyTextField.isEnabled = false
        self.testButton.isEnabled = false
        guard let password = self.intellicheckApiKeyTextField.text else {
            self.showIntellicheckPasswordCheckResponse("Password is empty", isFailure: true)
            return
        }
        guard let url = URL(string: "https://dev.ver-id.com/id-check/check-password") else {
            self.showIntellicheckPasswordCheckResponse("Failed to create request URL", isFailure: true)
            return
        }
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            self.showIntellicheckPasswordCheckResponse("Unknown device ID", isFailure: true)
            return
        }
        guard let appId = Bundle.main.bundleIdentifier else {
            self.showIntellicheckPasswordCheckResponse("Missing app ID", isFailure: true)
            return
        }
        guard let data = [
                "device_id": deviceId,
                "app_id": appId,
                "password": password
            ].map({ $0+"="+$1 }).joined(separator: "&").data(using: .utf8) else {
            self.showIntellicheckPasswordCheckResponse("Failed to serialize request data", isFailure: true)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let session = URLSession(configuration: .ephemeral)
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                self.showIntellicheckPasswordCheckResponse("Error checking password: \(error!.localizedDescription)", isFailure: true)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                self.showIntellicheckPasswordCheckResponse("Unknown error", isFailure: true)
                return
            }
            if statusCode == 200 {
                self.showIntellicheckPasswordCheckResponse("Password OK", isFailure: false)
            } else if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                self.showIntellicheckPasswordCheckResponse(responseString, isFailure: true)
            } else {
                self.showIntellicheckPasswordCheckResponse("Unknown error (status code \(statusCode))", isFailure: true)
            }
        }
        task.resume()
    }
    
    private func showIntellicheckPasswordCheckResponse(_ response: String, isFailure: Bool) {
        DispatchQueue.main.async {
            self.testButton.alpha = 1
            self.intellicheckApiKeyTextField.isEnabled = true
            self.testButton.isEnabled = self.intellicheckApiKeyTextField.text != nil
            self.passwordCheckActivityIndicator.stopAnimating()
            let alert = UIAlertController(title: isFailure ? "Error" : "Success", message: response, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
}
