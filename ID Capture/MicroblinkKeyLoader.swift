//
//  MicroblinkKeyLoader.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 05/04/2023.
//

import Foundation
import BlinkID

@MainActor
class MicroblinkKeyLoader: ObservableObject {
    
    @Published var result: Result<Void,Error>?
    
    init() {
        self.downloadMBLicenceKey { result in
            switch result {
            case .success(let key):
                MBMicroblinkSDK.shared().setLicenseKey(key) { error in
                    preconditionFailure("\(error)")
                }
                MBMicroblinkSDK.shared().showTrialLicenseWarning = false
                self.result = .success(())
            case .failure(let error):
                self.result = .failure(error)
            }
        }
    }
    
    private func downloadMBLicenceKey(completion: @escaping (Result<String,Error>) -> Void) {
        let queue = OperationQueue()
        queue.addOperation {
            do {
                guard let bundleId = Bundle.main.bundleIdentifier else {
                    throw LicenceKeyError.failedToObtainBundleId
                }
                guard let url = URL(string: "https://ver-id.s3.amazonaws.com/blinkid-keys/ios/\(bundleId).txt") else {
                    throw LicenceKeyError.failedToComposeURL
                }
                guard let key = String(data: try Data(contentsOf: url), encoding: .utf8) else {
                    throw LicenceKeyError.failedToDecodeLicenceKey
                }
                DispatchQueue.main.async {
                    completion(.success(key))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

enum LicenceKeyError: Error {
    case failedToObtainBundleId, failedToComposeURL, failedToDecodeLicenceKey
}
