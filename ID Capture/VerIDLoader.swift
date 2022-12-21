//
//  VerIDLoader.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 07/12/2022.
//

import Foundation
import VerIDCore

@MainActor
class VerIDLoader: ObservableObject {
    
    @Published var result: Result<VerID,Error>?
    
    init() {
        let veridFactory = VerIDFactory()
        let detrecFactory = VerIDFaceDetectionRecognitionFactory(apiSecret: nil)
        let classifiers = AuthenticityScoreSupport.default.classifiers
        if !classifiers.isEmpty {
            detrecFactory.additionalFaceClassifiers = classifiers
        }
        detrecFactory.settings.sizeRange = 1.0
        detrecFactory.defaultFaceTemplateVersion = .latest
        veridFactory.faceDetectionFactory = detrecFactory
        veridFactory.faceRecognitionFactory = detrecFactory
        veridFactory.createVerID { result in
            self.result = result
        }
    }
}
