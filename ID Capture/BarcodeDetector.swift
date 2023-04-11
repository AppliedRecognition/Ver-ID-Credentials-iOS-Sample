//
//  BarcodeDetector.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 11/04/2023.
//

import Foundation
import UIKit
import Vision

class BarcodeDetector {
    
    static let shared = BarcodeDetector()
    
    private init() {}
    
    func detectBarcodeInImage(_ image: UIImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let request = VNDetectBarcodesRequest { request, error in
                    if let err = error {
                        continuation.resume(throwing: err)
                        return
                    }
                    if let payload = request.results?.compactMap({ ($0 as? VNBarcodeObservation)?.payloadStringValue }).first(where: { !$0.isEmpty }) {
                        continuation.resume(returning: payload)
                    } else {
                        continuation.resume(throwing: BarcodeDetectorError.failedToReadBarcode)
                    }
                }
                let symbologies = try request.supportedSymbologies()
                if #available(iOS 15, *) {
                    guard symbologies.contains(.pdf417) else {
                        throw BarcodeDetectorError.unsupportedBarcodeFormat
                    }
                    request.symbologies = [.pdf417]
                } else {
                    guard symbologies.contains(.PDF417) else {
                        throw BarcodeDetectorError.unsupportedBarcodeFormat
                    }
                    request.symbologies = [.PDF417]
                }
                let requestHandler: VNImageRequestHandler
                if let cgImage = image.cgImage {
                    requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: self.cgImageOrientationFromUIImageOrientation(image.imageOrientation))
                } else if let ciImage = image.ciImage {
                    requestHandler = VNImageRequestHandler(ciImage: ciImage, orientation: self.cgImageOrientationFromUIImageOrientation(image.imageOrientation))
                } else {
                    throw BarcodeDetectorError.imageConversionError
                }
                try requestHandler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func cgImageOrientationFromUIImageOrientation(_ orientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch orientation {
        case .up:
            return .up
        case .right:
            return .right
        case .down:
            return .down
        case .left:
            return .left
        case .upMirrored:
            return .upMirrored
        case .rightMirrored:
            return .rightMirrored
        case .downMirrored:
            return .downMirrored
        case .leftMirrored:
            return .leftMirrored
        @unknown default:
            return .up
        }
    }
}

enum BarcodeDetectorError: LocalizedError {
    case failedToReadBarcode, unsupportedBarcodeFormat, imageConversionError
    
    var errorDescription: String? {
        switch self {
        case .failedToReadBarcode:
            return "Failed to read barcode"
        case .imageConversionError:
            return "Failed to convert image for barcode detection"
        case .unsupportedBarcodeFormat:
            return "Unable to detect barcode in PDF417 format"
        }
    }
}
