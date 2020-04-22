//
//  ResultsViewController.swift
//  Ver-ID ID Capture
//
//  Created by Jakub Dolejs on 26/10/2016.
//  Copyright © 2016 Applied Recognition, Inc. All rights reserved.
//

import UIKit
import NormalDistribution

class ResultsViewController: UIViewController {
    
    var liveFaceImage: UIImage?
    var cardFaceImage: UIImage?
    var comparisonScore: Float?
    
    @IBOutlet var cardFaceView: UIImageView!
    @IBOutlet var liveFaceView: UIImageView!
    @IBOutlet var cardFaceViewLandscape: UIImageView!
    @IBOutlet var liveFaceViewLandscape: UIImageView!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var farExplanationLabel: UILabel!
    @IBOutlet var helpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.liveFaceView.image = self.liveFaceImage
        self.cardFaceView.image = self.cardFaceImage
        self.liveFaceViewLandscape.image = self.liveFaceImage
        self.cardFaceViewLandscape.image = self.cardFaceImage
        
        guard let score = self.comparisonScore else {
            return
        }
        
        let normalDistribution = NormalDistribution()
        guard let probability = try? normalDistribution.cumulativeProbability(Double(score)) else {
            return
        }
        self.farExplanationLabel.text = String(format: "There is a %.5f\u{00a0}%% chance that the person on the card is not the person in the selfie.", 100.0-probability*100)
        self.scoreLabel.text = String(format: "%.02f", score)
    }
}
