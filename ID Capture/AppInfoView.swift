//
//  AppInfoView.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 09/12/2022.
//

import SwiftUI
import VerIDCore
import Microblink

struct AppInfoView: View {
    
    @StateObject var settings = Settings()
    
    var body: some View {
        List {
            Section(header: Text("Face detection and recognition")) {
                Toggle(isOn: $settings.useBackCamera) {
                    Text("Use back camera")
                }
                Toggle(isOn: $settings.enableActiveLivenessDetection) {
                    Text("Enable active liveness detection")
                }
            }
            if let address = Bundle.main.object(forInfoDictionaryKey: "com.appliedrec.supporteddocsurl") as? String, let url = URL(string: address) {
                Section(header: Text("ID capture")) {
                    Link(destination: url) {
                        HStack {
                            Text("Supported documents")
                            Spacer()
                            Image(systemName: "link").imageScale(.small)
                        }
                    }
                }
            }
            Section(header: Text("About")) {
                Text("The application captures an ID card using Microblink SDK. It then uses Ver\u{2011}ID SDK to capture a live face of the user and compare it to the face on the captured ID card.")
                VStack {
                    HStack {
                        Text("Privacy notice").font(.caption).bold()
                        Spacer()
                    }.padding(.bottom, 2)
                    HStack {
                        Text("The captured images and data stay in your device's memory while the app is running and are deleted when the app shuts down. Neither Applied Recognition nor other parties have access to the images and data captured by the app.").font(.caption)
                        Spacer()
                    }
                }
            }
            Section(header: Text("Version information")) {
                HStack {
                    Text("Application version")
                    Spacer()
                    Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown")
                }
                HStack {
                    Text("Ver-ID version")
                    Spacer()
                    Text(VerID.libraryVersion)
                }
                HStack {
                    Text("Microblink version")
                    Spacer()
                    Text(Bundle(for: MBMicroblinkApp.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown")
                }
            }
        }.navigationTitle("Settings")
    }
}

struct AppInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppInfoView()
        }
    }
}

class Settings: ObservableObject {
    
    enum Keys: String {
        case useBackCamera = "useBackCamera"
        case enableActiveLivenessDetection = "enableActiveLivenessDetection"
    }
    
    @Published var useBackCamera: Bool {
        didSet {
            UserDefaults.standard.set(self.useBackCamera, forKey: Keys.useBackCamera.rawValue)
        }
    }
    @Published var enableActiveLivenessDetection: Bool {
        didSet {
            UserDefaults.standard.set(self.enableActiveLivenessDetection, forKey: Keys.enableActiveLivenessDetection.rawValue)
        }
    }
    
    init() {
        UserDefaults.standard.register(defaults: [
            Keys.useBackCamera.rawValue: false,
            Keys.enableActiveLivenessDetection.rawValue: false
        ])
        self.useBackCamera = UserDefaults.standard.bool(forKey: Keys.useBackCamera.rawValue)
        self.enableActiveLivenessDetection = UserDefaults.standard.bool(forKey: Keys.enableActiveLivenessDetection.rawValue)
    }
}
