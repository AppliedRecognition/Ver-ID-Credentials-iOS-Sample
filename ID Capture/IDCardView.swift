//
//  IDCardView.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 07/12/2022.
//

import SwiftUI
import BlinkID
import VerIDCore

struct IDCardView: View {
    
    @State var sessionResult: Result<CapturedDocument,Error>
    @State var showingSessionResult = true
    @StateObject var verIDSessionRunner = VerIDSessionRunner()
    @EnvironmentObject var verIDLoader: VerIDLoader
    
    var body: some View {
        if let verIDResult = verIDLoader.result, case .success(let verID) = verIDResult {
            if let veridSessionresult = verIDSessionRunner.sessionResult, showingSessionResult {
                NavigationLink(isActive: $showingSessionResult) {
                    if let sessionError = veridSessionresult.error {
                        SessionErrorView(error: sessionError)
                    } else if let faceCapture = veridSessionresult.faceCaptures.first, case .success(let doc) = self.sessionResult {
                        let comparison = FaceComparison(verID: verID, document: doc, faceCapture: faceCapture)
                        FaceComparisonView(comparison: comparison)
                    }
                } label: {
                    EmptyView()
                }
            } else {
                switch sessionResult {
                case .success(let capture):
                    ZStack {
                        GeometryReader { proxy in
                            VStack {
                                Spacer()
                                HStack(alignment: .bottom) {
                                    Image("selfie").resizable().aspectRatio(contentMode: .fit).frame(width: proxy.size.width + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing, height: proxy.size.height + proxy.safeAreaInsets.bottom, alignment: .bottomTrailing).offset(y: proxy.safeAreaInsets.bottom)
                                    Spacer()
                                }
                            }.ignoresSafeArea()
                        }
                        VStack {
                            HStack {
                                NavigationLink {
                                    DocumentDetailsView(document: capture)
                                } label: {
                                    Image(uiImage: capture.faceCapture.image).resizable().aspectRatio(85.6/53.98, contentMode: .fit).frame(height: 150).cornerRadius(8)
                                }
                                Spacer()
                            }
                            HStack {
                                Button {
                                    (verID.faceDetection as? VerIDFaceDetection)?.detRecLib.settings.sizeRange = 0.13
                                    verIDSessionRunner.sessionResult = nil
                                    showingSessionResult = true
                                    verIDSessionRunner.startSession(verID: verID)
                                } label: {
                                    Image(systemName: "camera")
                                    Text("Compare to selfie")
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.top, 16)
                                Spacer()
                            }
                            Spacer()
                        }.padding()
                    }.navigationTitle("Your document")
                        .navigationBarTitleDisplayMode(.large)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                NavigationLink {
                                    DocumentDetailsView(document: capture)
                                } label: {
                                    Text("Details")
                                }
                            }
                        }
                case .failure(let error):
                    Text(error.localizedDescription)
                }
            }
        } else {
            ProgressView("Loading Ver-ID")
        }
    }
}

struct SessionErrorView: View {
    
    @State var error: Error
    
    var body: some View {
        VStack {
            HStack {
                Text("\(error.localizedDescription)")
                Spacer()
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Face capture failed")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct IDCardView_Previews: PreviewProvider {
    
    static func createCapturedDocument() -> Result<CapturedDocument,Error> {
        if let doc = CapturedDocument.sample {
            return .success(doc)
        } else {
            return .failure(NSError())
        }
    }
    
    static let verIDLoader = VerIDLoader()
    
    static var previews: some View {
        NavigationView {
            IDCardView(sessionResult: self.createCapturedDocument()).environmentObject(verIDLoader)
        }.navigationViewStyle(.stack)
        
        NavigationView {
            SessionErrorView(error: NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"]))
        }.navigationViewStyle(.stack).previewDisplayName("Session error")
    }
}

fileprivate enum PreviewError: String, Error {
    case failedToGetImage, faceNotDetected
}
