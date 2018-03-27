//: Playground - noun: a place where people can play

import Foundation
import SwiftyAlgebra

// Construct an algebraic extension over Q:
// K = 𝐐(√2) = 𝐐[x]/(x^2 - 2).

do {
    struct p: _Polynomial {                            // p = x^2 - 2, as a struct
        typealias K = 𝐐
        static let value = Polynomial<𝐐>(-2, 0, 1)
    }

    typealias I = PolynomialIdeal<p>                   // I = (x^2 - 2), static
    typealias K = QuotientField<Polynomial<𝐐>, I>      // K = Q[x]/I

    let a = Polynomial<𝐐>(0, 1).asQuotient(in: K.self) // a = x mod I
    a * a == 2
}
