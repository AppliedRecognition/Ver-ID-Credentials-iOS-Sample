//
//  ViewController.swift
//  VerIDIDCaptureTest
//
//  Created by Jakub Dolejs on 26/10/2016.
//  Copyright © 2016 Applied Recognition, Inc. All rights reserved.
//

import UIKit
import VerIDCredentials
import VerID

class ViewController: UIViewController, IDCaptureSessionDelegate, VerIDSessionDelegate {
    
    @IBOutlet var compareLiveFaceButton: UIButton!
    @IBOutlet var scanIdCardButton: UIButton!
    @IBOutlet var cardImageView: UIImageView!
    @IBOutlet var introTextView: UITextView!
    
    lazy var cardImageURL: URL? = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(self.cardImageFileName)
    }()
    var liveFace: VerIDFace?
    var liveFaceImage: UIImage?
    var document: IDDocument?
    let cardImageFileName = "capturedIdCard.png"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let cardData = UserDefaults.standard.data(forKey: "idBundle") else {
            return
        }
        DispatchQueue.global().async {
            guard let document = try? JSONDecoder().decode(IDDocument.self, from: cardData) else {
                return
            }
            guard let imageURL = document.pages.first?.imageURL else {
                return
            }
            do {
                let imageData = try Data(contentsOf: imageURL)
                guard let image = UIImage(data: imageData) else {
                    return
                }
                DispatchQueue.main.async {
                    self.document = document
                    self.cardImageView.image = image
                    self.cardImageView.layer.masksToBounds = true
                    self.compareLiveFaceButton.isEnabled = true
                    self.introTextView.isHidden = true
                    self.cardImageView.isHidden = false
                    self.scanIdCardButton.setTitle("Rescan ID Card", for: .normal)
                }
            } catch {
                NSLog("Error reading image data from %@: %@", imageURL.path, error.localizedDescription)
            }
        }
    }
    
    @IBAction func scanIdCard(_ sender: Any?) {
        let settings = IDCaptureSessionSettings()
        settings.document = IDDocument(pages: [])
        // To scan an ID with a photo on the front and a PDF 417 barcode on the back (e.g. US/Canadian driver's licence) uncomment the line below
        // settings.document = DoubleSidedPhotoCardWithPDF417Barcode()
        settings.showResult = true
        settings.showGuide = true
        settings.detectFaceForRecognition = true
        let session = IDCaptureSession(settings: settings)
        session.delegate = self
        session.start()
    }
    
    @IBAction func compareLiveFace(_ sender: Any?) {
        let settings = VerIDLivenessDetectionSessionSettings()
        settings.includeFaceTemplatesInResult = true
        settings.numberOfResultsToCollect = 2
        let session = VerIDLivenessDetectionSession(settings: settings)
        session.delegate = self
        session.start()
    }
    
    @IBAction func cardDeleted(_ segue: UIStoryboardSegue) {
        UserDefaults.standard.removeObject(forKey: "idBundle")
        if let cardImageURL = self.document?.pages.first?.imageURL {
            try? FileManager.default.removeItem(at: cardImageURL)
        }
        self.cardImageView.image = nil
        self.document = nil
        self.compareLiveFaceButton.isEnabled = false
        self.introTextView.isHidden = false
        self.cardImageView.isHidden = true
        self.scanIdCardButton.setTitle("Scan ID Card", for: .normal)
    }
    
    func idCaptureSession(_ session: IDCaptureSession, didFinishWithResult result: IDCaptureSessionResult) {
        if result.status == .finished {
            guard let sourceCardImageURL = result.document?.pages.first?.imageURL else {
                return
            }
            guard let imageData = try? Data(contentsOf: sourceCardImageURL) else {
                return
            }
            guard let image = UIImage(data: imageData) else {
                return
            }
            self.document = result.document
            self.cardImageView.image = image
            self.compareLiveFaceButton.isEnabled = true
            self.introTextView.isHidden = true
            self.cardImageView.isHidden = false
            self.scanIdCardButton.setTitle("Rescan ID Card", for: .normal)
            if let card = self.document {
                DispatchQueue.global().async {
                    do {
                        let cardData = try JSONEncoder().encode(card)
                        UserDefaults.standard.set(cardData, forKey: "idBundle")
                        if let cardString = String(data: cardData, encoding: .utf8) {
                            NSLog("Encoded idBundle data:\n%@", cardString)
                        }
                    } catch {
                        NSLog("Error encoding idBundle: %@", error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func session(_ session: VerIDSession, didFinishWithResult result: VerIDSessionResult) {
        guard result.isPositive else {
            return
        }
        guard let (face, imageURL) = result.faceImages(withBearing: .straight).first else {
            return
        }
        guard let imageData = try? Data(contentsOf: imageURL) else {
            return
        }
        guard let image = UIImage(data: imageData) else {
            return
        }
        self.liveFace = face
        let scaleTransform = CGAffineTransform(scaleX: image.size.width, y: image.size.height)
        let faceBounds = face.bounds.applying(scaleTransform)
        UIGraphicsBeginImageContext(faceBounds.size)
        image.draw(at: CGPoint(x: 0-faceBounds.minX, y: 0-faceBounds.minY))
        self.liveFaceImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.performSegue(withIdentifier: "comparisonResult", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ResultsViewController {
            controller.page = self.document?.pages.first
            controller.liveFaceImage = self.liveFaceImage
            controller.liveFace = self.liveFace
        } else if let controller = segue.destination as? IdCardViewController {
            controller.document = self.document
        }
    }
}
