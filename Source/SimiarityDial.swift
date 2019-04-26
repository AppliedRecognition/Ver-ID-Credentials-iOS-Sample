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
    var max: CGFloat = 1 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var threshold: CGFloat = 0.5 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func display() {
        if self.bounds.isEmpty {
            return
        }
        let lineWidth: CGFloat = 20
        let arcCenter = CGPoint(x: self.bounds.midX, y: self.bounds.maxY)
        let radius = min(self.bounds.midX, self.bounds.height) - lineWidth / 2
        let startAngle = CGFloat.pi
        let endAngle = CGFloat.pi * 2
        let arcPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
        
        let failLayer = CAShapeLayer()
        failLayer.fillColor = nil
        failLayer.strokeColor = UIColor.red.cgColor
        failLayer.lineWidth = lineWidth
        failLayer.strokeEnd = threshold / max
        failLayer.path = arcPath
        self.addSublayer(failLayer)
        
        let passLayer = CAShapeLayer()
        passLayer.fillColor = nil
        passLayer.strokeColor = UIColor(red: 0.21176470588235, green: 0.68627450980392, blue: 0.0, alpha: 1.0).cgColor
        passLayer.lineWidth = lineWidth
        passLayer.strokeStart = threshold / max
        passLayer.path = arcPath
        self.addSublayer(passLayer)
        
        let dotRadius: CGFloat = 12
        let dotPath = UIBezierPath(ovalIn: CGRect(x: bounds.midX-dotRadius/2, y: bounds.maxY-dotRadius/2, width: dotRadius, height: dotRadius))
        let dotLayer = CAShapeLayer()
        dotLayer.fillColor = UIColor.black.cgColor
        dotLayer.path = dotPath.cgPath
        self.addSublayer(dotLayer)
        
        let scoreAngle = score / max * (endAngle - startAngle)
        let scorePoint = CGPoint(x: bounds.midX - cos(scoreAngle)*bounds.width/2, y: bounds.maxY - sin(scoreAngle)*bounds.height)
        let needlePath = UIBezierPath()
        needlePath.move(to: CGPoint(x: bounds.midX, y: bounds.maxY))
        needlePath.addLine(to: scorePoint)
        let scoreLayer = CAShapeLayer()
        scoreLayer.strokeColor = UIColor.black.cgColor
        scoreLayer.lineWidth = 3
        scoreLayer.path = needlePath.cgPath
        self.addSublayer(scoreLayer)
        
        super.display()
    }
}
