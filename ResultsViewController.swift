//
//  ResultsViewController.swift
//  Ver-ID ID Capture
//
//  Created by Jakub Dolejs on 26/10/2016.
//  Copyright © 2016 Applied Recognition, Inc. All rights reserved.
//

import UIKit
import VerIDCredentials
import VerID

class ResultsViewController: UIViewController {
    
    var card: Card?
    var liveFaceImage: UIImage?
    var liveFace: VerIDFace?
    
    @IBOutlet var dialImageView: UIImageView!
    @IBOutlet var cardFaceView: UIImageView!
    @IBOutlet var liveFaceView: UIImageView!
    @IBOutlet var simiarityScoreLabel: UILabel!
    
    var similarityDialLayer: SimiarityDial?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.similarityDialLayer = SimiarityDial()
        self.similarityDialLayer!.fillColor = nil
        self.similarityDialLayer!.strokeColor = UIColor.black.cgColor
        self.similarityDialLayer!.lineCap = kCALineCapRound
        self.similarityDialLayer!.lineWidth = 3
        self.dialImageView.layer.addSublayer(self.similarityDialLayer!)
        self.liveFaceView.image = self.liveFaceImage
        self.cardFaceView.layer.cornerRadius = 12
        self.cardFaceView.layer.masksToBounds = true
        self.liveFaceView.layer.cornerRadius = 12
        self.liveFaceView.layer.masksToBounds = true
        
        if let cardImageURL = self.card?.imageURL, let cardFaceBounds = self.card?.features.first(where: { $0 is FacePhotoFeature })?.bounds, !cardFaceBounds.isNull, let cardImage = UIImage(contentsOfFile: cardImageURL.path) {
            let scaleTransform = CGAffineTransform(scaleX: cardImage.size.width, y: cardImage.size.height)
            let faceBounds = cardFaceBounds.applying(scaleTransform)
            UIGraphicsBeginImageContext(faceBounds.size)
            cardImage.draw(at: CGPoint(x: 0-faceBounds.minX, y: 0-faceBounds.minY))
            if let cardFaceImage = UIGraphicsGetImageFromCurrentImageContext() {
                self.cardFaceView.image = cardFaceImage
            }
            UIGraphicsEndImageContext()
        }
        
        if let cardFaceTemplate = self.card?.features.flatMap({ $0 as? FacePhotoFeature }).first?.template, let liveFaceTemplate = self.liveFace?.template?.map({ NSNumber(value: $0) }), let score = try? VerID.shared.compareFaceTemplate(cardFaceTemplate, to: liveFaceTemplate) {
            self.similarityDialLayer?.score = CGFloat(score.floatValue)
            self.simiarityScoreLabel.text = String(format: "Similarity score: %.01f/10", score.floatValue * 10)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.similarityDialLayer?.frame = self.dialImageView.bounds
        self.similarityDialLayer?.setNeedsDisplay()
    }
}
