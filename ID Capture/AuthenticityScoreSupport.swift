//
//  AuthenticityScoreSupport.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 14/12/2022.
//

import Foundation
import BlinkID
import VerIDCore

class AuthenticityScoreSupport {
    
    static let `default` = AuthenticityScoreSupport()
    
    private var supportedDocuments: [MBRegion:[MBType]] = [
        .alberta: [.typeDl, .typeId],
        .britishColumbia: [.typeDl, .typeDlPublicServicesCard, .typeId, .typePublicServicesCard],
        .manitoba: [.typeDl, .typeId],
        .newBrunswick: [.typeDl],
        .newfoundlandAndLabrador: [.typeDl],
        .novaScotia: [.typeDl, .typeId],
        .ontario: [.typeDl, .typeId, .typeHealthInsuranceCard],
        .quebec: [.typeDl],
        .saskatchewan: [.typeDl, .typeId],
        .yukon: [.typeDl]
    ]
    
    func isDocumentSupported(result: MBBlinkIdMultiSideRecognizerResult) -> Bool {
        guard let region = result.classInfo?.region, let type = result.classInfo?.type else {
            return false
        }
        let jurisdiction = result.barcodeResult?.jurisdiction ?? ""
        let unsupportedJurisdictions = ["PE", "NT", "NU"]
        return self.supportedDocuments.contains { entry in
            entry.key == region && entry.value.contains(type)
        } && !unsupportedJurisdictions.contains(jurisdiction)
    }
    
    lazy var classifiers: [Classifier] = {
        let models = Bundle(for: type(of: self)).paths(forResourcesOfType: "nv", inDirectory: nil)
        var suffix = 0
        return models.compactMap { model in
            let filename = (model as NSString).pathComponents.last!
            guard filename.starts(with: "license") || filename.starts(with: "licence") else {
                return nil
            }
            suffix += 1
            return Classifier(name: "licence".appending("00\(suffix)".suffix(2)), filename: model)
        }
    }()
}
