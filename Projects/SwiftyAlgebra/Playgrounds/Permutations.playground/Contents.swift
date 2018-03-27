//: Playground - noun: a place where people can play

import Foundation
import SwiftyAlgebra

// Permutation Example.

typealias P = Permutation

do {
    let σ = P(cyclic: 0, 1, 2) // cyclic notation
    let τ = P([0: 2, 1: 3, 2: 4, 3: 0, 4: 1]) // two-line notation

    σ[1]
    τ[2]

    σ * τ
    τ * σ

    σ.inverse
    τ.inverse
}

print(SymmetricGroup<_5>.allElements)

