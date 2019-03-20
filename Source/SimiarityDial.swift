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
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = UIBezierPath(rect: bounds).cgPath
        backgroundLayer.fillColor = UIColor(red: 0.21176470588235, green: 0.68627450980392, blue: 0.0, alpha: 1.0).cgColor
        
        let minAngle = CGFloat.pi
        let maxAngle = CGFloat.pi * 2
        let thresholdAngle = threshold / max * (maxAngle - minAngle)
        let thresholdPoint = CGPoint(x: bounds.midX - cos(thresholdAngle)*bounds.width/2, y: bounds.minY + sin(thresholdAngle)*bounds.height*2)
        let arcCentre = CGPoint(x: bounds.midX, y: bounds.minY)
        let ovalRect = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: bounds.height * 2)
        
        let maskPath = UIBezierPath(ovalIn: ovalRect)
        maskPath.append(UIBezierPath(ovalIn: ovalRect.insetBy(dx: 20, dy: 20)).reversing())
        maskPath.append(UIBezierPath(rect: CGRect(x: bounds.minX, y: bounds.maxY, width: bounds.width, height: bounds.height)).reversing())
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        
        let backgroundMaskLayer = CAShapeLayer()
        backgroundMaskLayer.path = maskPath.cgPath
        
        let noPath = UIBezierPath()
        noPath.move(to: arcCentre)
        noPath.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY))
        noPath.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        if threshold / max > 0.5 {
            noPath.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        }
        noPath.addLine(to: thresholdPoint)
        noPath.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.red.cgColor
        let transform = CGAffineTransform(scaleX: 1, y: -1).concatenating(CGAffineTransform(translationX: 0, y: bounds.height))
        noPath.apply(transform)
        shapeLayer.path = noPath.cgPath
        
        self.addSublayer(backgroundLayer)
        self.addSublayer(shapeLayer)
        backgroundLayer.mask = backgroundMaskLayer
        shapeLayer.mask = maskLayer
        
        let dotRadius: CGFloat = 12
        let dotPath = UIBezierPath(ovalIn: CGRect(x: bounds.midX-dotRadius/2, y: bounds.maxY-dotRadius/2, width: dotRadius, height: dotRadius))
        let dotLayer = CAShapeLayer()
        dotLayer.fillColor = UIColor.black.cgColor
        dotLayer.path = dotPath.cgPath
        self.addSublayer(dotLayer)
        
        let scoreAngle = score / max * (maxAngle - minAngle)
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
