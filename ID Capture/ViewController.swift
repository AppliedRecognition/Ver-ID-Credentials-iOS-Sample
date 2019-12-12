//
//  ViewController.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 11/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit
import IDCardCamera
import VerIDCore
import RxVerID
import RxSwift
import Microblink

class ViewController: UIViewController, CardDetectionViewControllerDelegate, MBBlinkIdOverlayViewControllerDelegate {
    
    let disposeBag = DisposeBag()
    var blinkIdRecognizer: MBSuccessFrameGrabberRecognizer?
    var cardImage: UIImage?
    var cardFace: RecognizableFace?
    var cardAspectRatio: CGFloat?
    var documentData: DocumentData?
    
    @IBOutlet var scanButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func scanIDCard() {
        let useBlinkId = UserDefaults.standard.bool(forKey: SettingsViewController.useBlinkIdKey)
        if useBlinkId {
            scanCardUsingMicroblink()
        } else {
            scanCardUsingIDCardCamera()
        }
    }
    
    func scanCardUsingIDCardCamera() {
        self.documentData = nil
        let controller = CardDetectionViewController()
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    func scanCardUsingMicroblink() {
        guard let licenceKey = Bundle.main.object(forInfoDictionaryKey: "blinkIdLicenceKey") as? String else {
            return
        }
        MBMicroblinkSDK.sharedInstance().setLicenseKey(licenceKey)
        let alert = UIAlertController(title: "Select issuing region", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "USA and Canada*", style: .default, handler: { _ in
            let recognizer = MBUsdlCombinedRecognizer()
            recognizer.encodeFullDocumentImage = true
            self.scanCardUsingMicroblinkRecognizer(recognizer)
        }))
        alert.addAction(UIAlertAction(title: "Other*", style: .default, handler: { _ in
            let recognizer = MBBlinkIdCombinedRecognizer()
            recognizer.encodeFullDocumentImage = true
            self.scanCardUsingMicroblinkRecognizer(recognizer)
        }))
        alert.addAction(UIAlertAction(title: "*View supported documents", style: .default, handler: { _ in
            guard let url = URL(string: "https://github.com/BlinkID/blinkid-ios/blob/master/documentation/BlinkIDRecognizer.md") else {
                return
            }
            self.performSegue(withIdentifier: "documents", sender: url)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func scanCardUsingMicroblinkRecognizer(_ recognizer: MBRecognizer) {
        self.documentData = nil
        self.blinkIdRecognizer = MBSuccessFrameGrabberRecognizer(recognizer: recognizer)
        /** Create BlinkID settings */
        let settings : MBBlinkIdOverlaySettings = MBBlinkIdOverlaySettings()
        settings.autorotateOverlay = true
        /** Crate recognizer collection */
        let recognizerCollection : MBRecognizerCollection = MBRecognizerCollection(recognizers: [self.blinkIdRecognizer!])
        /** Create your overlay view controller */
        let blinkIdOverlayViewController : MBBlinkIdOverlayViewController = MBBlinkIdOverlayViewController(settings: settings, recognizerCollection: recognizerCollection, delegate: self)
        /** Create recognizer view controller with wanted overlay view controller */
        let recognizerRunneViewController : UIViewController = MBViewControllerFactory.recognizerRunnerViewController(withOverlayViewController: blinkIdOverlayViewController)
        /** Present the recognizer runner view controller. You can use other presentation methods as well (instead of presentViewController) */
        self.present(recognizerRunneViewController, animated: true, completion: nil)
    }
    
    // MARK: - Face detection
    
    func detectFaceInImage(_ image: CGImage) {
        self.scanButton.isHidden = true
        self.activityIndicator.startAnimating()
        let veridImage = VerIDImage(cgImage: image, orientation: .up)
        rxVerID.detectRecognizableFacesInImage(veridImage, limit: 1)
        .asSingle()
        .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
        .observeOn(MainScheduler.instance)
        .subscribe(onSuccess: { face in
            self.scanButton.isHidden = false
            self.activityIndicator.stopAnimating()
            self.cardFace = face
            self.performSegue(withIdentifier: "selfie", sender: nil)
        }, onError: { error in
            self.scanButton.isHidden = false
            self.activityIndicator.stopAnimating()
            let alert = UIAlertController(title: "Error", message: "Failed to find a face on the ID card", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }).disposed(by: self.disposeBag)
    }
    
    // MARK: - ID card camera delegate
    
    func cardDetectionViewController(_ viewController: CardDetectionViewController, didDetectCard image: CGImage, withSettings settings: CardDetectionSettings) {
        self.cardImage = UIImage(cgImage: image)
        self.cardAspectRatio = settings.size.width/settings.size.height
        self.detectFaceInImage(image)
    }
    
    // MARK: - BlinkID delegate
    
    func blinkIdOverlayViewControllerDidFinishScanning(_ blinkIdOverlayViewController: MBBlinkIdOverlayViewController, state: MBRecognizerResultState) {
        if state == .valid {
            blinkIdOverlayViewController.recognizerRunnerViewController?.pauseScanning()
            DispatchQueue.main.async {
                blinkIdOverlayViewController.dismiss(animated: true, completion: nil)
                if let result = (self.blinkIdRecognizer?.slaveRecognizer as? MBBlinkIdCombinedRecognizer)?.result, let jpeg = result.encodedFullDocumentFrontImage {
                    self.cardImage = UIImage(data: jpeg)
                    self.documentData = DocumentData(result: result)
                    self.detectFaceInImage(self.cardImage!.cgImage!)
                } else if let result = (self.blinkIdRecognizer?.slaveRecognizer as? MBUsdlCombinedRecognizer)?.result, let jpeg = result.encodedFullDocumentImage {
                    self.cardImage = UIImage(data: jpeg)
                    self.documentData = DocumentData(result: result)
                    self.detectFaceInImage(self.cardImage!.cgImage!)
                }
            }
        }
    }
    
    func blinkIdOverlayViewControllerDidTapClose(_ blinkIdOverlayViewController: MBBlinkIdOverlayViewController) {
        blinkIdOverlayViewController.recognizerRunnerViewController?.pauseScanning()
        blinkIdOverlayViewController.dismiss(animated: true, completion: nil)
    }
    
    // MARK: -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CardViewController {
            destination.cardImage = self.cardImage
            destination.cardFace = self.cardFace
            destination.cardAspectRatio = self.cardAspectRatio
            destination.documentData = self.documentData
        } else if let destination = segue.destination as? SupportedDocumentsViewController, let url = sender as? URL {
            destination.url = url
        }
    }
}

