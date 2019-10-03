//
//  PolynomialTests.swift
//  SwiftyKnotsTests
//
//  Created by Taketo Sano on 2018/04/10.
//

import XCTest
@testable import SwiftyMath

class LaurentPolynomialTests: XCTestCase {
    typealias A = LaurentPolynomial<_x, 𝐙>
    typealias B = LaurentPolynomial<_x, 𝐐>

    func testInitFromInt() {
        let a = A(from: 3)
        XCTAssertEqual(a, A(coeffs: [0: 3]))
    }
    
    func testInitFromCoeffList() {
        let a = A(coeffs: 3, 5, -1)
        XCTAssertEqual(a, A(coeffs: [0: 3, 1: 5, 2: -1]))
    }
    
    func testInitFromLowerDegreeCoeffList() {
        let a = A(lowestExponent: -2, coeffs: 3, 5, -1, 3)
        XCTAssertEqual(a, A(coeffs: [-2: 3, -1: 5, 0: -1, 1: 3]))
    }
    
    func testProperties() {
        let a = A(lowestExponent: -2, coeffs: 3, 4, 0, 5)
        XCTAssertEqual(a.leadCoeff, 5)
        XCTAssertEqual(a.leadTerm, A(coeffs: [1: 5]))
        XCTAssertEqual(a.constTerm, 0)
        XCTAssertEqual(a.maxExponent, .some(1))
        XCTAssertEqual(a.minExponent, .some(-2))
        XCTAssertEqual(a.degree, 1)
    }
    
    func testSum() {
        let a = A(lowestExponent: -1, coeffs:    1, 2, 3)
        let b = A(lowestExponent: -2, coeffs: 1, 0, 2)
        XCTAssertEqual(a + b, A(lowestExponent: -2, coeffs: 1, 1, 4, 3))
    }
    
    func testZero() {
        let a = A(lowestExponent: -1, coeffs: 1, 2, 3)
        XCTAssertEqual(a + A.zero, a)
        XCTAssertEqual(A.zero + a, a)
    }
    
    func testNeg() {
        let a = A(lowestExponent: -1, coeffs: 1, 2, 3)
        XCTAssertEqual(-a, A(lowestExponent: -1, coeffs: -1, -2, -3))
    }
    
    func testMul() {
        let a = A(lowestExponent: -1, coeffs: 1, 2, 3)
        let b = A(lowestExponent: -1, coeffs: 3, 4)
        XCTAssertEqual(a * b, A(lowestExponent: -2, coeffs: 3, 10, 17, 12))
    }
    
    func testId() {
        let a = A(lowestExponent: -1, coeffs: 1, 2, 3)
        let e = A.identity
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }
    
    func testInv() {
        let a = A(coeffs: -1)
        XCTAssertEqual(a.inverse!, a)
        
        let b = A(lowestExponent: 3, coeffs: 1)
        XCTAssertEqual(b.inverse!, A(lowestExponent: -3, coeffs: 1))
        
        let c = A(lowestExponent: -4, coeffs: -1)
        XCTAssertEqual(c.inverse!, A(lowestExponent: 4, coeffs: -1))
        
        let d = A(coeffs: 1, 1)
        XCTAssertNil(d.inverse)
    }
    
    func testPow() {
        let a = A(lowestExponent: -1, coeffs: 1, 2)
        XCTAssertEqual(a.pow(0), A.identity)
        XCTAssertEqual(a.pow(1), a)
        XCTAssertEqual(a.pow(2), A(lowestExponent: -2, coeffs: 1, 4, 4))
        XCTAssertEqual(a.pow(3), A(lowestExponent: -3, coeffs: 1, 6, 12, 8))
    }
    
    func testDerivative() {
        let a = A(lowestExponent: -2, coeffs: 1, 2, 3, 4, 5)
        XCTAssertEqual(a.derivative, A(lowestExponent: -3, coeffs: -2, -2, 0, 4, 10))
    }
    
    func testEvaluate() {
        let a = A(lowestExponent: -1, coeffs: 1, 2, 3)
        XCTAssertEqual(a.evaluate(by: -1), -2)
        
        let b = B(lowestExponent: -1, coeffs: 1, 2, 3)
        XCTAssertEqual(b.evaluate(by: 2), 17./2)
    }
    
    func testIsMonic() {
        let a = A(lowestExponent: -1, coeffs: 1, 2, 1)
        XCTAssertTrue(a.isMonic)
        
        let b = A(lowestExponent: -1, coeffs: 1, 2, 3)
        XCTAssertFalse(b.isMonic)
    }
    
    func testToMonic() {
        let a = B(lowestExponent: -1, coeffs: 1, 2, 1)
        XCTAssertEqual(a.toMonic(), a)
        
        let b = B(lowestExponent: -1, coeffs: 1, 2, 3)
        XCTAssertEqual(b.toMonic(), B(lowestExponent: -1, coeffs: 1./3, 2./3, 1))
    }
}
