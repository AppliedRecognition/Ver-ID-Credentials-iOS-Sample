//
//  CardScannedViewController.swift
//  Ver-ID-Credentials Sample
//
//  Created by Jakub Dolejs on 27/05/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit
import VerIDCore
import VerIDUI
import RxSwift
import AAMVABarcodeParser

class CardViewController: UIViewController, VerIDFactoryDelegate, VerIDSessionDelegate {
    
    var cardImage: UIImage?
    var cardFaceImage: UIImage?
    var cardAspectRatio: CGFloat?
    var cardFace: RecognizableFace?
    var authenticityScore: Float?
    var frontBackMatchScore: Float?
    var comparisonScore: Float?
    var liveFaceImage: UIImage?
    var documentData: DocumentData?
    let disposeBag = DisposeBag()
    
    @IBOutlet var cardImageView: UIImageView!
    @IBOutlet var qualityWarningButton: UIButton!
    @IBOutlet var captureSelfieButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cardImageView.image = self.cardImage
        if let aspectRatio = self.cardAspectRatio {
            if let aspectRatioConstraint = self.cardImageView.constraints.first(where: { $0.identifier == "aspectRatio" }) {
                self.cardImageView.removeConstraint(aspectRatioConstraint)
            }
            let aspectRatioConstraint = NSLayoutConstraint(item: self.cardImageView!, attribute: .width, relatedBy: .equal, toItem: self.cardImageView!, attribute: .height, multiplier: aspectRatio, constant: 0)
            aspectRatioConstraint.identifier = "aspectRatio"
            self.cardImageView.addConstraint(aspectRatioConstraint)
        }
        let veridFactory = VerIDFactory()
        if let verid = Globals.verid {
            self.veridFactory(veridFactory, didCreateVerID: verid)
        } else {
            veridFactory.delegate = self
            veridFactory.createVerID()
        }
        if let faceQuality = self.cardFace?.quality, let threshold = (veridFactory.faceRecognitionFactory as? VerIDFaceDetectionRecognitionFactory)?.settings.faceExtractQualityThreshold {
            self.qualityWarningButton.isHidden = faceQuality >= CGFloat(threshold)
        }
        if self.documentData != nil {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Details", style: .plain, target: self, action: #selector(showCardDetails))
        }
    }
    
    // MARK: - VerIDFactoryDelegate
    
    func veridFactory(_ factory: VerIDFactory, didCreateVerID instance: VerID) {
        Globals.verid = instance
        self.captureSelfieButton.isEnabled = true
    }
    
    func veridFactory(_ factory: VerIDFactory, didFailWithError error: Error) {
        // TODO
    }
    
    // MARK: - VerIDSessionDelegate
    
    func didFinishSession(_ session: VerIDSession, withResult result: VerIDSessionResult) {
        do {
            if let error = result.error {
                throw error
            }
            guard let cardFace = self.cardFace else {
                return
            }
            guard let verid = Globals.verid else {
                return
            }
            guard let faceCapture = result.faceCaptures.first(where: { $0.bearing == .straight }) else {
                return
            }
            self.comparisonScore = try verid.faceRecognition.compareSubjectFaces([cardFace], toFaces: [faceCapture.face]).floatValue
            self.liveFaceImage = faceCapture.faceImage
            self.performSegue(withIdentifier: "comparison", sender: nil)
        } catch {
            let alert = UIAlertController(title: "Failed to capture live face", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func didCancelSession(_ session: VerIDSession) {
        
    }
    
    // MARK: -
    
    @objc func showCardDetails() {
        self.performSegue(withIdentifier: "details", sender: nil)
    }
    
    @IBAction func captureSelfie() {
        guard let verid = Globals.verid else {
            return
        }
        let session = VerIDSession(environment: verid, settings: LivenessDetectionSessionSettings())
        if ExecutionParams.isTesting, let url = ExecutionParams.selfieURL {
            if ExecutionParams.shouldFailLivenessDetection {
                self.didFinishSession(session, withResult: VerIDSessionResult(error: NSError(domain: kVerIDErrorDomain, code: 1, userInfo: nil)))
            } else {
                let result: VerIDSessionResult
                do {
                    guard let image = VerIDImage(url: url) else {
                        throw NSError(domain: kVerIDErrorDomain, code: 1, userInfo: nil)
                    }
                    let faces = try verid.faceDetection.detectFacesInImage(image, limit: 1, options: 0)
                    if faces.isEmpty {
                        throw NSError(domain: kVerIDErrorDomain, code: 1, userInfo: nil)
                    }
                    guard let face = try verid.faceRecognition.createRecognizableFacesFromFaces(faces, inImage: image).first else {
                        throw NSError(domain: kVerIDErrorDomain, code: 1, userInfo: nil)
                    }
                    guard let uiImage = UIImage(contentsOfFile: url.path) else {
                        throw NSError(domain: kVerIDErrorDomain, code: 1, userInfo: nil)
                    }
                    result = VerIDSessionResult(faceCaptures: [FaceCapture(face: RecognizableFace(face: faces[0], recognitionData: face.recognitionData), bearing: .straight, image: uiImage)])
                } catch {
                    result = VerIDSessionResult(error: error)
                }
                self.didFinishSession(session, withResult: result)
            }
            return
        }
        session.delegate = self
        session.start()
    }
    
    @IBAction func showQualityWarning() {
        let alert = UIAlertController(title: "Warning", message: "The face in the image is very low quality. The comparison with the selfie may show an unexpected score.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ResultsViewController, let cardFace = self.cardFace, let cardImage = self.cardImage {
            if let faceImage = self.cardFaceImage {
                controller.cardFaceImage = faceImage
            } else {
                UIGraphicsBeginImageContext(cardFace.bounds.size)
                defer {
                    UIGraphicsEndImageContext()
                }
                cardImage.draw(at: CGPoint(x: 0-cardFace.bounds.minX, y: 0-cardFace.bounds.minY))
                controller.cardFaceImage = UIGraphicsGetImageFromCurrentImageContext()
            }
            controller.liveFaceImage = self.liveFaceImage
            controller.comparisonScore = self.comparisonScore
        } else if let controller = segue.destination as? CardDetailsTableViewController {
            controller.documentData = self.documentData
            controller.cardImage = self.cardImage
            controller.authenticityScore = self.authenticityScore
            controller.frontBackMatchScore = self.frontBackMatchScore
        }
    }
}
