//: Playground - noun: a place where people can play

import Foundation
import SwiftyAlgebra

// Aliases populary used in Math.

typealias Z = IntegerNumber
typealias Q = RationalNumber

// Polynomials Example

typealias Qx = Polynomial<Q>
do {
    let f = Qx(2, 0, 1) // x^2 + 2
    let g = Qx(3, 2)    // 2x + 3

    f + g
    f * g
}
