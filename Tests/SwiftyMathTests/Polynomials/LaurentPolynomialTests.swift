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
        let a = A(coeffs: [3, 5, -1, 3], shift: -2)
        XCTAssertEqual(a, A(coeffs: [-2: 3, -1: 5, 0: -1, 1: 3]))
    }
    
    func testProperties() {
        let a = A(coeffs: [3, 4, 0, 5], shift: -2)
        XCTAssertEqual(a.leadCoeff, 5)
        XCTAssertEqual(a.leadTerm, A(coeffs: [1: 5]))
        XCTAssertEqual(a.constTerm, 0)
        XCTAssertEqual(a.highestPower, 1)
        XCTAssertEqual(a.lowestPower, -2)
        XCTAssertEqual(a.degree, 1)
    }
    
    func testSum() {
        let a = A(coeffs: [   1, 2, 3], shift: -1)
        let b = A(coeffs: [1, 0, 2], shift: -2)
        XCTAssertEqual(a + b, A(coeffs: [1, 1, 4, 3], shift: -2))
    }
    
    func testZero() {
        let a = A(coeffs: [1, 2, 3], shift: -1)
        XCTAssertEqual(a + A.zero, a)
        XCTAssertEqual(A.zero + a, a)
    }
    
    func testNeg() {
        let a = A(coeffs: [1, 2, 3], shift: -1)
        XCTAssertEqual(-a, A(coeffs: [-1, -2, -3], shift: -1))
    }
    
    func testMul() {
        let a = A(coeffs: [1, 2, 3], shift: -1)
        let b = A(coeffs: [3, 4], shift: -1)
        XCTAssertEqual(a * b, A(coeffs: [3, 10, 17, 12], shift: -2))
    }
    
    func testId() {
        let a = A(coeffs: [1, 2, 3], shift: -1)
        let e = A.identity
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }
    
    func testInv() {
        let a = A(coeffs: -1)
        XCTAssertEqual(a.inverse!, a)
        
        let b = A(coeffs: [1], shift: 3)
        XCTAssertEqual(b.inverse!, A(coeffs: [1], shift: -3))
        
        let c = A(coeffs: [-1], shift: -4)
        XCTAssertEqual(c.inverse!, A(coeffs: [-1], shift: 4))
        
        let d = A(coeffs: 1, 1)
        XCTAssertNil(d.inverse)
    }
    
    func testPow() {
        let a = A(coeffs: [1, 2], shift: -1)
        XCTAssertEqual(a.pow(0), A.identity)
        XCTAssertEqual(a.pow(1), a)
        XCTAssertEqual(a.pow(2), A(coeffs: [1, 4, 4], shift: -2))
        XCTAssertEqual(a.pow(3), A(coeffs: [1, 6, 12, 8], shift: -3))
    }
    
    func testDerivative() {
        let a = A(coeffs: [1, 2, 3, 4, 5], shift: -2)
        XCTAssertEqual(a.derivative, A(coeffs: [-2, -2, 0, 4, 10], shift: -3))
    }
    
    func testEvaluate() {
        let a = A(coeffs: [1, 2, 3], shift: -1)
        XCTAssertEqual(a.evaluate(at: -1), -2)
        
        let b = B(coeffs: [1, 2, 3], shift: -1)
        XCTAssertEqual(b.evaluate(at: 2), 17./2)
    }
    
    func testIsMonic() {
        let a = A(coeffs: [1, 2, 1], shift: -1)
        XCTAssertTrue(a.isMonic)
        
        let b = A(coeffs: [1, 2, 3], shift: -1)
        XCTAssertFalse(b.isMonic)
    }
    
    func testToMonic() {
        let a = B(coeffs: [1, 2, 1], shift: -1)
        XCTAssertEqual(a.toMonic(), a)
        
        let b = B(coeffs: [1, 2, 3], shift: -1)
        XCTAssertEqual(b.toMonic(), B(coeffs: [1./3, 2./3, 1], shift: -1))
    }
}
