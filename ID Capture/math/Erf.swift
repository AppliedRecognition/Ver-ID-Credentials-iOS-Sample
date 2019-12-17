//
//  Erf.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 17/12/2019.
//  Based on http://commons.apache.org/proper/commons-math/
//

import Foundation

class Erf {
    
    static func erf(_ x: Double) throws -> Double {
        if abs(x) > 40.0 {
            return x > 0 ? 1 : -1
        }
        let ret = try Gamma.regularizedGammaP(a: 0.5, x: x * x, epsilon: 1.0e-15, maxIterations: 10000)
        return x < 0 ? 0-ret : ret
    }
}
