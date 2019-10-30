//
//  F2Tests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2019/10/30.
//

import XCTest
import SwiftyMath

class F2Tests: XCTestCase {
    typealias A = 𝐅₂
    
    func testIntLiteral() {
        let a: A = 2
        XCTAssertEqual(a, A(2))
    }
    
    func testSum() {
        let a = A(2)
        let b = A(3)
        XCTAssertEqual(a + b, A(1))
    }
    
    func testZero() {
        let a = A(3)
        let o = A.zero
        XCTAssertEqual(o + o, o)
        XCTAssertEqual(a + o, a)
        XCTAssertEqual(o + a, a)
    }
    
    func testNeg() {
        let a = A(3)
        XCTAssertEqual(-a, A(1))
    }
    
    func testIntLiteralSum() {
        let a = A(2)
        let b = a + 1
        XCTAssertEqual(b, A(3))
    }
    
    func testMul() {
        let a = A(2)
        let b = A(3)
        XCTAssertEqual(a * b, .zero)
    }
    
    func testId() {
        let a = A(2)
        let e = A.identity
        XCTAssertEqual(e * e, e)
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }
    
    func testInv() {
        let a = A(1)
        XCTAssertEqual(a.inverse!, A(1))
        
        let b = A(2)
        XCTAssertNil(b.inverse)
    }
    
    func testIntLiteralMul() {
        let a = A(2)
        let b = a * 3
        XCTAssertEqual(b, A(2))
    }
    
    func testPow() {
        let a = A(3)
        XCTAssertEqual(a.pow(0), A.identity)
        XCTAssertEqual(a.pow(1), A(3))
        XCTAssertEqual(a.pow(2), A(1))
        XCTAssertEqual(a.pow(3), A(3))
    }
    
    func testAllElements() {
        XCTAssertEqual(A.allElements, [0, 1])
        XCTAssertEqual(A.countElements, 2)
    }
}
