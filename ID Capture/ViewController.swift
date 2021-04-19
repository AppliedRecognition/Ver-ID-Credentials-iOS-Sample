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
import RxSwift
import Microblink
import Vision
import AAMVABarcodeParser
import os.signpost

class ViewController: UIViewController, VerIDFactoryDelegate, CardAndBarcodeDetectionViewControllerDelegate, MBBlinkIdOverlayViewControllerDelegate {
    
    let disposeBag = DisposeBag()
    var blinkIdRecognizer: MBBlinkIdCombinedRecognizer?
    var cardImage: UIImage?
    var cardFaceImage: UIImage?
    var cardFace: RecognizableFace?
    var cardAspectRatio: CGFloat?
    var documentData: DocumentData?
    var faceTracking: FaceTracking?
    
    lazy var log: OSLog = {
        OSLog(subsystem: "com.appliedrec.ID-Capture", category: "Face detection")
    }()
    
    @IBOutlet var scanButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        self.scanButton.isHidden = true
        let veridFactory = VerIDFactory()
        let detRecFactory = VerIDFaceDetectionRecognitionFactory(apiSecret: nil)
        detRecFactory.settings.faceExtractQualityThreshold = 5.0
        veridFactory.faceDetectionFactory = detRecFactory
        veridFactory.faceRecognitionFactory = detRecFactory
        veridFactory.delegate = self
        veridFactory.createVerID()
    }
    
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
        self.startCardDetection()
    }
    
    func startCardDetection() {
        let settings = CardAndBarcodeDetectionSettings()
        let controller = CardAndBarcodeDetectionViewController(settings: settings)
        if ExecutionParams.isTesting {
            if ExecutionParams.shouldCancelIDCapture {
                self.cardAndBarcodeDetectionViewControllerDidCancel(controller)
            } else {
                let cardImage: CGImage
                if ExecutionParams.shouldFailDetectingFaceOnIDCard, let img = ExecutionParams.badCardImage {
                    cardImage = img
                } else if !ExecutionParams.shouldFailDetectingFaceOnIDCard {
                    if ExecutionParams.shouldIDCardBeRotated, let img = ExecutionParams.mockCardImageRotated {
                        settings.cardDetectionSettings.orientation = .portrait
                        cardImage = img
                    } else if !ExecutionParams.shouldIDCardBeRotated, let img = ExecutionParams.mockCardImage {
                        cardImage = img
                    } else {
                        return
                    }
                } else {
                    return
                }
                let barcodes: [VNBarcodeObservation]
                if let barcode = ExecutionParams.mockBarcodeObservation {
                    barcodes = [barcode]
                } else {
                    barcodes = []
                }
                self.cardAndBarcodeDetectionViewController(controller, didDetectCard: cardImage, andBarcodes: barcodes, withSettings: settings)
            }
        } else {
            if #available(iOS 13, *) {
                controller.settings.cardDetectionSettings.imagePoolSize = 10
            }
            controller.delegate = self
            self.present(controller, animated: true, completion: nil)
        }
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
            MBMicroblinkSDK.shared().setLicenseKey(key, errorCallback: { error in
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Failed to set barcode scanner licence key", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self.dismiss(animated: true)
                    }))
                    self.present(alert, animated: true)
                }
            })
            DispatchQueue.main.async {
                if ExecutionParams.isTesting {
                    if !ExecutionParams.shouldCancelIDCapture && ExecutionParams.shouldFailDetectingFaceOnIDCard, let cardImage = ExecutionParams.badCardImage {
                        self.detectFaceInImage(cardImage)
                    } else if !ExecutionParams.shouldFailDetectingFaceOnIDCard, let cardImage = ExecutionParams.mockCardImage, let barcode = ExecutionParams.mockBarcodeObservation {
                        self.parseBarcodes([barcode])
                            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                            .observeOn(MainScheduler.instance)
                            .subscribe(onSuccess: { docData in
                                self.documentData = docData
                                self.detectFaceInImage(cardImage)
                            }, onError: { error in
                                self.documentData = nil
                                self.detectFaceInImage(cardImage)
                            })
                            .disposed(by: self.disposeBag)
                    }
                } else {
                    let recognizer = MBBlinkIdCombinedRecognizer()
                    recognizer.returnFullDocumentImage = true
                    recognizer.encodeFullDocumentImage = true
                    recognizer.returnFaceImage = true
                    recognizer.encodeFaceImage = true
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
        }
    }
    
    // MARK: - VerIDFactoryDelegate
    
    func veridFactory(_ factory: VerIDFactory, didCreateVerID instance: VerID) {
        Globals.veridCard = instance
        self.scanButton.isHidden = false
        self.activityIndicator.stopAnimating()
    }
    
    func veridFactory(_ factory: VerIDFactory, didFailWithError error: Error) {
        self.activityIndicator.stopAnimating()
        let alert = UIAlertController(title: "Failed to load Ver-ID", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
    
    func detectFaceInImage(_ image: CGImage, croppedFaceImage: CGImage? = nil) {
        self.scanButton.isHidden = true
        self.activityIndicator.startAnimating()
        
        Single<(RecognizableFace,CGImagePropertyOrientation)>.create(subscribe: { emitter in
            do {
                let orientations: [CGImagePropertyOrientation] = [.up, .left, .right, .down]
                for orientation in orientations {
                    let veridImage = VerIDImage(cgImage: croppedFaceImage ?? image, orientation: orientation)
                    guard let face = try Globals.veridCard?.faceDetection.detectFacesInImage(veridImage, limit: 1, options: 0).first else {
                        continue
                    }
                    guard let recognizable = try Globals.veridCard?.faceRecognition.createRecognizableFacesFromFaces([face], inImage: veridImage).first else {
                        continue
                    }
                    let recognizableFace = RecognizableFace(face: face, recognitionData: recognizable.recognitionData, version: recognizable.version)
                    if ExecutionParams.shouldIDCardFaceBeLowQuality {
                        recognizableFace.quality = 5.0
                    }
                    emitter(.success((recognizableFace, orientation)))
                    return Disposables.create()
                }
                emitter(.error(NSError()))
            } catch {
                emitter(.error(error))
            }
            return Disposables.create()
        })
        .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
        .observeOn(MainScheduler.instance)
        .subscribe(onSuccess: { face, orientation in
            if let aspectRatio = self.cardAspectRatio, (orientation == .left || orientation == .right) {
                self.cardAspectRatio = 1.0/aspectRatio
            }
            self.cardImage = UIImage(cgImage: image, scale: 1, orientation: self.uiImageOrientationFromCGImageOrientation(orientation))
            self.scanButton.isHidden = false
            self.activityIndicator.stopAnimating()
            self.cardFace = face
            if let cardFaceImage = croppedFaceImage {
                self.cardFaceImage = UIImage(cgImage: cardFaceImage, scale: 1, orientation: self.uiImageOrientationFromCGImageOrientation(orientation))
            } else {
                self.cardFaceImage = nil
            }
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
        self.parseBarcodes(barcodes)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { docData in
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
        guard let verid = Globals.verid else {
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
                if let faceImageJpeg = result.encodedFaceImage, let faceImage = UIImage(data: faceImageJpeg) {
                    self.cardFaceImage = faceImage
                } else {
                    self.cardFaceImage = nil
                }
                if result.documentDataMatch == .failed {
                    let alert = UIAlertController(title: "Invalid licence", message: "The front and the back of the licence don't seem to match.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Proceed anyway", style: .default, handler: { _ in
                        self.detectFaceInImage(cgImage, croppedFaceImage: cgImage)
                    }))
                    self.present(alert, animated: true)
                    return
                }
                if let data = result.barcodeResult?.rawData, let _ = try? SecureStorage.getString(forKey: SecureStorage.commonKeys.intellicheckPassword.rawValue) {
                    self.parseBarcodeData(data).subscribe(onSuccess: { docData in
                        self.documentData = docData
                        self.detectFaceInImage(cgImage, croppedFaceImage: self.cardFaceImage?.cgImage)
                    }, onError: { error in
                        self.documentData = MicroblinkDocumentData(result: result)
                        self.detectFaceInImage(cgImage, croppedFaceImage: self.cardFaceImage?.cgImage)
                    }).disposed(by: self.disposeBag)
                } else {
                    self.documentData = MicroblinkDocumentData(result: result)
                    self.detectFaceInImage(cgImage, croppedFaceImage: self.cardFaceImage?.cgImage)
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
        return Single<Data>.create(subscribe: { event in
            do {
                guard let barcodeData = barcodes.first?.payloadStringValue?.data(using: .utf8) else {
                    throw BarcodeParserError.emptyDocument
                }
                event(.success(barcodeData))
            } catch {
                event(.error(error))
            }
            return Disposables.create()
        }).flatMap({ data in
            self.parseBarcodeData(data)
        }).subscribeOn(SerialDispatchQueueScheduler(qos: .default)).observeOn(MainScheduler.instance)
    }
    
    private func parseBarcodeData(_ barcodeData: Data) -> Single<DocumentData> {
        return Single<DocumentData>.create(subscribe: { event in
            do {
                let parser: BarcodeParsing
                if !ExecutionParams.isTesting, let intellicheckPassword = try SecureStorage.getString(forKey: SecureStorage.commonKeys.intellicheckPassword.rawValue) {
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
            destination.cardFaceImage = self.cardFaceImage
            destination.cardAspectRatio = self.cardAspectRatio
            destination.documentData = self.documentData
        } else if let destination = segue.destination as? SupportedDocumentsViewController, let url = sender as? URL {
            destination.url = url
        }
    }
}
