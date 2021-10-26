//
//  ViewController.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 11/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit
import VerIDCore
import RxSwift
import Microblink
import AAMVABarcodeParser

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var blinkIdRecognizer: MBBlinkIdCombinedRecognizer?
    var cardImage: UIImage?
    var cardFace: RecognizableFace?
    var cardAspectRatio: CGFloat?
    var authenticityScore: Float?
    var frontBackMatchScore: Float?
    var documentData: DocumentData?
    var faceTracking: FaceTracking?
    var verid: VerID?
    
    @IBOutlet var scanButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        self.scanButton.isHidden = true
        self.loadVerID()
    }
    
    @IBAction func scanIDCard() {
        let useBlinkId = UserDefaults.standard.bool(forKey: SettingsViewController.useBlinkIdKey)
        self.frontBackMatchScore = nil
        if useBlinkId {
            scanCardUsingMicroblink()
        } else {
            scanCardUsingIDCardCamera()
        }
    }
    
    // MARK: - Face detection
    
    func detectFaceInImage(_ image: CGImage, authenticityDetectionEnabled: Bool) {
        self.scanButton.isHidden = true
        self.activityIndicator.startAnimating()
        self.authenticityScore = nil
        guard let verID = self.verid else {
            return
        }
        let faceDetection = FaceDetection(verID: verID)
        faceDetection.detectFaceInImage(image, detectImageAuthenticity: authenticityDetectionEnabled).subscribe(onSuccess: { face, orientation, authenticityScore in
            if let aspectRatio = self.cardAspectRatio, (orientation == .left || orientation == .right) {
                self.cardAspectRatio = 1.0/aspectRatio
            }
            self.cardImage = UIImage(cgImage: image, scale: 1, orientation: orientation.uiImageOrientation)
            self.scanButton.isHidden = false
            self.activityIndicator.stopAnimating()
            self.cardFace = face
            self.authenticityScore = authenticityScore
            self.performSegue(withIdentifier: "selfie", sender: nil)
        }, onError: { error in
            self.scanButton.isHidden = false
            self.activityIndicator.stopAnimating()
            let alert = UIAlertController(title: "Error", message: "Failed to find a face on the ID card", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }).disposed(by: self.disposeBag)
    }
    
    // MARK: -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CardViewController {
            destination.verid = self.verid
            destination.cardImage = self.cardImage
            destination.cardFace = self.cardFace
            destination.cardAspectRatio = self.cardAspectRatio
            destination.documentData = self.documentData
            destination.authenticityScore = self.authenticityScore
            destination.frontBackMatchScore = self.frontBackMatchScore
        } else if let destination = segue.destination as? SupportedDocumentsViewController, let url = sender as? URL {
            destination.url = url
        }
    }
}

// MARK: - Ver-ID

extension ViewController: VerIDFactoryDelegate {
    
    func loadVerID() {
        let veridFactory = VerIDFactory()
        let detRecFactory = VerIDFaceDetectionRecognitionFactory(apiSecret: nil)
        detRecFactory.settings.faceExtractQualityThreshold = 4.0
        let authenticityClassifiers = AuthenticityScoreSupport.default.classifiers
        if !authenticityClassifiers.isEmpty {
            detRecFactory.additionalFaceClassifiers.append(contentsOf: authenticityClassifiers)
        }
        veridFactory.faceDetectionFactory = detRecFactory
        veridFactory.faceRecognitionFactory = detRecFactory
        veridFactory.delegate = self
        veridFactory.createVerID()
    }
    
    // MARK: VerIDFactoryDelegate
    
    func veridFactory(_ factory: VerIDFactory, didCreateVerID instance: VerID) {
        self.verid = instance
        self.scanButton.isHidden = false
        self.activityIndicator.stopAnimating()
    }
    
    func veridFactory(_ factory: VerIDFactory, didFailWithError error: Error) {
        self.activityIndicator.stopAnimating()
        let alert = UIAlertController(title: "Failed to load Ver-ID", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
