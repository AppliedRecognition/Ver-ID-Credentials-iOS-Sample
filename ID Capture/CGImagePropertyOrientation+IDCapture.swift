//
//  CGImagePropertyOrientation+IDCapture.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 26/10/2021.
//  Copyright © 2021 Applied Recognition Inc. All rights reserved.
//

import UIKit

extension CGImagePropertyOrientation {
    
    var uiImageOrientation: UIImage.Orientation {
        switch self {
        case .up:
            return .up
        case .left:
            return .left
        case .right:
            return .right
        case .down:
            return .down
        case .upMirrored:
            return .upMirrored
        case .leftMirrored:
            return .leftMirrored
        case .rightMirrored:
            return .rightMirrored
        case .downMirrored:
            return .downMirrored
        default:
            return .up
        }
    }
}
