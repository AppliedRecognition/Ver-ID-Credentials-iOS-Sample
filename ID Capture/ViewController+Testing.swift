//
//  ViewController+Testing.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 26/10/2021.
//  Copyright © 2021 Applied Recognition Inc. All rights reserved.
//

import UIKit
import IDCardCamera
import Vision
import RxSwift

extension ViewController {
    
    func testCardDetection(controller: CardAndBarcodeDetectionViewController) {
        if ExecutionParams.shouldCancelIDCapture {
            self.cardAndBarcodeDetectionViewControllerDidCancel(controller)
        } else {
            let cardImage: CGImage
            if ExecutionParams.shouldFailDetectingFaceOnIDCard, let img = ExecutionParams.badCardImage {
                cardImage = img
            } else if !ExecutionParams.shouldFailDetectingFaceOnIDCard {
                if ExecutionParams.shouldIDCardBeRotated, let img = ExecutionParams.mockCardImageRotated {
                    controller.settings.cardDetectionSettings.orientation = .portrait
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
            self.cardAndBarcodeDetectionViewController(controller, didDetectCard: cardImage, andBarcodes: barcodes, withSettings: controller.settings)
        }
    }
    
    func testScanCardUsingMicroblink() {
        if !ExecutionParams.shouldCancelIDCapture && ExecutionParams.shouldFailDetectingFaceOnIDCard, let cardImage = ExecutionParams.badCardImage {
            self.detectFaceInImage(cardImage, authenticityDetectionEnabled: false)
        } else if !ExecutionParams.shouldFailDetectingFaceOnIDCard, let cardImage = ExecutionParams.mockCardImage, let barcode = ExecutionParams.mockBarcodeObservation {
            BarcodeParser.default.parseBarcodes([barcode])
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { docData in
                    self.documentData = docData
                    self.detectFaceInImage(cardImage, authenticityDetectionEnabled: AuthenticityScoreSupport.default.isDocumentSupported(docData))
                }, onError: { error in
                    self.documentData = nil
                    self.detectFaceInImage(cardImage, authenticityDetectionEnabled: false)
                })
                .disposed(by: self.disposeBag)
        }
    }
}
