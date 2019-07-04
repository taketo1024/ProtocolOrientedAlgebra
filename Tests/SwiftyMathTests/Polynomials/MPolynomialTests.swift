//
//  PolynomialTests.swift
//  SwiftyKnotsTests
//
//  Created by Taketo Sano on 2018/04/10.
//

import XCTest
@testable import SwiftyMath

class MPolynomialTests: XCTestCase {
    typealias A = xyPolynomial<𝐙>
    
    func testIndeterminates_xy() {
        XCTAssertTrue (_xy.isFinite)
        XCTAssertEqual(_xy.numberOfIndeterminates, 2)
        XCTAssertEqual(_xy.degree(0), 1)
        XCTAssertEqual(_xy.degree(1), 1)
        XCTAssertEqual(_xy.symbol(0), "x")
        XCTAssertEqual(_xy.symbol(1), "y")
        XCTAssertEqual(_xy.totalDegree(exponents: [2, 3]), 5)
    }
    
    func testIndeterminates_xn() {
        XCTAssertFalse(_xn.isFinite)
        XCTAssertEqual(_xn.numberOfIndeterminates, Int.max)
        XCTAssertEqual(_xn.degree(0), 1)
        XCTAssertEqual(_xn.degree(1), 1)
        XCTAssertEqual(_xn.symbol(0), "x₀")
        XCTAssertEqual(_xn.symbol(1), "x₁")
        XCTAssertEqual(_xn.totalDegree(exponents: [2, 3, 7]), 12)
    }
    
    func testInitFromInt() {
        let a = A(from: 3)
        XCTAssertTrue(a.isConst)
        XCTAssertEqual(a.constTerm, 3)
        XCTAssertEqual(a.coeff(1), 0)
    }

    func testInitFromCoeffList() {
        // 3x²y + 2x + y + 1
        let a = A(coeffs: [[]: 1, [1]: 2, [0, 1]: 1, [2, 1]: 3])
        XCTAssertTrue(!a.isConst)
        XCTAssertEqual(a.constTerm, 1)
        XCTAssertEqual(a.coeff(1), 2)
        XCTAssertEqual(a.coeff(0, 1), 1)
        XCTAssertEqual(a.coeff(2, 1), 3)
    }
    
    func testUniqueness() {
        let a = A(13)
        let b = A(coeffs: [[0,0]: 13])
        XCTAssertEqual(a, b)
    }
    
    func testUniqueness2() {
        let a = A(coeffs: [[1]: 1])
        let b = A(coeffs: [[1,0]: 1, [0,1]: 0])
        XCTAssertEqual(a, b)
    }
    
    func testSum() {
        let a = A(coeffs: [[]: 1, [1]: 1, [0, 1]: 1]) // x + y + 1
        let b = A(coeffs: [[1]: -1, [0, 1]: 2, [1, 1]: 3]) // 3xy - x + 2y
        XCTAssertEqual(a + b, A(coeffs: [[]: 1, [0, 1]: 3, [1, 1]: 3]))
    }

    func testZero() {
        let a = A(coeffs: [[]: 1, [1]: 1, [0, 1]: 1]) // x + y + 1
        XCTAssertEqual(a + A.zero, a)
        XCTAssertEqual(A.zero + a, a)
    }

    func testNeg() {
        let a = A(coeffs: [[]: 1, [1]: 1, [0, 1]: 1])
        XCTAssertEqual(-a, A(coeffs: [[]: -1, [1]: -1, [0, 1]: -1]))
    }

    func testMul() {
        let a = A(coeffs: [[1]: 1, [0, 1]: 1]) // x + y
        let b = A(coeffs: [[1]: 2, [0, 1]: -1]) // 2x - y
        XCTAssertEqual(a * b, A(coeffs: [[2]: 2, [1, 1]: 1, [0, 2]: -1]))
    }

    func testId() {
        let a = A(coeffs: [[]: 1, [1]: 1, [0, 1]: 1])
        let e = A.identity
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }

    func testInv() {
        let a = A(-1)
        XCTAssertEqual(a.inverse!, a)

        let b = A(3)
        XCTAssertNil(b.inverse)

        let c = A(coeffs: [[]: 1, [1]: 1, [0, 1]: 1])
        XCTAssertNil(c.inverse)
    }

    func testEvaluate() {
        let a = A(coeffs: [[]: 2, [1]: -1, [0, 1]: 2, [1, 1]: 3]) // f(x,y) = 3xy - x + 2y + 2
        XCTAssertEqual(a.evaluate(at: 1, 2), 11)                  // f(1, 2) = 6 - 1 + 4 + 2
    }

    func testSymmetricPolynomial() {
        XCTAssertEqual(A.elementarySymmetric(0), A(1))
        XCTAssertEqual(A.elementarySymmetric(1), A(coeffs: [[1]: 1, [0, 1]: 1]))
        XCTAssertEqual(A.elementarySymmetric(2), A(coeffs: [[1, 1]: 1]))
    }
}
