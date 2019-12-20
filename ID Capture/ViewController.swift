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
import Vision
import AAMVABarcodeParser

class ViewController: UIViewController, CardAndBarcodeDetectionViewControllerDelegate, MBBlinkIdOverlayViewControllerDelegate {
    
    let disposeBag = DisposeBag()
    var blinkIdRecognizer: MBSuccessFrameGrabberRecognizer?
    var cardImage: UIImage?
    var cardFace: RecognizableFace?
    var cardAspectRatio: CGFloat?
    var documentData: DocumentData?
    var verid: VerID?
    var faceTracking: FaceTracking?
    
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
        self.faceTracking = nil
        if #available(iOS 13, *) {
            self.startCardDetection()
            return
        }
        self.scanButton.isHidden = true
        self.activityIndicator.startAnimating()
        rxVerID.verid.subscribeOn(SerialDispatchQueueScheduler(qos: .default)).observeOn(MainScheduler.instance).subscribe(onSuccess: { verid in
            self.verid = verid
            self.startCardDetection()
            self.scanButton.isHidden = false
            self.activityIndicator.stopAnimating()
        }, onError: { error in
            let alert = UIAlertController(title: "Failed to load Ver-ID", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }).disposed(by: self.disposeBag)
    }
    
    func startCardDetection() {
        let settings = CardAndBarcodeDetectionSettings()
        let controller = CardAndBarcodeDetectionViewController(settings: settings)
        if #available(iOS 13, *) {
            controller.settings.cardDetectionSettings.imagePoolSize = 10
        }
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    func scanCardUsingMicroblink() {
        guard let licenceKey = Bundle.main.object(forInfoDictionaryKey: "blinkIdLicenceKey") as? String else {
            return
        }
        MBMicroblinkSDK.sharedInstance().setLicenseKey(licenceKey)
        let alert = self.createRegionSelectionAlert()
        self.present(alert, animated: true, completion: nil)
    }
    
    func createRegionSelectionAlert() -> UIAlertController {
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
        return alert
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
    
    func uiImageOrientationFromCGImageOrientation(_ orientation: CGImagePropertyOrientation) -> UIImage.Orientation {
        switch orientation {
        case .up:
            return .up
        case .left:
            return .left
        case .right:
            return .right
        case .down:
            return .down
        case .upMirrored:
            return .upMirrored
        case .leftMirrored:
            return .leftMirrored
        case .rightMirrored:
            return .rightMirrored
        case .downMirrored:
            return .downMirrored
        default:
            return .up
        }
    }
    
    func detectFaceInImage(_ image: CGImage) {
        self.scanButton.isHidden = true
        self.activityIndicator.startAnimating()
        let images: [VerIDImage] = [
            VerIDImage(cgImage: image, orientation: .up),
            VerIDImage(cgImage: image, orientation: .left),
            VerIDImage(cgImage: image, orientation: .right),
            VerIDImage(cgImage: image, orientation: .down)
        ]
        Observable.from(images).flatMap({ veridImage in
            rxVerID.detectRecognizableFacesInImage(veridImage, limit: 1).map({ face in
                return (face,veridImage.orientation)
            })
        })
        .take(1)
        .asSingle()
        .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
        .observeOn(MainScheduler.instance)
        .subscribe(onSuccess: { (face,orientation) in
            if let aspectRatio = self.cardAspectRatio, (orientation == .left || orientation == .right) {
                self.cardAspectRatio = 1.0/aspectRatio
            }
            self.cardImage = UIImage(cgImage: image, scale: 1, orientation: self.uiImageOrientationFromCGImageOrientation(orientation))
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
    
    func cardAndBarcodeDetectionViewController(_ viewController: CardAndBarcodeDetectionViewController, didDetectCard image: CGImage, andBarcodes barcodes: [VNBarcodeObservation], withSettings settings: CardAndBarcodeDetectionSettings) {
        self.faceTracking = nil
        self.cardImage = UIImage(cgImage: image)
        self.cardAspectRatio = settings.cardDetectionSettings.size.width/settings.cardDetectionSettings.size.height
        self.parseBarcodes(barcodes).subscribe(onSuccess: { docData in
            self.documentData = docData
            self.detectFaceInImage(image)
        }, onError: { error in
            self.documentData = nil
            self.detectFaceInImage(image)
        }).disposed(by: self.disposeBag)
    }
    
    func cardAndBarcodeDetectionViewControllerDidCancel(_ viewController: CardAndBarcodeDetectionViewController) {
        self.faceTracking = nil
    }
    
    func qualityOfImage(_ image: CGImage) -> NSNumber? {
        if #available(iOS 13, *) {
            // Use the built-in image sharpness detection to determine the image quality
            return nil
        }
        guard let verid = self.verid else {
            return nil
        }
        let faceTracking = self.faceTracking ?? verid.faceDetection.startFaceTracking()
        do {
            let face = try faceTracking.trackFaceInImage(VerIDImage(cgImage: image, orientation: .up))
            // Use the detected face quality as image quality
            return NSNumber(value: Float(face.quality))
        } catch {
            // Set image quality to 0 (no face found)
            return NSNumber(value: 0)
        }
    }
    
    // MARK: - BlinkID delegate
    
    func blinkIdOverlayViewControllerDidFinishScanning(_ blinkIdOverlayViewController: MBBlinkIdOverlayViewController, state: MBRecognizerResultState) {
        if state == .valid {
            blinkIdOverlayViewController.recognizerRunnerViewController?.pauseScanning()
            DispatchQueue.main.async {
                blinkIdOverlayViewController.dismiss(animated: true, completion: nil)
                if let result = (self.blinkIdRecognizer?.slaveRecognizer as? MBBlinkIdCombinedRecognizer)?.result, let jpeg = result.encodedFullDocumentFrontImage {
                    self.cardImage = UIImage(data: jpeg)
                    self.documentData = MicroblinkDocumentData(result: result)
                    self.detectFaceInImage(self.cardImage!.cgImage!)
                } else if let result = (self.blinkIdRecognizer?.slaveRecognizer as? MBUsdlCombinedRecognizer)?.result, let jpeg = result.encodedFullDocumentImage {
                    self.cardImage = UIImage(data: jpeg)
                    self.documentData = MicroblinkDocumentData(result: result)
                    self.detectFaceInImage(self.cardImage!.cgImage!)
                }
            }
        }
    }
    
    func blinkIdOverlayViewControllerDidTapClose(_ blinkIdOverlayViewController: MBBlinkIdOverlayViewController) {
        blinkIdOverlayViewController.recognizerRunnerViewController?.pauseScanning()
        blinkIdOverlayViewController.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Barcode parsing
    
    private func parseBarcodes(_ barcodes: [VNBarcodeObservation]) -> Single<DocumentData> {
        return Single<DocumentData>.create(subscribe: { event in
            do {
                guard let barcodeData = barcodes.first?.payloadStringValue?.data(using: .utf8) else {
                    throw BarcodeParserError.emptyDocument
                }
                // TODO: Get Intellicheck API key from secure store and if it exists use intellicheck parser. Otherwise use ours.
                let parser = AAMVABarcodeParser()
                let docData = try parser.parseData(barcodeData)
                event(.success(docData))
            } catch {
                event(.error(error))
            }
            return Disposables.create()
        }).subscribeOn(SerialDispatchQueueScheduler(qos: .default)).observeOn(MainScheduler.instance)
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

