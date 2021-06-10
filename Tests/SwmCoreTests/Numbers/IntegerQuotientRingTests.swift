//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwmCore

class IntegerQuotientRingTests: XCTestCase {
    
    typealias A = IntegerQuotientRing<_4> // not a Field
    
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
        XCTAssertEqual(a * b, A(2))
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
        
        let c = A(3)
        XCTAssertEqual(c.inverse!, A(3))

        let o = A.zero
        XCTAssertNil(o.inverse)
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
    
    func testIsField() {
        XCTAssertFalse(IntegerQuotientRing<_4>.isField)
        XCTAssertTrue( IntegerQuotientRing<_5>.isField)
    }
    
    func testAllElements() {
        XCTAssertEqual(A.allElements, [0, 1, 2, 3])
        XCTAssertEqual(A.countElements, 4)
    }
    
    func testRandom() {
        var results: Set<A> = []
        
        for _ in 0 ..< 100 {
            let x = A.random()
            results.insert(x)
        }
        XCTAssertTrue(results.count == A.countElements)
    }
}
