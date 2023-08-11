//
//  VerIDSessionRunner.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 06/12/2022.
//

import Foundation
import VerIDUI
import VerIDCore
import SwiftUI
import AVFoundation

@MainActor
class VerIDSessionRunner: ObservableObject, VerIDSessionDelegate {
    
    @Published var sessionResult: VerIDSessionResult?
    @Published var isSessionRunning: Bool = false
    
    func startSession(verID: VerID) {
        let settings = LivenessDetectionSessionSettings()
        settings.faceCaptureCount = UserDefaults.standard.bool(forKey: Settings.Keys.enableActiveLivenessDetection.rawValue) ? 2 : 1
        let session = VerIDSession(environment: verID, settings: settings)
        session.delegate = self
        session.start()
        self.isSessionRunning = true
    }
    
    nonisolated func didFinishSession(_ session: VerIDSession, withResult result: VerIDSessionResult) {
        _Concurrency.Task {
            await MainActor.run {
                self.sessionResult = result
                self.isSessionRunning = false
            }
        }
    }
    
    nonisolated func didCancelSession(_ session: VerIDSession) {
        _Concurrency.Task {
            await MainActor.run {
                self.isSessionRunning = false
            }
        }
    }
    
    nonisolated func cameraPositionForSession(_ session: VerIDSession) -> AVCaptureDevice.Position {
        return UserDefaults.standard.bool(forKey: Settings.Keys.useBackCamera.rawValue) ? .back : .front
    }
}
