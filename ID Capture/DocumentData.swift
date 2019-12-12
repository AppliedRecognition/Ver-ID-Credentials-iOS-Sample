//
//  DocumentData.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 12/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit
import Microblink

struct DocumentData {
    
    let firstName: String?
    let lastName: String?
    let address: String?
    let dateOfBirth: String?
    let dateOfExpiry: String?
    let dateOfIssue: String?
    let documentNumber: String?
    let sex: String?

    init(result: MBBlinkIdCombinedRecognizerResult) {
        self.firstName = result.firstName
        self.lastName = result.lastName
        self.address = result.address
        self.dateOfBirth = result.dateOfBirth?.originalDateString
        self.dateOfIssue = result.dateOfIssue?.originalDateString
        self.dateOfExpiry = result.dateOfExpiry?.originalDateString
        self.documentNumber = result.documentNumber
        self.sex = result.sex
    }
    
    init(result: MBUsdlCombinedRecognizerResult) {
        self.firstName = result.firstName
        self.lastName = result.lastName
        self.address = result.address
        self.dateOfBirth = result.dateOfBirth?.originalDateString
        self.dateOfIssue = result.dateOfIssue?.originalDateString
        self.dateOfExpiry = result.dateOfExpiry?.originalDateString
        self.documentNumber = result.documentNumber
        self.sex = result.sex
    }
}
