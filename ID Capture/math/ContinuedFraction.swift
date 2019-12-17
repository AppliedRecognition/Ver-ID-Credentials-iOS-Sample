//
//  ContinuedFraction.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 17/12/2019.
//  Based on http://commons.apache.org/proper/commons-math/
//

import Foundation

class ContinuedFraction {
    
    let getA: (Int,Double) -> Double
    let getB: (Int,Double) -> Double
    
    init(getA: @escaping (Int,Double) -> Double, getB: @escaping (Int,Double) -> Double) {
        self.getA = getA
        self.getB = getB
    }
    
    func evaluate(x: Double, epsilon: Double, maxIterations: Int) throws -> Double {
        var p0 = 1.0
        var p1 = getA(0, x)
        var q0 = 0.0
        var q1 = 1.0
        var c = p1 / q1
        var n: Int = 0
        var relativeError = Double.greatestFiniteMagnitude
        while (n < maxIterations && relativeError > epsilon) {
            n += 1
            let a = getA(n, x)
            let b = getB(n, x)
            var p2 = a * p1 + b * p0
            var q2 = a * q1 + b * q0
            var infinite = false
            if p2.isInfinite || q2.isInfinite {
                /*
                 * Need to scale. Try successive powers of the larger of a or b
                 * up to 5th power. Throw ConvergenceException if one or both
                 * of p2, q2 still overflow.
                 */
                var scaleFactor = 1.0
                var lastScaleFactor = 1.0
                let maxPower = 5
                let scale = max(a,b)
                if (scale <= 0) {  // Can't scale
                    throw NSError()
                }
                infinite = true
                for _ in 0..<maxPower {
                    lastScaleFactor = scaleFactor
                    scaleFactor *= scale
                    if a != 0.0 && a > b {
                        p2 = p1 / lastScaleFactor + (b / scaleFactor * p0)
                        q2 = q1 / lastScaleFactor + (b / scaleFactor * q0)
                    } else if b != 0 {
                        p2 = (a / scaleFactor * p1) + p0 / lastScaleFactor
                        q2 = (a / scaleFactor * q1) + q0 / lastScaleFactor
                    }
                    infinite = p2.isInfinite || q2.isInfinite
                    if !infinite {
                        break
                    }
                }
            }

            if infinite {
               // Scaling failed
               throw NSError()
            }

            let r = p2 / q2

            if r.isNaN {
                throw NSError()
            }
            relativeError = abs(r / c - 1.0)

            // prepare for next iteration
            c = p2 / q2
            p0 = p1
            p1 = p2
            q0 = q1
            q1 = q2
        }

        if n >= maxIterations {
            throw NSError()
        }

        return c
    }
}
