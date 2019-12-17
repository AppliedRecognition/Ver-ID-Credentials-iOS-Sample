//
//  NormalDistribution.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 17/12/2019.
//  Based on http://commons.apache.org/proper/commons-math/
//

import Foundation

class NormalDistribution {
    
    let mean: Double
    let standardDeviation: Double
    
    convenience init() {
        self.init(mean: 0, standardDeviation: 1)
    }
    
    init(mean: Double, standardDeviation: Double) {
        self.mean = mean
        self.standardDeviation = standardDeviation
    }
    
    func cumulativeProbability(_ x: Double) throws -> Double {
        let dev = x - self.mean
        if abs(dev) > 40.0 * self.standardDeviation {
            return dev < 0 ? 0.0 : 1.0
        }
        return try 0.5 * (1 + Erf.erf(dev / (standardDeviation * 2.squareRoot())))
    }
}
