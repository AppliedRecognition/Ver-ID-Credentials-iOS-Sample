//
//  CardDetailsTableViewController.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 12/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit
import AAMVABarcodeParser

class CardDetailsTableViewController: UITableViewController {
    
    var cardProperties: [(key:String,value:String)] = []
    var documentData: DocumentData?
    var cardImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let documentData = self.documentData {
            self.cardProperties = documentData.entries
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return cardProperties.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath) as? ImageTableViewCell {
                cell.cardImageView.image = self.cardImage
                if let constraint = cell.cardImageView.constraints.first(where: { $0.identifier == "aspectRatio" }) {
                    cell.cardImageView.removeConstraint(constraint)
                }
                if let imageSize = self.cardImage?.size {
                    let constraint = NSLayoutConstraint(item: cell.cardImageView!, attribute: .width, relatedBy: .equal, toItem: cell.cardImageView!, attribute: .height, multiplier: imageSize.width/imageSize.height, constant: 0)
                    constraint.identifier = "aspectRatio"
                    cell.cardImageView.addConstraint(constraint)
                }
                return cell
            }
            return UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "docProperty", for: indexPath)
            let (key,val) = self.cardProperties[indexPath.row]
            cell.textLabel?.text = key
            cell.detailTextLabel?.text = val
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Image"
        } else {
            return "Properties"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let alert = UIAlertController(title: cardProperties[indexPath.row].0, message: cardProperties[indexPath.row].1, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
