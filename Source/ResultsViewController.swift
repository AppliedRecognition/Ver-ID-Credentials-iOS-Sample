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
    
    var page: Page?
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
        self.similarityDialLayer!.lineCap = CAShapeLayerLineCap.round
        self.similarityDialLayer!.lineWidth = 3
        self.dialImageView.layer.addSublayer(self.similarityDialLayer!)
        self.liveFaceView.image = self.liveFaceImage
        self.cardFaceView.layer.cornerRadius = 12
        self.cardFaceView.layer.masksToBounds = true
        self.liveFaceView.layer.cornerRadius = 12
        self.liveFaceView.layer.masksToBounds = true
        
        if let cardImageURL = self.page?.imageURL, let cardFaceBounds = self.page?.features.first(where: { $0 is FacePhotoFeature })?.bounds, !cardFaceBounds.isNull, let cardImage = UIImage(contentsOfFile: cardImageURL.path) {
            UIGraphicsBeginImageContext(cardFaceBounds.size)
            cardImage.draw(at: CGPoint(x: 0-cardFaceBounds.minX, y: 0-cardFaceBounds.minY))
            if let cardFaceImage = UIGraphicsGetImageFromCurrentImageContext() {
                self.cardFaceView.image = cardFaceImage
            }
            UIGraphicsEndImageContext()
        }
        
        if let cardFaceTemplate = self.page?.features.compactMap({ $0 as? FacePhotoFeature }).first?.face?.faceTemplate, let liveFaceTemplate = self.liveFace?.faceTemplate, let score = try? VerID.shared.compareFaceTemplates(cardFaceTemplate, liveFaceTemplate) {
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
