//
//  Globals.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 23/04/2020.
//  Copyright © 2020 Applied Recognition Inc. All rights reserved.
//

import Foundation
import RxVerID
import VerIDCore

let rxVerID = RxVerID()
let rxVerIDCard: RxVerID = {
    let detRecFactory = VerIDFaceDetectionRecognitionFactory(apiSecret: nil)
    detRecFactory.settings.faceExtractQualityThreshold = 5.0
    let verid = RxVerID()
    verid.faceDetectionFactory = detRecFactory
    verid.faceRecognitionFactory = detRecFactory
    return verid
}()
