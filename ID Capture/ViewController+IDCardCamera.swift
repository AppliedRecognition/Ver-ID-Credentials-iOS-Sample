//
//  ViewController+IDCardCamera.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 26/10/2021.
//  Copyright © 2021 Applied Recognition Inc. All rights reserved.
//

import UIKit
import IDCardCamera
import RxSwift
import VerIDCore
import Vision

extension ViewController: CardAndBarcodeDetectionViewControllerDelegate {

    func scanCardUsingIDCardCamera() {
        self.documentData = nil
        self.faceTracking = nil
        let settings = CardAndBarcodeDetectionSettings()
        let controller = CardAndBarcodeDetectionViewController(settings: settings)
        if ExecutionParams.isTesting {
            self.testCardDetection(controller: controller)
        } else {
            if #available(iOS 13, *) {
                controller.settings.cardDetectionSettings.imagePoolSize = 10
            }
            controller.delegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: - ID card camera delegate

    func cardAndBarcodeDetectionViewController(_ viewController: CardAndBarcodeDetectionViewController, didDetectCard image: CGImage, andBarcodes barcodes: [VNBarcodeObservation], withSettings settings: CardAndBarcodeDetectionSettings) {
        self.faceTracking = nil
        self.cardImage = UIImage(cgImage: image)
        self.cardAspectRatio = settings.cardDetectionSettings.size.width/settings.cardDetectionSettings.size.height
        BarcodeParser.default.parseBarcodes(barcodes)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { docData in
                self.documentData = docData
                self.detectFaceInImage(image, authenticityDetectionEnabled: AuthenticityScoreSupport.default.isDocumentSupported(docData))
            }, onError: { error in
                self.documentData = nil
                self.detectFaceInImage(image, authenticityDetectionEnabled: false)
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
}
