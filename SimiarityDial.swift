//
//  SimiarityDial.swift
//  VerIDIDCaptureTest
//
//  Created by Jakub Dolejs on 09/01/2018.
//  Copyright © 2018 Applied Recognition, Inc. All rights reserved.
//

import UIKit

/// CALayer that shows a needle representing a score between 0.0 and 1.0
class SimiarityDial: CAShapeLayer {
    
    /// Score between 0.0 and 1.0
    var score: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func display() {
        if self.bounds.isEmpty {
            return
        }
        let elipseRect = CGRect(x: 0, y: self.bounds.height / 93 * 7, width: self.bounds.width, height: self.bounds.width / 248 * 158)
        let angleOffset: CGFloat = 0.57
        let minAngle = CGFloat.pi + angleOffset
        let maxAngle = CGFloat.pi * 2 - angleOffset
        let angle = minAngle + self.score * (maxAngle - minAngle)
        let length = elipseRect.maxX - elipseRect.midX
        let height = sin(angle) * length * (elipseRect.height / elipseRect.width)
        let width = cos(angle) * length
        let origin = CGPoint(x: elipseRect.midX, y: elipseRect.midY)
        let destination = CGPoint(x: elipseRect.midX + width, y: elipseRect.midY + height)
        let path = UIBezierPath()
        path.move(to: origin)
        path.addLine(to: destination)
        self.path = path.cgPath
        super.display()
    }
}
