//
//  MultiplicativeSequence.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/12.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public struct MultiplicativeSequence<K: Field>: CustomStringConvertible {
    internal let map: (Int) -> MPolynomial<K>

    public init(belongingTo f: PowerSeries<K>) {
        self.map = { n in
            let Is = n.partitions
            return Is.sum { I in
                let c = I.elements.multiply { i in f.coeff(i) }
                let s_I = SymmetricPolynomial<K>.monomial(n, I).elementaryDecomposition()
                return c * s_I
            }
        }
    }

    public subscript(n: Int) -> MPolynomial<K> {
        return map(n)
    }

    public var description: String {
        return (0 ..< 5).map{ self[$0].description }.joined(separator: " + ") + " ..."
    }
}

public extension MultiplicativeSequence where K == 𝐐 {
    public static var HirzebruchL: MultiplicativeSequence<K> {
        let B = BernoulliNumber
        let f = PowerSeries<K> { n in
            (n == 0) ? 1 : K(2.pow(2 * n), (2 * n).factorial) * B(2 * n)
        }
        return MultiplicativeSequence(belongingTo: f)
    }
}
