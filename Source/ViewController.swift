//
//  ViewController.swift
//  VerIDIDCaptureTest
//
//  Created by Jakub Dolejs on 26/10/2016.
//  Copyright © 2016 Applied Recognition, Inc. All rights reserved.
//

import UIKit
import VerIDCredentials
import VerIDCore
import VerIDUI

class ViewController: UIViewController, IDCaptureSessionDelegate, SessionDelegate, CardPropertiesViewControllerDelegate {
    
    @IBOutlet var compareLiveFaceButton: UIButton!
    @IBOutlet var scanIdCardButton: UIButton!
    @IBOutlet var cardImageView: UIImageView!
    @IBOutlet var introTextView: UITextView!
    
    var verid: VerID?
    var veridCredentials: VerID?
    
    lazy var cardImageURL: URL? = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(self.cardImageFileName)
    }()
    var liveFace: RecognizableFace?
    var liveFaceImage: UIImage?
    var document: IDDocument?
    let cardImageFileName = "capturedIdCard.png"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let cardData = UserDefaults.standard.data(forKey: "idBundle") else {
            return
        }
        if let document = try? JSONDecoder().decode(IDDocument.self, from: cardData) {
            self.document = document
        } else {
            return
        }
        guard let imageURL = self.document?.pages.first?.imageURL else {
            return
        }
        do {
            let imageData = try Data(contentsOf: imageURL)
            guard let image = UIImage(data: imageData) else {
                return
            }
            self.cardImageView.image = image
            self.cardImageView.layer.masksToBounds = true
            self.compareLiveFaceButton.isEnabled = true
            self.introTextView.isHidden = true
            self.cardImageView.isHidden = false
            self.scanIdCardButton.setTitle("Rescan ID Card", for: .normal)
        } catch {
            NSLog("Error reading image data from %@: %@", imageURL.path, error.localizedDescription)
            return
        }
    }
    
    @IBAction func compareLiveFace(_ sender: Any?) {
        guard let verid = self.verid else {
            return
        }
        let settings = LivenessDetectionSessionSettings()
        settings.numberOfResultsToCollect = 2
        let session = Session(environment: verid, settings: settings)
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
    
    func idCaptureSession(_ session: IDCaptureSession, didCaptureIDDocument document: IDDocument) {
        self.navigationController?.popToRootViewController(animated: false)
        guard let cardImageURL = self.cardImageURL else {
            return
        }
        guard let sourceCardImageURL = document.pages.first?.imageURL else {
            return
        }
        guard let imageData = try? Data(contentsOf: sourceCardImageURL) else {
            return
        }
        guard let image = UIImage(data: imageData) else {
            return
        }
        do {
            try imageData.write(to: cardImageURL)
        } catch {
            NSLog("Error copying file %@ to %@: %@", sourceCardImageURL.path, cardImageURL.path, error.localizedDescription)
            return
        }
        self.document = document
        self.document?.pages.first?.imagePath = self.cardImageFileName
        self.cardImageView.image = image
        self.compareLiveFaceButton.isEnabled = true
        self.introTextView.isHidden = true
        self.cardImageView.isHidden = false
        self.scanIdCardButton.setTitle("Rescan ID Card", for: .normal)
        if let card = self.document {
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
    
    func idCaptureSession(_ session: IDCaptureSession, didFailWithError error: Error) {
        let alert = UIAlertController(title: "ID capture session failed", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func didCancelIDCaptureSession(_ session: IDCaptureSession) {
        
    }
    
    func session(_ session: Session, didFinishWithResult result: SessionResult) {
        if let error = result.error {
            return
        }
        guard let detectedFace = result.attachments.first, let imageURL = detectedFace.imageURL, let face = detectedFace.face as? RecognizableFace else {
            return
        }
        guard let imageData = try? Data(contentsOf: imageURL) else {
            return
        }
        guard let image = UIImage(data: imageData) else {
            return
        }
        self.liveFace = face
        UIGraphicsBeginImageContext(face.bounds.size)
        defer {
            UIGraphicsEndImageContext()
        }
        image.draw(at: CGPoint(x: 0-face.bounds.minX, y: 0-face.bounds.minY))
        self.liveFaceImage = UIGraphicsGetImageFromCurrentImageContext()
        self.performSegue(withIdentifier: "comparisonResult", sender: nil)
    }
    
    func sessionWasCanceled(_ session: Session) {
        
    }
    
    
    func cardPropertiesViewController(_ viewController: CardPropertiesViewController, didSelectIDDocument document: IDDocument) {
        guard let verid = self.veridCredentials else {
            return
        }
        let settings = IDCaptureSessionSettings()
        settings.document = document
        settings.showResult = true
        settings.showGuide = true
        settings.detectFaceForRecognition = true
        let session = IDCaptureSession(environment: verid, settings: settings)
        session.delegate = self
        session.start()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ResultsViewController {
            controller.verid = self.verid
            controller.page = self.document?.pages.first
            controller.liveFaceImage = self.liveFaceImage
            controller.liveFace = self.liveFace
        } else if let controller = segue.destination as? IdCardViewController {
            controller.document = self.document
        } else if let controller = segue.destination as? CardPropertiesViewController {
            controller.delegate = self
        }
    }
}
