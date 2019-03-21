//
//  CardPropertiesViewController.swift
//  Ver-ID Credentials Sample
//
//  Created by Jakub Dolejs on 19/03/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit
import VerIDCredentials

class CardPropertiesViewController: UIViewController {
    
    @IBOutlet var photoPageSwitch: UISwitch!
    @IBOutlet var barcodePageSwitch: UISwitch!
    
    var delegate: CardPropertiesViewControllerDelegate?
    
    @IBAction func didSelectProperties(_ sender: Any?) {
        var pages: [Page] = []
        if self.photoPageSwitch.isOn {
            pages.append(ISOID1PhotoCard())
        }
        if self.barcodePageSwitch.isOn {
            pages.append(ISOID1CardWithPDF417Barcode())
        }
        if pages.isEmpty {
            return
        }
        let document = IDDocument(pages: pages)
        self.delegate?.cardPropertiesViewController(self, didSelectIDDocument: document)
    }

    @IBAction func didSwitchProperty(_ sender: UISwitch?) {
        self.navigationItem.rightBarButtonItem?.isEnabled = photoPageSwitch.isOn || barcodePageSwitch.isOn
    }
}

protocol CardPropertiesViewControllerDelegate {
    func cardPropertiesViewController(_ viewController: CardPropertiesViewController, didSelectIDDocument document: IDDocument)
}
