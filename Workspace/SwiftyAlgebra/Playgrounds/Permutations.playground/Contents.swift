//: Playground - noun: a place where people can play

import Foundation
import SwiftyAlgebra

// Aliases populary used in Math.

typealias Z = IntegerNumber
typealias Q = RationalNumber
typealias R = RealNumber

// Permutation Example.

typealias S_5 = Permutation<_5>

do {
    let σ = S_5(cyclic: 0, 1, 2) // cyclic notation
    let τ = S_5([0: 2, 1: 3, 2: 4, 3: 0, 4: 1]) // two-line notation

    σ[1]
    τ[2]

    (σ * τ) [3]  // 3 -> 0 -> 1
    (τ * σ) [3]  // 3 -> 3 -> 0

    σ * τ != τ * σ   // noncommutative
}
