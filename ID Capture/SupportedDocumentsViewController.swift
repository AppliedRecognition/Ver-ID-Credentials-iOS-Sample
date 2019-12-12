//
//  SupportedDocumentsViewController.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 12/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit
import WebKit

class SupportedDocumentsViewController: UIViewController {
    
    @IBOutlet var webkitView: WKWebView!
    var url: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = self.url else {
            return
        }
        let request = URLRequest(url: url)
        self.webkitView.load(request)
    }
}
