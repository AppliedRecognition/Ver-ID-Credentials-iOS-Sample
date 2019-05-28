//
//  ViewController.swift
//  VerIDIDCaptureTest
//
//  Created by Jakub Dolejs on 26/10/2016.
//  Copyright © 2016 Applied Recognition, Inc. All rights reserved.
//

import UIKit
import VerIDCredentials
import VerIDCore
import VerIDUI

class ViewController: UIViewController, IDCaptureSessionDelegate, CardPropertiesViewControllerDelegate {
    
    // MARK: -
    
    @IBOutlet var scanIdCardButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var verid: VerID?
    
    func idCaptureSession(_ session: IDCaptureSession, didCaptureIDDocument document: IDDocument) {
        self.performSegue(withIdentifier: "selfie", sender: document)
    }
    
    func idCaptureSession(_ session: IDCaptureSession, didFailWithError error: Error) {
        let alert = UIAlertController(title: "ID capture session failed", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func didCancelIDCaptureSession(_ session: IDCaptureSession) {
        
    }
    
    func cardPropertiesViewController(_ viewController: CardPropertiesViewController, didSelectIDDocument document: IDDocument) {
        self.navigationController?.popToRootViewController(animated: false)
        guard let verid = self.verid else {
            return
        }
        let settings = IDCaptureSessionSettings()
        settings.document = document
        settings.showResult = true
        settings.showGuide = true
        settings.detectFaceForRecognition = true
        let session = IDCaptureSession(environment: verid, settings: settings)
        if UserDefaults.standard.bool(forKey: "intellicheck") {
            let barcodeParserFactory = BarcodeParserFactory(useIntellicheck: true)
            session.viewControllersFactory = DefaultIDCaptureSessionViewControllersFactory(environment: verid, barcodeParserFactory: barcodeParserFactory)
        }
        session.delegate = self
        session.start()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? CardViewController, let document = sender as? IDDocument {
            controller.idDocument = document
            controller.verid = self.verid
        } else if let controller = segue.destination as? CardPropertiesViewController {
            controller.delegate = self
        }
    }
}
