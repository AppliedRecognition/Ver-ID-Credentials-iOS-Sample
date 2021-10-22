//
//  ScoreDescriptionViewController.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 22/10/2021.
//  Copyright © 2021 Applied Recognition Inc. All rights reserved.
//

import UIKit

class ScoreDescriptionViewController: UIViewController {
    
    var scoreName: String?
    var scoreDescription: String?
    
    @IBOutlet var descriptionTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.descriptionTextView.text = self.scoreDescription
        self.navigationItem.title = self.scoreName
    }

}
