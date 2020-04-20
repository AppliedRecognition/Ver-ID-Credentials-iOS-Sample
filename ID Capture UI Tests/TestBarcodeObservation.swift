//
//  TestBarcodeObservation.swift
//  ID Capture UI Tests
//
//  Created by Jakub Dolejs on 20/04/2020.
//  Copyright © 2020 Applied Recognition Inc. All rights reserved.
//

import Foundation
import Vision

class TestBarcodeObservation: VNBarcodeObservation {
    
    private let payloadString: String
    
    init(payload: String) {
        self.payloadString = payload
        super.init()
    }
    
    required init?(coder: NSCoder) {
        if let data = coder.decodeData() {
            payloadString = String(data: data, encoding: .utf8) ?? ""
        } else {
            payloadString = ""
        }
        super.init(coder: coder)
    }
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        if let data = self.payloadString.data(using: .utf8) {
            coder.encode(data)
        }
    }
    
    override var payloadStringValue: String? {
        return self.payloadString
    }
}
