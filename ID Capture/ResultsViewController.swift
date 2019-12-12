//
//  ResultsViewController.swift
//  Ver-ID ID Capture
//
//  Created by Jakub Dolejs on 26/10/2016.
//  Copyright © 2016 Applied Recognition, Inc. All rights reserved.
//

import UIKit
import VerIDCore
import RxSwift
import RxVerID

class ResultsViewController: UIViewController {
    
    var liveFaceImage: UIImage?
    var cardFaceImage: UIImage?
    var comparisonScore: Float?
    
    let disposeBag = DisposeBag()
    
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
        self.cardFaceView.image = self.cardFaceImage
        
        guard let score = self.comparisonScore else {
            return
        }
        
        rxVerID.verid.subscribe(onSuccess: { verid in
            self.similarityDialLayer!.max = CGFloat(verid.faceRecognition.maxAuthenticationScore.floatValue)
            self.similarityDialLayer!.threshold = CGFloat(verid.faceRecognition.authenticationScoreThreshold.floatValue)
            self.similarityDialLayer!.score = CGFloat(score)
            self.scoreLabel.text = String(format: "Score: %.01f", score)
        }, onError: nil).disposed(by: self.disposeBag)
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
