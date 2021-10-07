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
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var farExplanationLabel: UILabel!
    
    let threshold: Float = 3.0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.liveFaceView.image = self.liveFaceImage
        self.cardFaceView.image = self.cardFaceImage
        self.liveFaceViewLandscape.image = self.liveFaceImage
        self.cardFaceViewLandscape.image = self.cardFaceImage
        
        guard let score = self.comparisonScore else {
            return
        }
        if score >= threshold {
            let normalDistribution = NormalDistribution()
            guard let probability = try? normalDistribution.cumulativeProbability(Double(score)) else {
                return
            }
            self.farExplanationLabel.text = String(format: "The face matching score %.01f indicates a likelihood of %.5f\u{00a0}%% that the person on the ID card is the same person as the one in the selfie. We recommend a threshold of %.01f for a positive identification when comparing faces from identity cards.", score, probability*100, threshold)
            self.resultLabel.text = "Pass"
            self.resultLabel.textColor = UIColor(red: 54/255, green: 175/255, blue: 0, alpha: 1)
        } else {
            self.farExplanationLabel.text = String(format: "The face matching score %.01f indicates that the person on the ID card is likely NOT the same person as the one in the selfie. We recommend a threshold of %.01f for a positive identification when comparing faces from identity cards.", score, threshold)
            self.resultLabel.text = "Warning"
            self.resultLabel.textColor = UIColor.red
        }
    }
}
