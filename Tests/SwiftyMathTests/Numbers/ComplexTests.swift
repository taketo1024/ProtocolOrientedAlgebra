//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwiftyMath

class ComplexTests: XCTestCase {

    typealias A = 𝐂

    func testIntLiteral() {
        let a: A = 5
        XCTAssertEqual(a, A(5, 0))
    }

    func testFloatLiteral() {
        let a: A = 0.5
        XCTAssertEqual(a, A(0.5, 0))
    }

    func testFromRational() {
        let a = A(from: 𝐐(3, 4))
        XCTAssertEqual(a, A(0.75, 0))
    }

    func testFromReal() {
        let a = A(𝐑(3.14))
        XCTAssertEqual(a, A(3.14, 0))
    }

    func testFromPolar() {
        let a = A(r: 2, θ: π / 4)
        XCTAssertEqual(a, A(√2, √2))
    }

    func testSum() {
        let a = A(1, 2)
        let b = A(3, 4)
        XCTAssertEqual(a + b, A(4, 6))
    }

    func testZero() {
        let a = A(3, 4)
        let o = A.zero
        XCTAssertEqual(o + o, o)
        XCTAssertEqual(a + o, a)
        XCTAssertEqual(o + a, a)
    }

    func testNeg() {
        let a = A(3, 4)
        XCTAssertEqual(-a, A(-3, -4))
    }

    func testConj() {
        let a = A(3, 4)
        XCTAssertEqual(a.conjugate, A(3, -4))
    }

    func testMul() {
        let a = A(2, 3)
        let b = A(4, 5)
        XCTAssertEqual(a * b, A(-7, 22))
    }

    func testId() {
        let a = A(2, 1)
        let e = A.identity
        XCTAssertEqual(e * e, e)
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }

    func testInv() {
        let a = A(3, 4)
        XCTAssertEqual(a.inverse!, A(0.12, -0.16))

        let o = A.zero
        XCTAssertNil(o.inverse)
    }

    func testDiv() {
        let a = A(2, 3)
        let b = A(3, 4)

        XCTAssertEqual(a / b, A(0.72, 0.04))
    }

    func testPow() {
        let a = A(2, 1)
        XCTAssertEqual(a.pow(0), A.identity)
        XCTAssertEqual(a.pow(1), A(2, 1))
        XCTAssertEqual(a.pow(2), A(3, 4))
        XCTAssertEqual(a.pow(3), A(2, 11))

        XCTAssertEqual(a.pow(-1), A(0.4, -0.2))
        XCTAssertEqual(a.pow(-2), A(0.12, -0.16))
        XCTAssertEqual(a.pow(-3), A(0.016, -0.088))
    }

    func testAbs() {
        let a = A(2, 4)
        XCTAssertEqual(a.abs, √20)
        XCTAssertEqual((-a).abs, √20)
        XCTAssertEqual(a.conjugate.abs, √20)
    }

    func testArg() {
        let a = A(1, 1)
        XCTAssertEqual(a.arg, π / 4)
    }

    func testNorm() {
        let a = A(2, 4)
        XCTAssertEqual(a.norm, √20)
        XCTAssertEqual((-a).norm, √20)
        XCTAssertEqual(a.conjugate.norm, √20)
    }
}
