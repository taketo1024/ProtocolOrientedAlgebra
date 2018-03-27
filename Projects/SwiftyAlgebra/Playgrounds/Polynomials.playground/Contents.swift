//: Playground - noun: a place where people can play

import Foundation
import SwiftyAlgebra

// Polynomials Example

typealias P = Polynomial<𝐐>
do {
    let f = P(2, 0, 1) // x^2 + 2
    let g = P(3, 2)    // 2x + 3

    f + g
    f * g
}
