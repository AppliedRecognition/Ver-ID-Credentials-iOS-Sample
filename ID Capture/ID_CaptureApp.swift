//
//  ID_CaptureApp.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 06/12/2022.
//

import SwiftUI
import Microblink

@main
struct ID_CaptureApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView().onChange(of: scenePhase) { phase in
                if phase == .active {
                    loadMicroblink()
                }
            }
        }
    }
    
    func loadMicroblink() {
        MBMicroblinkSDK.shared().setLicenseResource("mb-licence", withExtension: "key", inSubdirectory: nil, for: Bundle.main) { error in
            preconditionFailure("\(error)")
        }
        MBMicroblinkSDK.shared().showTrialLicenseWarning = false
    }
}
