//: Playground - noun: a place where people can play

import Foundation
import SwiftyAlgebra

// Aliases populary used in Math.

typealias Z = IntegerNumber
typealias Q = RationalNumber

// Rational Number Sample.

do {
    let a = Q(4, 5)
    let b = Q(3, 2)
    a + b
    a * b
    b / a
}

// Integer Quotient Example

typealias Z_4 = IntegerQuotientRing<_4>

do {
    let x: Z_4 = 3
    x + x == 2
    x * 3 == 1

    Z_4.printAddTable()
    Z_4.printMulTable()
}

typealias F_5 = IntegerQuotientField<_5>

do {
    let x: F_5 = 2
    x.inverse!
    x * x.inverse! == 1

    F_5.printAddTable()
    F_5.printMulTable()
    F_5.printExpTable()
}
