//
//  ViewController+Microblink.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 26/10/2021.
//  Copyright © 2021 Applied Recognition Inc. All rights reserved.
//

import UIKit
import Microblink
import BarcodeDataMatcher

extension ViewController: MBBlinkIdOverlayViewControllerDelegate {
    
    func scanCardUsingMicroblink() {
        let op = MicroblinkSetup()
        op.completionBlock = { [weak op, weak self] in
            guard let `op` = op, let `self` = self else {
                return
            }
            DispatchQueue.main.async {
                guard self.isViewLoaded else {
                    return
                }
                if let error = op.error {
                    let alert = UIAlertController(title: "Failed to retrieve Microblink licence key", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                guard !ExecutionParams.isTesting else {
                    self.testScanCardUsingMicroblink()
                    return
                }
                let recognizer = MBBlinkIdCombinedRecognizer()
                recognizer.returnFullDocumentImage = true
                recognizer.encodeFullDocumentImage = true
                recognizer.returnFaceImage = false
                recognizer.encodeFaceImage = false
                self.blinkIdRecognizer = recognizer
                let settings = MBBlinkIdOverlaySettings()
                settings.autorotateOverlay = true
                let recognizerCollection = MBRecognizerCollection(recognizers: [recognizer])
                let blinkIdOverlayViewController = MBBlinkIdOverlayViewController(settings: settings, recognizerCollection: recognizerCollection, delegate: self)
                guard let recognizerRunnerViewController : UIViewController = MBViewControllerFactory.recognizerRunnerViewController(withOverlayViewController: blinkIdOverlayViewController) else {
                    let alert = UIAlertController(title: "Error", message: "Failed to start scan", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                    self.present(alert, animated: true)
                    return
                }
                self.present(recognizerRunnerViewController, animated: true, completion: nil)
            }
        }
        OperationQueue().addOperation(op)
    }
    
    // MARK: - BlinkID delegate
    
    func blinkIdOverlayViewControllerDidFinishScanning(_ blinkIdOverlayViewController: MBBlinkIdOverlayViewController, state: MBRecognizerResultState) {
        if state == .valid {
            blinkIdOverlayViewController.recognizerRunnerViewController?.pauseScanning()
            DispatchQueue.main.async {
                blinkIdOverlayViewController.dismiss(animated: true, completion: nil)
                self.scanButton.isHidden = true
                self.activityIndicator.startAnimating()
                guard let result = self.blinkIdRecognizer?.result else {
                    let alert = UIAlertController(title: "Card scan failed", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                guard let jpeg = result.encodedFullDocumentFrontImage, let image = UIImage(data: jpeg), let cgImage = image.cgImage else {
                    let alert = UIAlertController(title: "Failed to extract ID card image", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                self.cardImage = image
                if let frontPage = result.frontVizResult, let barcode = result.barcodeResult?.rawData, let dateOfBirth = frontPage.dateOfBirth.date, let dateOfIssue = frontPage.dateOfIssue.date, let dateOfExpiry = frontPage.dateOfExpiry.date {
                    self.frontBackMatchScore = try? DocumentFrontPageData(firstName: frontPage.firstName, lastName: frontPage.lastName, address: frontPage.address, dateOfBirth: dateOfBirth, documentNumber: frontPage.documentNumber, dateOfIssue: dateOfIssue, dateOfExpiry: dateOfExpiry).match(barcode)
                }
                let authenticityDetectionEnabled = AuthenticityScoreSupport.default.isDocumentSupported(result: result)
                if result.documentDataMatch == .failed {
                    let alert = UIAlertController(title: "Invalid licence", message: "The front and the back of the licence don't seem to match.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Proceed anyway", style: .default, handler: { _ in
                        self.detectFaceInImage(cgImage, authenticityDetectionEnabled: authenticityDetectionEnabled)
                    }))
                    self.present(alert, animated: true)
                    return
                }
                if let data = result.barcodeResult?.rawData, let _ = try? SecureStorage.getString(forKey: SecureStorage.commonKeys.intellicheckPassword.rawValue) {
                    BarcodeParser.default.parseBarcodeData(data).subscribe(onSuccess: { docData in
                        self.documentData = docData
                        self.detectFaceInImage(cgImage, authenticityDetectionEnabled: authenticityDetectionEnabled)
                    }, onError: { error in
                        self.documentData = MicroblinkDocumentData(result: result)
                        self.detectFaceInImage(cgImage, authenticityDetectionEnabled: authenticityDetectionEnabled)
                    }).disposed(by: self.disposeBag)
                } else {
                    self.documentData = MicroblinkDocumentData(result: result)
                    self.detectFaceInImage(cgImage, authenticityDetectionEnabled: authenticityDetectionEnabled)
                }
            }
        }
    }
    
    func blinkIdOverlayViewControllerDidTapClose(_ blinkIdOverlayViewController: MBBlinkIdOverlayViewController) {
        blinkIdOverlayViewController.recognizerRunnerViewController?.pauseScanning()
        blinkIdOverlayViewController.dismiss(animated: true, completion: nil)
    }
}

fileprivate class MicroblinkSetup: Operation {
    
    var error: Error?
    
    override func main() {
        guard let licenceURLString = Bundle.main.object(forInfoDictionaryKey: "blinkIdLicenceKeyURL") as? String else {
            return
        }
        guard let licenceURL = URL(string: licenceURLString) else {
            return
        }
        var key: String
        do {
            let licenceKeyData = try Data(contentsOf: licenceURL)
            guard let licenceKey = String(data: licenceKeyData, encoding: .utf8) else {
                return
            }
            key = licenceKey
        } catch {
            guard let licenceKey = Bundle.main.object(forInfoDictionaryKey: "blinkIdLicenceKey") as? String else {
                self.error = MicroblinkSDKError.licenceKeyNotFound
                return
            }
            key = licenceKey
        }
        MBMicroblinkSDK.shared().showTrialLicenseWarning = false
        MBMicroblinkSDK.shared().setLicenseKey(key, errorCallback: { error in
            DispatchQueue.main.async {
                guard let rootVC = UIApplication.shared.delegate?.window??.rootViewController else {
                    return
                }
                let alert = UIAlertController(title: "Error", message: "Failed to set barcode scanner licence key", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    fatalError()
                }))
                rootVC.present(alert, animated: true)
            }
        })
    }
}

enum MicroblinkSDKError: Error {
    case licenceKeyNotFound
}
