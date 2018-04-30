//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwiftyMath

class RealTests: XCTestCase {

    typealias A = 𝐑

    func testIntLiteral() {
        let a: A = 5
        XCTAssertEqual(a, A(5))
    }

    func testFloatLiteral() {
        let a: A = 0.5
        XCTAssertEqual(a, A(0.5))
    }

    func testFromRational() {
        let a = A(from: 𝐐(3, 4))
        XCTAssertEqual(a, A(0.75))
    }

    func testSum() {
        let a = A(0.1)
        let b = A(0.2)
        XCTAssertEqual(a + b, A(0.3))
    }

    func testZero() {
        let a = A(3.14)
        let o = A.zero
        XCTAssertEqual(o + o, o)
        XCTAssertEqual(a + o, a)
        XCTAssertEqual(o + a, a)
    }

    func testNeg() {
        let a = A(4.124)
        XCTAssertEqual(-a, A(-4.124))
    }

    func testMul() {
        let a = A(0.12)
        let b = A(2.456)
        XCTAssertEqual(a * b, A(0.29472))
    }

    func testId() {
        let a = A(3.14)
        let e = A.identity
        XCTAssertEqual(e * e, e)
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }

    func testInv() {
        let a = A(0.25)
        XCTAssertEqual(a.inverse!, A(4.0))

        let b = A(4.0)
        XCTAssertEqual(b.inverse!, A(0.25))

        let o = A.zero
        XCTAssertNil(o.inverse)
    }

    func testDiv() {
        let a = A(4.2)
        let b = A(0.4)

        XCTAssertEqual(a / b, A(10.5))
    }

    func testPow() {
        let a = A(2.0)
        XCTAssertEqual(a.pow(0), A(1))
        XCTAssertEqual(a.pow(1), A(2))
        XCTAssertEqual(a.pow(2), A(4))
        XCTAssertEqual(a.pow(3), A(8))

        XCTAssertEqual(a.pow(-1), A(0.5))
        XCTAssertEqual(a.pow(-2), A(0.25))
        XCTAssertEqual(a.pow(-3), A(0.125))
    }

    func testIneq() {
        let a = A(3.14)
        let b = A(22.0 / 7.0)
        XCTAssertTrue(a < b)
    }

    func testAbs() {
        let a = A(4.1)
        let b = A(-4.1)
        XCTAssertEqual(a.abs, a)
        XCTAssertEqual(b.abs, a)
    }

    func testNorm() {
        let a = A(4.1)
        let b = A(-4.1)
        XCTAssertEqual(a.norm, 4.1)
        XCTAssertEqual(b.norm, 4.1)
    }
}
