//
//  PolynomialTests.swift
//  SwiftyKnotsTests
//
//  Created by Taketo Sano on 2018/04/10.
//

import XCTest
@testable import SwmCore

class LaurentPolynomialTests: XCTestCase {
    struct _x: PolynomialIndeterminate {
        static let symbol: String = "x"
    }
    
    typealias A = LaurentPolynomial<𝐙, _x>
    typealias B = LaurentPolynomial<𝐐, _x>

    func testInitFromInt() {
        let a = A(from: 3)
        XCTAssertEqual(a, A(elements: [0: 3]))
    }
    
    func testInitFromIntLiteral() {
        let a: A = 3
        XCTAssertEqual(a, A(elements: [0: 3]))
    }
    
    func testProperties() {
        let a = A(elements: [-2: 3, -1: 4, 1: 5])
        XCTAssertEqual(a.leadCoeff, 5)
        XCTAssertEqual(a.leadTerm, A(elements: [1: 5]))
        XCTAssertEqual(a.constTerm, .zero)
        XCTAssertEqual(a.leadExponent, 1)
//        XCTAssertEqual(a.lowestExponent, -2)
        XCTAssertEqual(a.degree, 1)
    }
    
    func testSum() {
        let a = A(elements: [-1: 1, 0: 2, 1: 3])
        let b = A(elements: [-2: 1, 0: 2])
        XCTAssertEqual(a + b, A(elements: [-2: 1, -1: 1, 0: 4, 1: 3]))
    }
    
    func testZero() {
        let a = A(elements: [-1: 1, 0: 2, 1: 3])
        XCTAssertEqual(a + A.zero, a)
        XCTAssertEqual(A.zero + a, a)
    }
    
    func testNeg() {
        let a = A(elements: [-1: 1, 0: 2, 1: 3])
        XCTAssertEqual(-a, A(elements: [-1: -1, 0: -2, 1: -3]))
    }
    
    func testMul() {
        let a = A(elements: [-1: 1, 0: 2, 1: 3])
        let b = A(elements: [-1: 3, 0: 4])
        XCTAssertEqual(a * b, A(elements: [-2: 3, -1: 10, 0: 17, 1: 12]))
    }
    
    func testId() {
        let a = A(elements: [-1: 1, 0: 2, 1: 3])
        let e = A.identity
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }
    
    func testInv() {
        let a = A(-1)
        XCTAssertEqual(a.inverse!, a)
        
        let b = A(elements: [-3: 1])
        XCTAssertEqual(b.inverse!, A(elements: [3: 1]))
        
        let c = A(elements: [-4: -1])
        XCTAssertEqual(c.inverse!, A(elements: [4: -1]))
        
        let d = A(elements: [0: 1, 1: 1])
        XCTAssertNil(d.inverse)
    }
    
    func testPow() {
        let a = A(elements: [-1: 1, 0: 2])
        XCTAssertEqual(a.pow(0), A.identity)
        XCTAssertEqual(a.pow(1), a)
        XCTAssertEqual(a.pow(2), A(elements: [-2: 1, -1: 4, 0: 4]))
        XCTAssertEqual(a.pow(3), A(elements: [-3: 1, -2: 6, -1: 12, 0: 8]))
    }
    
    func testDerivative() {
        let a = A(elements: [-2: 1, -1: 2, 0: 3, 1: 4, 2: 5])
        XCTAssertEqual(a.derivative, A(elements: [-3: -2, -2: -2, -1: 0, 0: 4, 1: 10]))
    }
    
    func testEvaluate() {
        let a = A(elements: [-1: 1, 0: 2, 1: 3])
        XCTAssertEqual(a.evaluate(by: -1), -2)
        
        let b = B(elements: [-1: 1, 0: 2, 1: 3])
        XCTAssertEqual(b.evaluate(by: 2), 17./2)
    }
    
    func testIsMonic() {
        let a = A(elements: [-1: 1, 0: 2, 1: 1])
        XCTAssertTrue(a.isMonic)
        
        let b = A(elements: [-1: 1, 0: 2, 1: 3])
        XCTAssertFalse(b.isMonic)
    }
}
