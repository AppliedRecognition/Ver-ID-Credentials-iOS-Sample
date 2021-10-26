//
//  FaceDetection.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 26/10/2021.
//  Copyright © 2021 Applied Recognition Inc. All rights reserved.
//

import Foundation
import RxSwift
import VerIDCore

class FaceDetection {
    
    let verID: VerID
    
    init(verID: VerID) {
        self.verID = verID
    }
    
    func detectFaceInImage(_ image: CGImage, detectImageAuthenticity: Bool) -> Single<(RecognizableFace,CGImagePropertyOrientation,Float?)> {
        return Single<(RecognizableFace,CGImagePropertyOrientation,Float?)>.create(subscribe: { emitter in
            do {
                let orientations: [CGImagePropertyOrientation] = [.up, .left, .right, .down]
                for orientation in orientations {
                    let veridImage = VerIDImage(cgImage: image, orientation: orientation)
                    guard let face = try self.verID.faceDetection.detectFacesInImage(veridImage, limit: 1, options: 0).first else {
                        continue
                    }
                    var authenticityScore: Float? = nil
                    if detectImageAuthenticity, let faceDetection = self.verID.faceDetection as? VerIDFaceDetection, let classifier = AuthenticityScoreSupport.default.classifiers.first {
                        do {
                            authenticityScore = try faceDetection.extractAttributeFromFace(face, image: veridImage, using: classifier.name).floatValue
                        } catch {
                            NSLog("Failed to extract authenticity score: %@", error.localizedDescription)
                        }
                    }
                    guard let recognizable = try self.verID.faceRecognition.createRecognizableFacesFromFaces([face], inImage: veridImage).first else {
                        continue
                    }
                    let recognizableFace = RecognizableFace(face: face, recognitionData: recognizable.recognitionData, version: recognizable.version)
                    if ExecutionParams.shouldIDCardFaceBeLowQuality {
                        recognizableFace.quality = 5.0
                    }
                    emitter(.success((recognizableFace, orientation, authenticityScore)))
                    return Disposables.create()
                }
                emitter(.error(FaceDetectionError.faceNotFound))
            } catch {
                emitter(.error(error))
            }
            return Disposables.create()
        }).subscribeOn(SerialDispatchQueueScheduler(qos: .default)).observeOn(MainScheduler.instance)
    }
}
