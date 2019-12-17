//
//  Gamma.swift
//  ID Capture
//
//  Created by Jakub Dolejs on 17/12/2019.
//  Based on http://commons.apache.org/proper/commons-math/
//

import Foundation

class Gamma {
    
    static let lanczos: [Double] = {
        return [
            0.99999999999999709182,
            57.156235665862923517,
            -59.597960355475491248,
            14.136097974741747174,
            -0.49191381609762019978,
            0.33994649984811888699e-4,
            0.46523628927048575665e-4,
            -0.98374475304879564677e-4,
            0.15808870322491248884e-3,
            -0.21026444172410488319e-3,
            0.21743961811521264320e-3,
            -0.16431810653676389022e-3,
            0.84418223983852743293e-4,
            -0.26190838401581408670e-4,
            0.36899182659531622704e-5
        ]
    }()
    
    static let halfLog2Pi: Double = {
        return 0.5 * log(2.0 * Double.pi)
    }()
    
    static func regularizedGammaP(a: Double, x: Double, epsilon: Double, maxIterations: Int) throws -> Double {
        if a.isNaN || x.isNaN || a <= 0.0 || x < 0.0 {
            return Double.nan
        } else if x == 0.0 {
            return 0.0
        } else if x >= a + 1 {
            return try 1.0 - regularizedGammaQ(a: a, x: x, epsilon: epsilon, maxIterations: maxIterations)
        } else {
            var n: Double = 0
            var an: Double = 1.0 / a
            var sum: Double = an
            while abs(an/sum) > epsilon && Int(n) < maxIterations && sum < Double.infinity {
                n = n + 1.0
                an = an * (x / (a + n))
                sum += an
            }
            if Int(n) >= maxIterations {
                throw NSError()
            } else if sum.isInfinite {
                return 1.0
            } else {
                return exp(0 - x + (a * log(x)) - logGamma(a)) * sum
            }
        }
    }
    
    static func regularizedGammaQ(a: Double, x: Double, epsilon: Double, maxIterations: Int) throws -> Double {
        if a.isNaN || x.isNaN || a <= 0.0 || x < 0.0 {
            return Double.nan
        }
        if x == 0.0 {
            return 1.0
        }
        if x < a + 1.0 {
            return try 1.0 - regularizedGammaP(a: a, x: x, epsilon: epsilon, maxIterations: maxIterations)
        }
        let cf = ContinuedFraction(getA: { (n: Int, x: Double) in
            ((2.0 * Double(n)) + 1.0) - a + x
        }, getB: { (n: Int, x: Double) in
            Double(n) * (a - Double(n))
        })
        var ret = try 1.0 / cf.evaluate(x: x, epsilon: epsilon, maxIterations: maxIterations)
        ret = exp(0 - x + (a * log(x)) - logGamma(a)) * ret
        return ret
    }
    
    static func logGamma(_ x: Double) -> Double {
        if x.isNaN || x <= 0.0 {
            return Double.nan
        }
        let g: Double = 607.0 / 128.0
        var sum: Double = 0.0
        var i = lanczos.count-1
        while i>0 {
            sum += lanczos[i] / (x + Double(i))
            i -= 1
        }
        sum += lanczos[0]
        
        let tmp: Double = x + g + 0.5
        return ((x + 0.5) * log(tmp)) - tmp + halfLog2Pi + log(sum / x)
    }
}
