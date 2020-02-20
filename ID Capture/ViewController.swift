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
    var blinkIdRecognizer: MBBlinkIdCombinedRecognizer?
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
        guard let licenceURLString = Bundle.main.object(forInfoDictionaryKey: "blinkIdLicenceKeyURL") as? String else {
            return
        }
        guard let licenceURL = URL(string: licenceURLString) else {
            return
        }
        DispatchQueue.global().async {
            var key: String
            do {
                let licenceKeyData = try Data(contentsOf: licenceURL)
                guard let licenceKey = String(data: licenceKeyData, encoding: .utf8) else {
                    return
                }
                key = licenceKey
            } catch {
                guard let licenceKey = Bundle.main.object(forInfoDictionaryKey: "blinkIdLicenceKey") as? String else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Failed to retrieve Microblink licence key", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                key = licenceKey
            }
            MBMicroblinkSDK.sharedInstance().setLicenseKey(key)
            DispatchQueue.main.async {
                let recognizer = MBBlinkIdCombinedRecognizer()
                recognizer.returnFullDocumentImage = true
                recognizer.encodeFullDocumentImage = true
                self.blinkIdRecognizer = recognizer
                let settings = MBBlinkIdOverlaySettings()
                settings.autorotateOverlay = true
                let recognizerCollection = MBRecognizerCollection(recognizers: [recognizer])
                let blinkIdOverlayViewController = MBBlinkIdOverlayViewController(settings: settings, recognizerCollection: recognizerCollection, delegate: self)
                let recognizerRunnerViewController = MBViewControllerFactory.recognizerRunnerViewController(withOverlayViewController: blinkIdOverlayViewController)
                self.present(recognizerRunnerViewController, animated: true, completion: nil)
            }
        }
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
        self.parseBarcodes(barcodes).subscribeOn(SerialDispatchQueueScheduler(qos: .default)).observeOn(MainScheduler.instance).subscribe(onSuccess: { docData in
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
                guard let result = self.blinkIdRecognizer?.result, let jpeg = result.encodedFullDocumentFrontImage else {
                    return
                }
                self.cardImage = UIImage(data: jpeg)
                self.documentData = MicroblinkDocumentData(result: result)
                if result.documentDataMatch == .failed {
                    let alert = UIAlertController(title: "Invalid licence", message: "The front and the back of the licence don't seem to match.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Proceed anyway", style: .default, handler: { _ in
                        self.detectFaceInImage(self.cardImage!.cgImage!)
                    }))
                    self.present(alert, animated: true)
                    return
                }
                self.detectFaceInImage(self.cardImage!.cgImage!)
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
                let parser: BarcodeParsing
                if let intellicheckPassword = try SecureStorage.getString(forKey: SecureStorage.commonKeys.intellicheckPassword.rawValue) {
                    parser = IntellicheckBarcodeParser(apiKey: intellicheckPassword)
                } else {
                    parser = AAMVABarcodeParser()
                }
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

