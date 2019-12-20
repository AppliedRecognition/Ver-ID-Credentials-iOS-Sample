//
//  DocumentData.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 12/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit
import Microblink
import AAMVABarcodeParser

class MicroblinkDocumentData: DocumentData {
    
    init(result: MBBlinkIdCombinedRecognizerResult) {
        super.init()
        if let firstName = result.firstName {
            self.setValue(DataField(description: "First name", originalValue: firstName, parsedValue: firstName), forEntryID: "firstName")
        }
        if let lastName = result.lastName {
            self.setValue(DataField(description: "Last name", originalValue: lastName, parsedValue: lastName), forEntryID: "lastName")
        }
        if let address = result.address {
            self.setValue(DataField(description: "Address", originalValue: address, parsedValue: address), forEntryID: "address")
        }
        if let dateOfBirth = result.dateOfBirth?.originalDateString {
            self.setValue(DataField(description: "Date of birth", originalValue: dateOfBirth, parsedValue: dateOfBirth), forEntryID: "dateOfBirth")
        }
        if let dateOfIssue = result.dateOfIssue?.originalDateString {
            self.setValue(DataField(description: "Date of issue", originalValue: dateOfIssue, parsedValue: dateOfIssue), forEntryID: "dateOfIssue")
        }
        if let dateOfExpiry = result.dateOfExpiry?.originalDateString {
            self.setValue(DataField(description: "Date of expiry", originalValue: dateOfExpiry, parsedValue: dateOfExpiry), forEntryID: "dateOfExpiry")
        }
        if let documentNumber = result.documentNumber {
            self.setValue(DataField(description: "Document number", originalValue: documentNumber, parsedValue: documentNumber), forEntryID: "documentNumber")
        }
        if let sex = result.sex {
            self.setValue(DataField(description: "Sex", originalValue: sex, parsedValue: sex), forEntryID: "sex")
        }
        self.rawData = nil
    }
    
    init(result: MBUsdlCombinedRecognizerResult) {
        super.init()
        if let firstName = result.firstName {
            self.setValue(DataField(description: "First name", originalValue: firstName, parsedValue: firstName), forEntryID: "firstName")
        }
        if let lastName = result.lastName {
            self.setValue(DataField(description: "Last name", originalValue: lastName, parsedValue: lastName), forEntryID: "lastName")
        }
        if let address = result.address {
            self.setValue(DataField(description: "Address", originalValue: address, parsedValue: address), forEntryID: "address")
        }
        if let dateOfBirth = result.dateOfBirth?.originalDateString {
            self.setValue(DataField(description: "Date of birth", originalValue: dateOfBirth, parsedValue: dateOfBirth), forEntryID: "dateOfBirth")
        }
        if let dateOfIssue = result.dateOfIssue?.originalDateString {
            self.setValue(DataField(description: "Date of issue", originalValue: dateOfIssue, parsedValue: dateOfIssue), forEntryID: "dateOfIssue")
        }
        if let dateOfExpiry = result.dateOfExpiry?.originalDateString {
            self.setValue(DataField(description: "Date of expiry", originalValue: dateOfExpiry, parsedValue: dateOfExpiry), forEntryID: "dateOfExpiry")
        }
        if let documentNumber = result.documentNumber {
            self.setValue(DataField(description: "Document number", originalValue: documentNumber, parsedValue: documentNumber), forEntryID: "documentNumber")
        }
        if let sex = result.sex {
            self.setValue(DataField(description: "Sex", originalValue: sex, parsedValue: sex), forEntryID: "sex")
        }
        self.rawData = result.data()
    }
    
    init(result: MBUsdlRecognizerResult) {
        super.init()
        if let firstName = result.firstName {
            self.setValue(DataField(description: "First name", originalValue: firstName, parsedValue: firstName), forEntryID: "firstName")
        }
        if let lastName = result.lastName {
            self.setValue(DataField(description: "Last name", originalValue: lastName, parsedValue: lastName), forEntryID: "lastName")
        }
        if let address = result.address {
            self.setValue(DataField(description: "Address", originalValue: address, parsedValue: address), forEntryID: "address")
        }
        if let dateOfBirth = result.dateOfBirth?.originalDateString {
            self.setValue(DataField(description: "Date of birth", originalValue: dateOfBirth, parsedValue: dateOfBirth), forEntryID: "dateOfBirth")
        }
        if let dateOfIssue = result.dateOfIssue?.originalDateString {
            self.setValue(DataField(description: "Date of issue", originalValue: dateOfIssue, parsedValue: dateOfIssue), forEntryID: "dateOfIssue")
        }
        if let dateOfExpiry = result.dateOfExpiry?.originalDateString {
            self.setValue(DataField(description: "Date of expiry", originalValue: dateOfExpiry, parsedValue: dateOfExpiry), forEntryID: "dateOfExpiry")
        }
        if let documentNumber = result.documentNumber {
            self.setValue(DataField(description: "Document number", originalValue: documentNumber, parsedValue: documentNumber), forEntryID: "documentNumber")
        }
        if let sex = result.sex {
            self.setValue(DataField(description: "Sex", originalValue: sex, parsedValue: sex), forEntryID: "sex")
        }
        self.rawData = result.data()
    }
}
