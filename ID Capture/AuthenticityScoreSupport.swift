//
//  AuthenticityScoreSupport.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 14/12/2022.
//

import Foundation
import Microblink
import VerIDCore

class AuthenticityScoreSupport {
    
    static let `default` = AuthenticityScoreSupport()
    
    private var supportedDocuments: [MBRegion:[MBType]] = [
        .alberta: [.typeDl, .typeId],
        .britishColumbia: [.typeDl, .typeDlPublicServicesCard, .typeId, .typePublicServicesCard],
        .manitoba: [.typeDl, .typeId],
        .newBrunswick: [.typeDl],
        .newfoundlandAndLabrador: [.typeDl],
        .novaScotia: [.typeDl],
        .ontario: [.typeDl, .typeId],
        .quebec: [.typeDl],
        .saskatchewan: [.typeDl],
        .yukon: [.typeDl]
    ]
    
    func isDocumentSupported(result: MBBlinkIdCombinedRecognizerResult) -> Bool {
        guard let region = result.classInfo?.region, let type = result.classInfo?.type else {
            return false
        }
        return self.supportedDocuments.contains { entry in
            entry.key == region && entry.value.contains(type)
        }
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
