//
//  CardScannedViewController.swift
//  Ver-ID-Credentials Sample
//
//  Created by Jakub Dolejs on 27/05/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit
import VerIDCore
import VerIDUI
import VerIDCredentials

class CardViewController: UIViewController, VerIDSessionDelegate {
    
    var idDocument: IDDocument?
    var verid: VerID?
    var liveFaceImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let photoPageImageURL = self.idDocument?.pages.first(where: { $0.features.contains(where: { $0 is FacePhotoFeature }) })?.imageURL else {
            return
        }
        self.cardImageView.image = UIImage(contentsOfFile: photoPageImageURL.path)
    }
    
    @IBAction func captureSelfie() {
        guard let verid = self.verid else {
            return
        }
        let session = VerIDSession(environment: verid, settings: LivenessDetectionSessionSettings())
        session.delegate = self
        session.start()
    }
    @IBOutlet var cardImageView: UIImageView!
    
    func session(_ session: VerIDSession, didFinishWithResult result: VerIDSessionResult) {
        guard result.error == nil else {
            let alert = UIAlertController(title: "Failed to capture live face", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        DispatchQueue.global().async {
            guard let attachment = result.attachments.first(where: { $0.imageURL != nil && $0.face is RecognizableFace }), let imageData = try? Data(contentsOf: attachment.imageURL!), let image = UIImage(data: imageData), let face = attachment.face as? RecognizableFace else {
                return
            }
            UIGraphicsBeginImageContext(face.bounds.size)
            defer {
                UIGraphicsEndImageContext()
            }
            image.draw(at: CGPoint(x: 0-face.bounds.minX, y: 0-face.bounds.minY))
            self.liveFaceImage = UIGraphicsGetImageFromCurrentImageContext()
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "comparison", sender: face)
            }
        }
    }
    
    func sessionWasCanceled(_ session: VerIDSession) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ResultsViewController {
            controller.verid = self.verid
            controller.page = self.idDocument?.pages.first(where: { $0.features.contains(where: { $0 is FacePhotoFeature }) })
            controller.liveFace = sender as? RecognizableFace
            controller.liveFaceImage = self.liveFaceImage
        }
    }
}
