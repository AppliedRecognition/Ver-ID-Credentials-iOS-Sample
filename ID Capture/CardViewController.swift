//
//  CardScannedViewController.swift
//  Ver-ID-Credentials Sample
//
//  Created by Jakub Dolejs on 27/05/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit
import VerIDCore
import RxVerID
import RxSwift
import AAMVABarcodeParser

class CardViewController: UIViewController {
    
    var cardImage: UIImage?
    var cardFaceImage: UIImage?
    var cardAspectRatio: CGFloat?
    var cardFace: RecognizableFace?
    var comparisonScore: Float?
    var liveFaceImage: UIImage?
    var documentData: DocumentData?
    let disposeBag = DisposeBag()
    let rxVerID = RxVerID()
    
    @IBOutlet var cardImageView: UIImageView!
    @IBOutlet var qualityWarningButton: UIButton!
    
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
        if let faceQuality = self.cardFace?.quality, let threshold = (rxVerID.faceRecognitionFactory as? VerIDFaceDetectionRecognitionFactory)?.settings.faceExtractQualityThreshold {
            self.qualityWarningButton.isHidden = faceQuality >= CGFloat(threshold)
        }
        if self.documentData != nil {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Details", style: .plain, target: self, action: #selector(showCardDetails))
        }
        self.rxVerID.verid.subscribe(onSuccess: { _ in }, onError: { _ in }).disposed(by: self.disposeBag)
    }
    
    @objc func showCardDetails() {
        self.performSegue(withIdentifier: "details", sender: nil)
    }
    
    @IBAction func captureSelfie() {
        guard let cardFace = self.cardFace else {
            return
        }
        let session: Maybe<(RecognizableFace, URL, Bearing)>
        if ExecutionParams.isTesting, let url = ExecutionParams.selfieURL {
            if ExecutionParams.shouldFailLivenessDetection {
                session = .error(NSError(domain: kVerIDErrorDomain, code: 1, userInfo: nil))
            } else {
                session = self.rxVerID.detectRecognizableFacesInImageURL(url, limit: 1).map({ face in
                    (face, url, Bearing.straight)
                }).asMaybe()
            }
        } else {
            session = self.rxVerID.session(settings: LivenessDetectionSessionSettings()).flatMap({ result in
                self.rxVerID.recognizableFacesAndImagesFromSessionResult(result, bearing: .straight).asMaybe()
            })
        }
        session.flatMap({ (face, url, _) in
            self.rxVerID.compareFace(cardFace, toFaces: [face]).flatMap({ score in
                self.rxVerID.cropImageURL(url, toFace: face).map({ image in
                    return (image, score)
                })
            }).asMaybe()
        }).subscribeOn(SerialDispatchQueueScheduler(qos: .default))
        .observeOn(MainScheduler.instance)
        .subscribe(onSuccess: { (image, score) in
            self.liveFaceImage = image
            self.comparisonScore = score
            self.performSegue(withIdentifier: "comparison", sender: nil)
        }, onError: { error in
            let alert = UIAlertController(title: "Failed to capture live face", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }, onCompleted: nil).disposed(by: self.disposeBag)
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
        }
    }
}
