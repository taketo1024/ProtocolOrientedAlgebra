import Foundation

// see: https://en.wikipedia.org/wiki/Factorization_of_polynomials#Obtaining_linear_factors

/* TODO not working.
public extension _Polynomial where T == NormalPolynomialType, R == 𝐐 {
    public func factorize() -> [Polynomial<𝐐>] {
        typealias Q = 𝐐

        if degree == 0 {
            return [self]
        }

        let m = coeffs.values.reduce(1) { lcm($0, $1.denominator) } // lcm of all denoms
        let c = coeffs.values.reduce(0) { gcd($0, m * $1.numerator / $1.denominator) }
        let d = m ./ c

        let (an, a0) = ((d * leadCoeff).numerator, (d * constTerm).numerator)

        var result: [Polynomial<Q>] = []
        var q = self

        for b1 in an.divisors {
            for b0 in a0.divisors.flatMap({[$0, -$0]}) {
                let q0 = Polynomial(coeffs: Q(b1), -Q(b0)) // b1x - b0
                while q != .identity {
                    let (q1, r) = q /% q0
                    if r == .zero {
                        q = q1
                        result.append(q0)
                    } else {
                        break
                    }
                }
            }
        }

        if(q != .identity) {
            result.append(q)
        }

        return result
    }
}
*/
