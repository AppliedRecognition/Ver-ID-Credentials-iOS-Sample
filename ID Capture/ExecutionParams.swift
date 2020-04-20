//
//  ExecutionParams.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 20/04/2020.
//  Copyright © 2020 Applied Recognition Inc. All rights reserved.
//

import UIKit
import Microblink
import VerIDCore
import Vision

class ExecutionParams {
    
    static var isTesting: Bool {
        return CommandLine.arguments.contains("--test")
    }
    
    static var shouldFailLivenessDetection: Bool {
        return CommandLine.arguments.contains("--failLivenessDetection")
    }
    
    static var shouldCancelIDCapture: Bool {
        return CommandLine.arguments.contains("--cancelIDCapture")
    }
    
    static var shouldFailDetectingFaceOnIDCard: Bool {
        return CommandLine.arguments.contains("--failFaceOnIDCard")
    }
    
    static var shouldIDCardFaceBeLowQuality: Bool {
        return CommandLine.arguments.contains("--lowQualityCardFace")
    }
    
    static var mockCardImage: CGImage? {
        if let url = Bundle(for: ExecutionParams.self).url(forResource: "cardImage", withExtension: "png", subdirectory: "Test resources"), let imageData = try? Data(contentsOf: url) {
            return UIImage(data: imageData)?.cgImage
        }
        return nil
    }
    
    static var badCardImage: CGImage? {
        let size = CGSize(width: 800, height: 500)
        UIGraphicsBeginImageContext(size)
        defer {
            UIGraphicsEndImageContext()
        }
        UIColor.gray.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()?.cgImage
    }
    
    static var mockBarcodeObservation: VNBarcodeObservation? {
        if let url = Bundle(for: ExecutionParams.self).url(forResource: "barcode", withExtension: "txt", subdirectory: "Test resources"), let barcodeData = try? Data(contentsOf: url), let barcodeString = String(data: barcodeData, encoding: .utf8) {
            return TestBarcodeObservation(payload: barcodeString)
        }
        return nil
    }
    
    static var selfieURL: URL? {
        return Bundle(for: ExecutionParams.self).url(forResource: "selfieImage", withExtension: "jpg", subdirectory: "Test resources")
    }
}
