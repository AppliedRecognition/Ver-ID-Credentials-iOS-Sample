//
//  ErrorViewController.swift
//  Ver-ID Credentials Sample
//
//  Created by Jakub Dolejs on 27/11/2018.
//  Copyright © 2018 Applied Recognition Inc. All rights reserved.
//

import UIKit

class ErrorViewController: UIViewController {
    
    weak var delegate: ErrorViewControllerDelegate?
    
    @IBAction func reload(_ sender: UIButton) {
        self.delegate?.didReceiveReloadRequest(from: self)
    }
}

protocol ErrorViewControllerDelegate: class {
    func didReceiveReloadRequest(from viewController: ErrorViewController)
}
