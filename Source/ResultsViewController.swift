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
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var helpButton: UIButton!
    
    var similarityDialLayer: SimiarityDial?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.similarityDialLayer = SimiarityDial()
        self.dialView.layer.addSublayer(self.similarityDialLayer!)
        self.liveFaceView.image = self.liveFaceImage
        self.cardFaceView.layer.cornerRadius = 12
        self.cardFaceView.layer.masksToBounds = true
        self.liveFaceView.layer.cornerRadius = 12
        self.liveFaceView.layer.masksToBounds = true
        
        if let page = self.page as? FacePhotoPage, let cardImageURL = page.imageURL, let cardFaceBounds = page.face?.bounds, !cardFaceBounds.isNull, let cardImage = UIImage(contentsOfFile: cardImageURL.path) {
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
        guard let cardFaces = (self.page as? FacePhotoPage)?.face else {
            return
        }
        self.similarityDialLayer!.max = CGFloat(verid.faceRecognition.maxAuthenticationScore.floatValue)
        do {
            self.similarityDialLayer!.threshold = CGFloat(verid.faceRecognition.authenticationScoreThreshold.floatValue)
            let score: CGFloat = CGFloat(try verid.faceRecognition.compareSubjectFaces([liveFace], toFaces: [cardFaces]).floatValue)
            self.similarityDialLayer?.score = score
            self.scoreLabel.text = String(format: "Score: %.01f", score)
        } catch {
            self.scoreLabel.text = "Comparison failed"
            self.helpButton.isHidden = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.similarityDialLayer?.frame = self.dialView.bounds
        self.similarityDialLayer?.setNeedsDisplay()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ScoreTableViewController {
            dest.score = self.similarityDialLayer?.score
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return identifier != "score" || self.similarityDialLayer?.score != nil
    }
}
