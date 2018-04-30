//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwiftyMath

class RationalTests: XCTestCase {

    typealias A = 𝐐

    func testEquality() {
        XCTAssertEqual(A(1), A(1, 1))
        XCTAssertEqual(A(2), A(2, 1))
        XCTAssertEqual(A(2, 1), A(4, 2))
        XCTAssertEqual(A(-2, 1), A(4, -2))
    }

    func testIntLiteral() {
        let a: A = 5
        XCTAssertEqual(a, A(5, 1))
    }

    func testRationalDivOp() {
        let a = 2./3
        XCTAssertEqual(a, A(2, 3))
    }

    func testSum() {
        let a = A(3, 2)
        let b = A(4, 5)
        XCTAssertEqual(a + b, A(23, 10))
    }

    func testZero() {
        let a = A(3)
        let o = A.zero
        XCTAssertEqual(o + o, o)
        XCTAssertEqual(a + o, a)
        XCTAssertEqual(o + a, a)
    }

    func testNeg() {
        let a = A(3, 2)
        XCTAssertEqual(-a, A(-3, 2))
    }

    func testMul() {
        let a = A(3, 5)
        let b = A(13, 6)
        XCTAssertEqual(a * b, A(13, 10))
    }

    func testId() {
        let a = A(3, 4)
        let e = A.identity
        XCTAssertEqual(e * e, e)
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }

    func testInv() {
        let a = A(3, 5)
        XCTAssertEqual(a.inverse!, A(5, 3))

        let o = A.zero
        XCTAssertNil(o.inverse)
    }

    func testDiv() {
        let a = A(3, 5)
        let b = A(3, 2)

        XCTAssertEqual(a / b, A(2, 5))
    }

    func testPow() {
        let a = A(2, 3)
        XCTAssertEqual(a.pow(0), A(1))
        XCTAssertEqual(a.pow(1), A(2, 3))
        XCTAssertEqual(a.pow(2), A(4, 9))
        XCTAssertEqual(a.pow(3), A(8, 27))

        XCTAssertEqual(a.pow(-1), A(3, 2))
        XCTAssertEqual(a.pow(-2), A(9, 4))
        XCTAssertEqual(a.pow(-3), A(27, 8))
    }

    func testIneq() {
        let a = A(4, 5)
        let b = A(3, 2)
        XCTAssertTrue(a < b)
    }

    func testSign() {
        let a = A(4, 5)
        let b = A(-4, 5)
        XCTAssertEqual(a.sign, 1)
        XCTAssertEqual(b.sign, -1)
        XCTAssertEqual(A.zero, 0)
    }

    func testAbs() {
        let a = A(4, 5)
        let b = A(-4, 5)
        XCTAssertEqual(a.abs, a)
        XCTAssertEqual(b.abs, a)
    }

    func testNorm() {
        let a = A(4, 5)
        let b = A(-4, 5)
        XCTAssertEqual(a.norm, 0.8)
        XCTAssertEqual(b.norm, 0.8)
    }
}
