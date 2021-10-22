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
    var authenticityScore: Float?
    var frontBackMatchScore: Float?
    var scores: [(key:String,value:String,description:String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        if let authenticityScore = self.authenticityScore {
            let authenticity = authenticityScore >= 0.6 ? "is" : "is not"
            self.scores.append((key: "Authenticity score", value: String(format: "%.02f", authenticityScore), description: String(format: "Ver-ID uses machine learning to calculate an authenticity score. The score between 0.0 and 1.0 indicates the authenticity of the document holder's image. Higher scores mean a lesser chance that the image has been tampered with.\n\nThis scan's score of %.02f suggests that the document %@ authentic.", authenticityScore, authenticity)))
        }
        if let frontBackMatchScore = self.frontBackMatchScore {
            self.scores.append((key: "Front/back match score", value: String(format: "%.0f%%", frontBackMatchScore * 100), description: String(format: "The score indicates how well the information on the front of the document matches the information on the barcode. The comparison uses a fuzzy string matching algorithm.\n\nIn this scan, %.0f%% of the information on the front matches the barcode.", frontBackMatchScore * 100)))
        }
        if let documentData = self.documentData {
            self.cardProperties.append(contentsOf: documentData.entries)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.scores.isEmpty ? 2 : 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            if !scores.isEmpty {
                return scores.count
            } else {
                return cardProperties.count
            }
        case 2:
            return cardProperties.count
        default:
            return 1
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
                    constraint.priority = .defaultHigh
                    cell.cardImageView.addConstraint(constraint)
                }
                return cell
            }
            return UITableViewCell()
        } else {
            let cellId: String
            let text: String
            let detailText: String
            if !self.scores.isEmpty && indexPath.section == 1 {
                let (key,val,_) = self.scores[indexPath.row]
                text = key
                detailText = val
                cellId = "score"
            } else {
                let (key,val) = self.cardProperties[indexPath.row]
                text = key
                detailText = val
                cellId = "docProperty"
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            cell.textLabel?.text = text
            cell.detailTextLabel?.text = detailText
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Image"
        } else if !self.scores.isEmpty && section == 1 {
            return "Validation"
        } else {
            return "Properties"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && !self.scores.isEmpty {
            self.performSegue(withIdentifier: "details", sender: indexPath.row)
        } else if indexPath.section != 0 {
            let alert = UIAlertController(title: cardProperties[indexPath.row].0, message: cardProperties[indexPath.row].1, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard !self.scores.isEmpty && indexPath.section == 1 else {
            return
        }
        self.performSegue(withIdentifier: "details", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ScoreDescriptionViewController, let index = sender as? Int {
            destination.scoreName = self.scores[index].key
            destination.scoreDescription = self.scores[index].description
        }
    }
}
