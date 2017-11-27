import Foundation


// cf. https://en.wikipedia.org/wiki/Factorization_of_polynomials#Obtaining_linear_factors
public func factorize(_ p: Polynomial<RationalNumber>) -> [Polynomial<RationalNumber>] {
    typealias Q = RationalNumber

    if p.degree == 0 {
        return [p]
    }

    let m = p.coeffs.reduce(1) { lcm($0, $1.denominator) } // lcm of all denoms
    let c = p.coeffs.reduce(0) { gcd($0, m * $1.numerator / $1.denominator) }
    let d = Q(m, c)
    let (an, a0) = ((d * p.leadCoeff).numerator, (d * p.coeffs[0]).numerator)

    var result: [Polynomial<Q>] = []
    var q = p

    for b1 in an.divisors {
        for b0 in a0.divisors.flatMap({[$0, -$0]}) {
            let q0 = Polynomial<Q>(Q(b1), Q(b0)) // b1x - b0
            while q != 1 {
                let (q1, r) = q /% q0
                if r == 0 {
                    q = q1
                    result.append(q0)
                } else {
                    break
                }
            }
        }
    }
    if(q != 1) {
        result.append(q)
    }

    return result
}

