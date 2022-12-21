//
//  FaceComparison.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 07/12/2022.
//

import Foundation
import VerIDCore
import NormalDistribution

class FaceComparison: ObservableObject {
    
    let document: CapturedDocument
    let faceCapture: FaceCapture
    let threshold: Float = 4.0
    
    @Published var comparisonResult: Result<Float,Error>? {
        didSet {
            switch comparisonResult {
            case .success(let score) where score > threshold:
                if let probability = try? NormalDistribution().cumulativeProbability(Double(score)) {
                    self.probability = probability * 100
                } else {
                    self.probability = nil
                }
            default:
                self.probability = nil
            }
        }
    }
    @Published var probability: Double?
    
    init(verID: VerID, document: CapturedDocument, faceCapture: FaceCapture) {
        self.document = document
        self.faceCapture = faceCapture
        self.compareFaces(verID: verID)
    }
    
    init(document: CapturedDocument, faceCapture: FaceCapture, comparisonResult: Result<Float,Error>) {
        self.document = document
        self.faceCapture = faceCapture
        self.comparisonResult = comparisonResult
        switch comparisonResult {
        case .success(let score) where score > threshold:
            self.probability = try? NormalDistribution().cumulativeProbability(Double(score)) * 100
        default:
            self.probability = nil
        }
    }
    
    func compareFaces(verID: VerID) {
        do {
            let score = try verID.faceRecognition.compareSubjectFaces([self.document.faceCapture.face], toFaces: [self.faceCapture.face]).floatValue
            self.comparisonResult = .success(score)
        } catch {
            self.comparisonResult = .failure(error)
        }
    }
}
