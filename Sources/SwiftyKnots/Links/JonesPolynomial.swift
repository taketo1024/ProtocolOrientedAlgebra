//
//  JonesPolynomial.swift
//  SwiftyKnots
//
//  Created by Taketo Sano on 2018/04/04.
//

import SwiftyMath

public extension Link {
    
    // a polynomial in 𝐙[A, 1/A]
    public var KauffmanBracket: LaurentPolynomial<𝐙> {
        return _KauffmanBracket(normalized: false)
    }
    
    private func _KauffmanBracket(normalized b: Bool) -> LaurentPolynomial<𝐙> {
        let A = LaurentPolynomial<𝐙>.indeterminate(symbol: "A")
        if let x = crossings.first(where: {$0.isCrossing}) {
            let i = crossings.index(of: x)!
            let pair = splicedPair(at: i)
            return A * pair.0._KauffmanBracket(normalized: b) + A.pow(-1) * pair.1._KauffmanBracket(normalized: b)
        } else {
            let n = components.count
            return ( -A.pow(2) - A.pow(-2) ).pow(b ? n - 1 : n)
        }
    }
    
    // a polynomial in 𝐐[q, 1/q] where q = -A^{-2}
    // TODO replace with t = -q^2 = A^{-4} to get J ∈ 𝐙[√t, 1/√t]
    public var JonesPolynomial: LaurentPolynomial<𝐙> {
        return _JonesPolynomial(normalized: true)
    }
    
    public var unnormalizedJonesPolynomial: LaurentPolynomial<𝐙> {
        return _JonesPolynomial(normalized: false)
    }
    
    public func _JonesPolynomial(normalized b: Bool) -> LaurentPolynomial<𝐙> {
        let A = LaurentPolynomial<𝐙>.indeterminate(symbol: "A")
        let f = (-A).pow( -3 * writhe ) * _KauffmanBracket(normalized: b)
        let J = LaurentPolynomial(symbol: "q", degreeRange: -f.upperDegree/2 ... -f.lowerDegree/2) { i in
            (-1).pow(i) * f.coeff(-2 * i)
        }
        return J
    }
}
