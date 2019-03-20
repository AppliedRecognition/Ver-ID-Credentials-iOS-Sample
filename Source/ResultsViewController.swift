//
//  ResultsViewController.swift
//  Ver-ID ID Capture
//
//  Created by Jakub Dolejs on 26/10/2016.
//  Copyright © 2016 Applied Recognition, Inc. All rights reserved.
//

import UIKit
import VerIDCredentials
import VerIDCore

class ResultsViewController: UIViewController {
    
    var verid: VerID?
    var page: Page?
    var liveFaceImage: UIImage?
    var liveFace: RecognizableFace?
    
    @IBOutlet var dialView: UIView!
    @IBOutlet var cardFaceView: UIImageView!
    @IBOutlet var liveFaceView: UIImageView!
    @IBOutlet var simiarityScoreLabel: UILabel!
    
    var similarityDialLayer: SimiarityDial?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.similarityDialLayer = SimiarityDial()
        self.similarityDialLayer!.max = 5.6
        self.dialView.layer.addSublayer(self.similarityDialLayer!)
        self.liveFaceView.image = self.liveFaceImage
        self.cardFaceView.layer.cornerRadius = 12
        self.cardFaceView.layer.masksToBounds = true
        self.liveFaceView.layer.cornerRadius = 12
        self.liveFaceView.layer.masksToBounds = true
        
        if let cardImageURL = self.page?.imageURL, let cardFaceBounds = self.page?.features.first(where: { $0 is FacePhotoFeature })?.bounds, !cardFaceBounds.isNull, let cardImage = UIImage(contentsOfFile: cardImageURL.path) {
            UIGraphicsBeginImageContext(cardFaceBounds.size)
            cardImage.draw(at: CGPoint(x: 0-cardFaceBounds.minX, y: 0-cardFaceBounds.minY))
            self.cardFaceView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        guard let verid = self.verid else {
            return
        }
        guard let liveFace = self.liveFace else {
            return
        }
        guard let cardFaces = self.page?.features.compactMap({ ($0 as? FacePhotoFeature)?.faceTemplate }) else {
            return
        }
        do {
            self.similarityDialLayer!.threshold = CGFloat(verid.faceRecognition.authenticationScoreThreshold.floatValue)
            let score: CGFloat = CGFloat(try verid.faceRecognition.compareSubjectFaces([liveFace], toFaces: cardFaces).floatValue)
            self.similarityDialLayer?.score = score
            if score > CGFloat(verid.faceRecognition.authenticationScoreThreshold.floatValue) {
                self.simiarityScoreLabel.text = "Authenticated"
            } else {
                self.simiarityScoreLabel.text = "Not authenticated"
            }
        } catch {
            self.simiarityScoreLabel.text = "Comparison failed"
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.similarityDialLayer?.frame = self.dialView.bounds
        self.similarityDialLayer?.setNeedsDisplay()
    }
}
