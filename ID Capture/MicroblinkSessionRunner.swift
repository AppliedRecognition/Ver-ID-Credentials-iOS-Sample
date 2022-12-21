//
//  MicroblinkSessionRunner.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 07/12/2022.
//

import Foundation
import UIKit
import Microblink
import DocumentVerificationClient
import VerIDCore
import VerIDSerialization

class MicroblinkSessionRunner: NSObject, ObservableObject, MBBlinkIdOverlayViewControllerDelegate, UIAdaptivePresentationControllerDelegate {
    
    @Published var sessionResult: Result<CapturedDocument,Error>?
    @Published var status: DocumentCaptureStatus = .idle
    
    private var blinkIdRecognizer: MBBlinkIdCombinedRecognizer?
    var verID: VerID?
    
    func captureDocument() {
        self.status = .capturing
        let recognizer = MBBlinkIdCombinedRecognizer()
        recognizer.saveCameraFrames = true
        self.blinkIdRecognizer = recognizer
        let settings = MBBlinkIdOverlaySettings()
        settings.autorotateOverlay = true
        let recognizerCollection = MBRecognizerCollection(recognizers: [recognizer])
        let blinkIdOverlayViewController = MBBlinkIdOverlayViewController(settings: settings, recognizerCollection: recognizerCollection, delegate: self)
        guard let recognizerRunnerViewController = MBViewControllerFactory.recognizerRunnerViewController(withOverlayViewController: blinkIdOverlayViewController) else {
            return
        }
        guard let rootViewController = UIApplication.shared.connectedScenes.compactMap({ scene in
            return (scene as? UIWindowScene)?.keyWindow?.rootViewController
        }).first else {
            return
        }
        recognizerRunnerViewController.presentationController?.delegate = self
        rootViewController.present(recognizerRunnerViewController, animated: true)
    }
    
    // MARK: - Blink ID
    
    func blinkIdOverlayViewControllerDidFinishScanning(_ blinkIdOverlayViewController: MBBlinkIdOverlayViewController, state: MBRecognizerResultState) {
        if state == .valid {
            blinkIdOverlayViewController.recognizerRunnerViewController?.pauseScanning()
            DispatchQueue.main.async {
                blinkIdOverlayViewController.dismiss(animated: true, completion: nil)
                guard let result = self.blinkIdRecognizer?.result else {
                    return
                }
                self.status = .processing
                Task {
                    let captureResult: Result<CapturedDocument,Error>
                    do {
                        let verificationResult = try await self.verifyDocumentInScanResult(result)
                        guard let image = verificationResult?.extractionResult?.fullDocumentFrontImage else {
                            throw DocumentCaptureError.failedToReadImage
                        }
                        let (faceCapture, authScore) = try await self.faceCaptureFromImage(image, detectAuthenticity: AuthenticityScoreSupport.default.isDocumentSupported(result: result))
                        let document = CapturedDocument(scanResult: result, faceCapture: faceCapture, authenticityScore: authScore, documentVerificationResult: verificationResult)
                        captureResult = .success(document)
                    } catch {
                        captureResult = .failure(error)
                    }
                    await MainActor.run {
                        self.sessionResult = captureResult
                        self.status = .idle
                    }
                }
            }
        }
    }

    func blinkIdOverlayViewControllerDidTapClose(_ blinkIdOverlayViewController: MBBlinkIdOverlayViewController) {
        self.status = .idle
        blinkIdOverlayViewController.dismiss(animated: true)
    }
    
    // MARK: -
    
    func verifyDocumentInScanResult(_ scanResult: MBBlinkIdCombinedRecognizerResult) async throws -> DocumentVerificationResult? {
        guard let frontImage = scanResult.frontCameraFrame?.image, let backImage = scanResult.backCameraFrame?.image else {
            throw DescribedError("Failed to read document images")
        }
        guard let docVerURL = Bundle.main.object(forInfoDictionaryKey: "com.appliedrec.docverurl") as? String,
                let docVerClientId = Bundle.main.object(forInfoDictionaryKey: "com.appliedrec.docverclientid") as? String,
                let docVerClientSecret = Bundle.main.object(forInfoDictionaryKey: "com.appliedrec.docverclientsecret") as? String else {
            throw DescribedError("Failed to obtain document verification credentials")
        }
        let frontImageSource = ImageSource(image: frontImage)
        let backImageSource = ImageSource(image: backImage)
        let docVerRequest = DocumentVerificationRequest(imageFront: frontImageSource, imageBack: backImageSource)
        docVerRequest.returnFullDocumentImage = true
        let docVerSettings = DocumentVerificationServiceSettings(verificationServiceBaseUrl: docVerURL,
                                                                 accessClientId: docVerClientId,
                                                                 accessClientSecret: docVerClientSecret)
        let docVerService = DocumentVerificationService(settings: docVerSettings)
        return try await docVerService.verify(documentVerificationRequest: docVerRequest)
    }
    
    func faceCaptureFromImage(_ image: UIImage, detectAuthenticity: Bool, completion: @escaping (Result<(FaceCapture, Float?),Error>) -> Void) {
        DispatchQueue.global().async {
            do {
                guard let faceDetectionUtility = self.verID?.utilities?.faceDetection else {
                    throw DocumentCaptureError.unsupportedFaceRecognitionImplementation
                }
                let faces = try faceDetectionUtility.detectRecognizableFacesInImage(image, limit: 1, faceTemplateVersions: [.latest])
                if faces.isEmpty {
                    throw DocumentCaptureError.failedToDetectFaceOnDocument
                }
                let authenticityScore: Float?
                if detectAuthenticity, let faceDetection = self.verID?.faceDetection as? VerIDFaceDetection, let classifier = AuthenticityScoreSupport.default.classifiers.first {
                    authenticityScore = try faceDetection.extractAttributeFromFace(faces.first!, image: image, using: classifier.name).floatValue
                } else {
                    authenticityScore = nil
                }
                let capture = try FaceCapture(faces: faces, bearing: .straight, image: image)
                DispatchQueue.main.async {
                    completion(.success((capture, authenticityScore)))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func faceCaptureFromImage(_ image: UIImage, detectAuthenticity: Bool) async throws -> (FaceCapture, Float?) {
        return try await withCheckedThrowingContinuation { continuation in
            self.faceCaptureFromImage(image, detectAuthenticity: detectAuthenticity) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.status = .idle
    }
}

enum DocumentCaptureError: LocalizedError {
    case failedToReadImage, unsupportedFaceRecognitionImplementation, failedToDetectFaceOnDocument
    
    var errorDescription: String? {
        switch self {
        case .failedToReadImage:
            return "Failed to read document image"
        case .unsupportedFaceRecognitionImplementation:
            return "Unsuported face recognition implementation"
        case .failedToDetectFaceOnDocument:
            return "Failed to detect a face on ID document"
        }
    }
}

enum DocumentCaptureStatus {
    case idle, capturing, processing
}
