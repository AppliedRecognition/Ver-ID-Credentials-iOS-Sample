//
//  BarcodeScan.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 19/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit
import Microblink

class BarcodeScan: NSObject, MBBlinkIdOverlayViewControllerDelegate {
    
    let viewController: UIViewController
    var delegate: BarcodeScanDelegate?
    private var recognizer: MBUsdlRecognizer?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func startScan() {
        guard let licenceKey = Bundle.main.object(forInfoDictionaryKey: "blinkIdLicenceKey") as? String else {
            return
        }
        MBMicroblinkSDK.shared().setLicenseKey(licenceKey)
        self.recognizer = MBUsdlRecognizer()
        /** Create BlinkID settings */
        let settings : MBBlinkIdOverlaySettings = MBBlinkIdOverlaySettings()
        settings.autorotateOverlay = true
        /** Crate recognizer collection */
        let recognizerCollection : MBRecognizerCollection = MBRecognizerCollection(recognizers: [self.recognizer!])
        /** Create your overlay view controller */
        let blinkIdOverlayViewController : MBBlinkIdOverlayViewController = MBBlinkIdOverlayViewController(settings: settings, recognizerCollection: recognizerCollection, delegate: self)
        /** Create recognizer view controller with wanted overlay view controller */
        guard let recognizerRunneViewController : UIViewController = MBViewControllerFactory.recognizerRunnerViewController(withOverlayViewController: blinkIdOverlayViewController) else {
            let alert = UIAlertController(title: "Error", message: "Failed to start scan", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.viewController.present(alert, animated: true)
            return
        }
        /** Present the recognizer runner view controller. You can use other presentation methods as well (instead of presentViewController) */
        self.viewController.present(recognizerRunneViewController, animated: true, completion: nil)
    }
    
    func blinkIdOverlayViewControllerDidFinishScanning(_ blinkIdOverlayViewController: MBBlinkIdOverlayViewController, state: MBRecognizerResultState) {
        if state == .valid, let result = self.recognizer?.result {
            blinkIdOverlayViewController.recognizerRunnerViewController?.pauseScanning()
            DispatchQueue.main.async {
                blinkIdOverlayViewController.dismiss(animated: true, completion: nil)
                let data = MicroblinkDocumentData(result: result)
                self.delegate?.barcodeScan(self, didScanData: data)
            }
        }
    }
    
    func blinkIdOverlayViewControllerDidTapClose(_ blinkIdOverlayViewController: MBBlinkIdOverlayViewController) {
        blinkIdOverlayViewController.recognizerRunnerViewController?.pauseScanning()
        blinkIdOverlayViewController.dismiss(animated: true, completion: nil)
        self.delegate?.barcodeScanDidCancel(self)
    }
    
}

protocol BarcodeScanDelegate: class {
    func barcodeScan(_ barcodeScan: BarcodeScan, didScanData data: MicroblinkDocumentData)
    func barcodeScanDidCancel(_ barcodeScan: BarcodeScan)
}
