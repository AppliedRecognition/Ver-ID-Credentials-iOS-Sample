//
//  IdCardViewController.swift
//  VerIDIDCaptureTest
//
//  Created by Jakub Dolejs on 09/01/2018.
//  Copyright © 2018 Applied Recognition, Inc. All rights reserved.
//

import UIKit
import VerID
import AVFoundation
import VerIDCredentials

/// View controller that shows a detected ID card and its properties
class IdCardViewController: UIViewController, UITableViewDataSource {
    
    var document: IDDocument?
    var properties: [[String:String]] = []
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var cardImageView: IdCardImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        if let url = self.document?.pages.first?.imageURL, let image = UIImage(contentsOfFile: url.path) {
            // Show the card image
            self.cardImageView.image = image
            if let faceBounds = self.document?.frontFacePhoto.bounds, !faceBounds.isNull {
                // Overlay the face bounds over the card image
                self.cardImageView.faceBounds = faceBounds
            }
        }
        if let barcode = self.document?.barcodes.first?.value.first {
            self.properties = barcode.array
        }
    }
    
    /// Request the deletion of the card. The deletion is performed in response to an unwind segue in the main view controller.
    ///
    /// - Parameter sender: The delete button
    @IBAction func deleteCard(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.barButtonItem = sender
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.performSegue(withIdentifier: "deleteCard", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.properties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let property = self.properties[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "property", for: indexPath)

        cell.textLabel?.text = property.keys.first
        cell.detailTextLabel?.text = property.values.first

        return cell
    }
}

/// Image view that overlays the bounds of a detected face over the image of an ID card
class IdCardImageView: UIImageView {
    
    /// The face whose bounds to overlay on the image
    var faceBounds: CGRect? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        while let sub = self.layer.sublayers?.first(where: { $0 is CAShapeLayer }) {
            sub.removeFromSuperlayer()
        }
        if let faceBounds = self.faceBounds, let imageSize = self.image?.size {
            let imageRect = AVMakeRect(aspectRatio: imageSize, insideRect: CGRect(origin: CGPoint.zero, size: self.bounds.size))
            let scale = imageRect.width / imageSize.width
            let scaleTransform = CGAffineTransform(scaleX: imageSize.width * scale, y: imageSize.height * scale).concatenating(CGAffineTransform(translationX: imageRect.minX, y: imageRect.minY))
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = UIBezierPath(roundedRect: faceBounds.applying(scaleTransform), cornerRadius: 6).cgPath
            shapeLayer.fillColor = nil
            shapeLayer.strokeColor = UIColor.white.cgColor
            shapeLayer.lineWidth = 3
            self.layer.addSublayer(shapeLayer)
        }
    }
}
