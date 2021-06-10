//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwmCore

class RealTests: XCTestCase {
    
    typealias A = 𝐑
    
    func testIntLiteral() {
        let a: A = 5
        assertApproxEqual(a, A(5))
    }
    
    func testFloatLiteral() {
        let a: A = 0.5
        assertApproxEqual(a, A(0.5))
    }
    
    func testFromRational() {
        let a = A(from: 𝐐(3, 4))
        assertApproxEqual(a, A(0.75))
    }
    
    func testSum() {
        let a = A(1)
        let b = A(2)
        
        assertApproxEqual(a + b, 3)
    }
    
    func testZero() {
        let a = A(3.14)
        let o = A.zero
        assertApproxEqual(o + o, o)
        assertApproxEqual(a + o, a)
        assertApproxEqual(o + a, a)
    }
    
    func testNeg() {
        let a = A(4.124)
        assertApproxEqual(-a, A(-4.124))
    }
    
    func testMul() {
        let a = A(0.12)
        let b = A(2.456)
        assertApproxEqual(a * b, A(0.29472))
    }
    
    func testId() {
        let a = A(3.14)
        let e = A.identity
        assertApproxEqual(e * e, e)
        assertApproxEqual(a * e, a)
        assertApproxEqual(e * a, a)
    }
    
    func testInv() {
        let a = A(0.25)
        assertApproxEqual(a.inverse!, A(4.0))
        
        let b = A(4.0)
        assertApproxEqual(b.inverse!, A(0.25))
        
        let o = A.zero
        XCTAssertNil(o.inverse)
    }
    
    func testDiv() {
        let a = A(4.2)
        let b = A(0.4)
        
        assertApproxEqual(a / b, A(10.5))
    }
    
    func testPow() {
        let a = A(2.0)
        assertApproxEqual(a.pow(0), A(1))
        assertApproxEqual(a.pow(1), A(2))
        assertApproxEqual(a.pow(2), A(4))
        assertApproxEqual(a.pow(3), A(8))
        
        assertApproxEqual(a.pow(-1), A(0.5))
        assertApproxEqual(a.pow(-2), A(0.25))
        assertApproxEqual(a.pow(-3), A(0.125))
    }
    
    func testIneq() {
        let a = A(3.14)
        let b = A(22.0 / 7.0)
        XCTAssertTrue(a < b)
    }
    
    func testAbs() {
        let a = A(4.1)
        let b = A(-4.1)
        assertApproxEqual(a.abs, a)
        assertApproxEqual(b.abs, a)
    }
    
    func testApproxEqual() {
        let a = A(0.1)
        let b = A(0.2)
        
        XCTAssertTrue((a + b).isApproximatelyEqualTo(0.3))
    }
    
    func testRandom() {
        var results: Set<A> = []
        
        for _ in 0 ..< 100 {
            let x = A.random()
            results.insert(x)
        }
        XCTAssertTrue(results.isUnique)
        XCTAssertTrue(results.contains{ $0 > 0 })
        XCTAssertTrue(results.contains{ $0 < 0 })
    }
    
    func testRandomInRange() {
        let range: Range<A> = -100 ..< 100
        var results: Set<A> = []
        
        for _ in 0 ..< 100 {
            let x = A.random(in: range)
            results.insert(x)
        }
        XCTAssertTrue(results.allSatisfy{ range.contains($0) })
        XCTAssertTrue(results.isUnique)
        XCTAssertTrue(results.contains{ $0 > 0 })
        XCTAssertTrue(results.contains{ $0 < 0 })
    }

    func testRandomInClosedRange() {
        let range: ClosedRange<A> = -100 ... 100
        var results: Set<A> = []
        
        for _ in 0 ..< 100 {
            let x = A.random(in: range)
            results.insert(x)
            XCTAssertTrue(range.contains(x))
        }
        XCTAssertTrue(results.allSatisfy{ range.contains($0) })
        XCTAssertTrue(results.isUnique)
        XCTAssertTrue(results.contains{ $0 > 0 })
        XCTAssertTrue(results.contains{ $0 < 0 })
    }
    
    private func assertApproxEqual(_ x: 𝐑, _ y: 𝐑, error e: 𝐑 = 0.0001) {
        XCTAssertTrue(x.isApproximatelyEqualTo(y, error: e))
    }
}
