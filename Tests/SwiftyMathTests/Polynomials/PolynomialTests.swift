//
//  PolynomialTests.swift
//  SwiftyKnotsTests
//
//  Created by Taketo Sano on 2018/04/10.
//

import XCTest
@testable import SwiftyMath

class PolynomialTests: XCTestCase {
    typealias A = Polynomial<_x, 𝐙>
    typealias B = Polynomial<_x, 𝐐>

    func testInitFromInt() {
        let a = A(from: 3)
        XCTAssertEqual(a, A(coeffs: [0: 3]))
    }
    
    func testInitFromCoeffList() {
        let a = A(coeffs: 3, 5, -1)
        XCTAssertEqual(a, A(coeffs: [0: 3, 1: 5, 2: -1]))
    }
    
    func testProperties() {
        let a = A(coeffs: 3, 4, 0, 5)
        XCTAssertEqual(a.leadCoeff, 5)
        XCTAssertEqual(a.leadTerm, A(coeffs: [3: 5]))
        XCTAssertEqual(a.constTerm, 3)
        XCTAssertEqual(a.maxExponent, .some(3))
        XCTAssertEqual(a.minExponent, .some(0))
        XCTAssertEqual(a.degree, 3)
        XCTAssertFalse(a.isSingleTerm)
    }
    
    func testIndeterminate() {
        let x = A.indeterminate
        XCTAssertEqual(x, A(coeffs: [1: 1]))
        XCTAssertEqual(x.description, "x")
        XCTAssertEqual(x.degree, 1)
        XCTAssertEqual(x.maxExponent, .some(1))
        XCTAssertEqual(x.minExponent, .some(1))
        XCTAssertTrue (x.isSingleTerm)
    }
    
    func testSum() {
        let a = A(coeffs: 1, 2, 3)
        let b = A(coeffs: 0, 1, 0, 2)
        XCTAssertEqual(a + b, A(coeffs: 1, 3, 3, 2))
    }
    
    func testZero() {
        let a = A(coeffs: 1, 2, 3)
        XCTAssertEqual(a + A.zero, a)
        XCTAssertEqual(A.zero + a, a)
    }
    
    func testNeg() {
        let a = A(coeffs: 1, 2, 3)
        XCTAssertEqual(-a, A(coeffs: -1, -2, -3))
    }
    
    func testScalarMul() {
        let a = A(coeffs: 1, 2, 3)
        XCTAssertEqual(3 * a, A(coeffs: 3, 6, 9))
    }
    
    func testMul() {
        let a = A(coeffs: 1, 2, 3)
        let b = A(coeffs: 3, 4)
        XCTAssertEqual(a * b, A(coeffs: 3, 10, 17, 12))
    }
    
    func testId() {
        let a = A(coeffs: 1, 2, 3)
        let e = A.identity
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }
    
    func testInv() {
        let a = A(coeffs: -1)
        XCTAssertEqual(a.inverse!, a)
        
        let b = A(coeffs: 3)
        XCTAssertNil(b.inverse)
        
        let c = A(coeffs: 1, 1)
        XCTAssertNil(c.inverse)
    }
    
    func testPow() {
        let a = A(coeffs: 1, 2)
        XCTAssertEqual(a.pow(0), A.identity)
        XCTAssertEqual(a.pow(1), a)
        XCTAssertEqual(a.pow(2), A(coeffs: 1, 4, 4))
        XCTAssertEqual(a.pow(3), A(coeffs: 1, 6, 12, 8))
    }
    
    func testDerivative() {
        let a = A(coeffs: 1, 2, 3, 4)
        XCTAssertEqual(a.derivative, A(coeffs: 2, 6, 12))
    }
    
    func testEvaluate() {
        let a = A(coeffs: 1, 2, 3)
        XCTAssertEqual(a.evaluate(by: -1), 2)
    }
    
    func testIsMonic() {
        let a = A(coeffs: 1, 2, 1)
        XCTAssertTrue(a.isMonic)
        
        let b = A(coeffs: 1, 2, 3)
        XCTAssertFalse(b.isMonic)
    }
    
    func testToMonic() {
        let a = B(coeffs: 1, 2, 1)
        XCTAssertEqual(a.toMonic(), a)
        
        let b = B(coeffs: 1, 2, 3)
        XCTAssertEqual(b.toMonic(), B(coeffs: 1./3, 2./3, 1))
    }
    
    func testEucDiv() {
        let a = B(coeffs: 1, 2, 1)
        let b = B(coeffs: 3, 2)
        let (q, r) = a /% b
        XCTAssertEqual(q, B(coeffs: 1./4, 1./2))
        XCTAssertEqual(r, B(1./4))
        XCTAssertTrue(a.euclideanDegree > r.euclideanDegree)
        XCTAssertEqual(a, q * b + r)
    }
    
    struct _t: PolynomialIndeterminate {
        static var symbol = "t"
        static var degree = 2
    }
    
    func testCustomIndeterminate() {
        typealias T = Polynomial<_t, 𝐙>
        let t = T.indeterminate
        XCTAssertEqual(t, T(coeffs: [1: 1]))
        XCTAssertEqual(t.description, "t")
        XCTAssertEqual(t.degree, 2)
        XCTAssertEqual(t.maxExponent, .some(1))
        XCTAssertEqual(t.minExponent, .some(1))
    }
}
