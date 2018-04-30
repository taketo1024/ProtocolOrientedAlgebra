//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwiftyMath

class QuaternionTests: XCTestCase {

    typealias A = 𝐇

    func testIntLiteral() {
        let a: A = 5
        XCTAssertEqual(a, A(5, 0, 0, 0))
    }

    func testFloatLiteral() {
        let a: A = 0.5
        XCTAssertEqual(a, A(0.5, 0, 0, 0))
    }

    func testFromReal() {
        let a = A(𝐑(3.14))
        XCTAssertEqual(a, A(3.14, 0, 0, 0))
    }

    func testFromComplex() {
        let a = A(𝐂(2, 3))
        XCTAssertEqual(a, A(2, 3, 0, 0))
    }

    func testSum() {
        let a = A(1, 2, 3, 4)
        let b = A(3, 4, 5, 6)
        XCTAssertEqual(a + b, A(4, 6, 8, 10))
    }

    func testZero() {
        let a = A(3, 4, 5, 6)
        let o = A.zero
        XCTAssertEqual(o + o, o)
        XCTAssertEqual(a + o, a)
        XCTAssertEqual(o + a, a)
    }

    func testNeg() {
        let a = A(3, 4, -1, 2)
        XCTAssertEqual(-a, A(-3, -4, 1, -2))
    }

    func testConj() {
        let a = A(3, 4, -1, 2)
        XCTAssertEqual(a.conjugate, A(3, -4, 1, -2))
    }

    // (-1 + 3i + 4j + 3k) × (2 + 3i -1j + 4k)

    func testMul() {
        let a = A(-1, 3, 4, 3)
        let b = A(2, 3, -1, 4)
        XCTAssertEqual(a * b, A(-19, 22, 6, -13))
    }

    func testId() {
        let a = A(2, 1, 4, 3)
        let e = A.identity
        XCTAssertEqual(e * e, e)
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }

    func testInv() {
        let a = A(1, -1, 1, 1)
        XCTAssertEqual(a.inverse!, A(0.25, 0.25, -0.25, -0.25))

        let o = A.zero
        XCTAssertNil(o.inverse)
    }

    func testPow() {
        let a = A(1, 2, 3, 4)
        XCTAssertEqual(a.pow(0), A.identity)
        XCTAssertEqual(a.pow(1), A(1, 2, 3, 4))
        XCTAssertEqual(a.pow(2), A(4, -20, 22, -8))
        XCTAssertEqual(a.pow(3), A(10, -124, -30, 80))
    }

    func testAbs() {
        let a = A(1, 2, 3, 4)
        XCTAssertEqual(a.abs, √30)
    }

    func testNorm() {
        let a = A(1, 2, 3, 4)
        XCTAssertEqual(a.norm, √30)
    }
}
