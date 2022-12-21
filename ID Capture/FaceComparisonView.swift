//
//  FaceComparisonView.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 07/12/2022.
//

import SwiftUI
import VerIDCore
import VerIDSerialization

struct FaceComparisonView: View {
    
    @StateObject var comparison: FaceComparison
    
    var body: some View {
        if case .success(let score) = comparison.comparisonResult {
            VStack {
                HStack {
                    Image(uiImage: comparison.document.faceCapture.faceImage).resizable().aspectRatio(CGSize(width: 4, height: 5), contentMode: .fit).cornerRadius(20).frame(maxWidth: 150)
                    Image(uiImage: comparison.faceCapture.faceImage).resizable().aspectRatio(CGSize(width: 4, height: 5), contentMode: .fit).cornerRadius(20).frame(maxWidth: 150).padding(.leading, 16)
                    Spacer()
                }.padding(.bottom, 16)
                Text(String(format: "The face matching score %.02f indicates a likelihood of %.0f%% that the person on the ID card is the same person as the one in the selfie. We recommend a threshold of %.02f for a positive identification when comparing faces from identity cards.", score, comparison.probability ?? 0, comparison.threshold))
                Spacer()
            }
            .padding()
            .navigationTitle(String(format: "Score %.02f", score))
            .navigationBarTitleDisplayMode(.large)
        } else {
            Text("Comparison failed")
        }
    }
}

struct FaceComparisonView_Previews: PreviewProvider {
    
    static let captureHeader: Data = {
        return "Ver-ID capture".data(using: .utf8)!
    }()

    static func createSampleFaceComparison() -> Result<FaceComparison,DescribedError> {
        do {
            guard let cardCaptureAsset = NSDataAsset(name: "card_capture") else {
                throw DescribedError("Failed to load asset for card capture")
            }
            var captureData: Data
            if cardCaptureAsset.data.starts(with: captureHeader) {
                captureData = cardCaptureAsset.data[captureHeader.count...]
            } else {
                captureData = cardCaptureAsset.data
            }
            guard let capture1: Capture = try? Deserializer.deserialize(captureData) else {
                throw DescribedError("Failed to deserialize card capture")
            }
            guard let cardCapture = try? FaceCapture(faces: capture1.faces, bearing: .straight, imageProvider: capture1.image) else {
                throw DescribedError("Failed to create card face capture")
            }
            guard let faceCaptureAsset = NSDataAsset(name: "face_capture") else {
                throw DescribedError("Failed to load asset for face capture")
            }
            if faceCaptureAsset.data.starts(with: captureHeader) {
                captureData = faceCaptureAsset.data[captureHeader.count...]
            } else {
                captureData = faceCaptureAsset.data
            }
            guard let capture2: Capture = try? Deserializer.deserialize(captureData) else {
                throw DescribedError("Failed to deserialize face capture")
            }
            guard let faceCapture = try? FaceCapture(faces: capture2.faces, bearing: .straight, imageProvider: capture2.image) else {
                throw DescribedError("Failed to create face capture")
            }
            let faceComparison = FaceComparison(document: CapturedDocument(faceCapture: cardCapture), faceCapture: faceCapture, comparisonResult: .success(7.5))
            return .success(faceComparison)
        } catch let error as DescribedError {
            return .failure(error)
        } catch {
            fatalError()
        }
    }

    static var previews: some View {
        NavigationView {
            let comparisonResult = self.createSampleFaceComparison()
            switch comparisonResult {
            case .success(let comparison):
                FaceComparisonView(comparison: comparison)
            case .failure(let error):
                Text(error.localizedDescription)
            }
        }.navigationViewStyle(.stack)
    }
}
