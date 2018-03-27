//: Playground - noun: a place where people can play

import Foundation
import SwiftyAlgebra

// Matrix Example

do {
    typealias M = Matrix<_2,_2, 𝐙>

    let a = M(1, 2, 3, 4)
    let b = M(2, 1, 1, 2)
    a + b
    a * b

    a + b == b + a  // commutative
    a * b != b * a  // noncommutative

    let c = Matrix<_3,_3, 𝐙>(1, 2, 3, 0, -4, 1, 0, 3, -1)

    c.determinant
    c.inverse!
    c * c.inverse!
}

// Matrix Elimination

do {
    typealias M = Matrix<_3,_3, 𝐙>

    let A = M(1, -2, -6, 2, 4, 12, 1, -4, -12)

    let E = A.eliminate(form: .Diagonal, debug: false) // set `debug: true` to see the elimination process.
    let (B, P, Q) = (E.result, E.left, E.right)

    B == P * A * Q
}
