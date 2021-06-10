//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwmCore

class ComplexTests: XCTestCase {
    
    typealias A = 𝐂
    
    func testFromInt() {
        let a = A(from: 5)
        assertApproxEqual(a, A(5, 0))
    }
    
    func testFromReal() {
        let a = A(𝐑(3.14))
        assertApproxEqual(a, A(3.14, 0))
    }
    
    func testFromPolar() {
        let a = A(r: 2, θ: π / 4)
        XCTAssertTrue(a.isApproximatelyEqualTo(A(√2, √2)))
    }
    
    func testSum() {
        let a = A(1, 2)
        let b = A(3, 4)
        assertApproxEqual(a + b, A(4, 6))
    }
    
    func testZero() {
        let a = A(3, 4)
        let o = A.zero
        assertApproxEqual(o + o, o)
        assertApproxEqual(a + o, a)
        assertApproxEqual(o + a, a)
    }
    
    func testNeg() {
        let a = A(3, 4)
        assertApproxEqual(-a, A(-3, -4))
    }
    
    func testConj() {
        let a = A(3, 4)
        assertApproxEqual(a.conjugate, A(3, -4))
    }
    
    func testMul() {
        let a = A(2, 3)
        let b = A(4, 5)
        assertApproxEqual(a * b, A(-7, 22))
    }
    
    func testId() {
        let a = A(2, 1)
        let e = A.identity
        assertApproxEqual(e * e, e)
        assertApproxEqual(a * e, a)
        assertApproxEqual(e * a, a)
    }
    
    func testInv() {
        let a = A(3, 4)
        assertApproxEqual(a.inverse!, A(0.12, -0.16))
        
        let o = A.zero
        XCTAssertNil(o.inverse)
    }
    
    func testDiv() {
        let a = A(2, 3)
        let b = A(3, 4)
        
        XCTAssertTrue((a / b).isApproximatelyEqualTo(A(0.72, 0.04), error: 0.0001))
    }
    
    func testPow() {
        let a = A(2, 1)
        assertApproxEqual(a.pow(0), A.identity)
        assertApproxEqual(a.pow(1), A(2, 1))
        assertApproxEqual(a.pow(2), A(3, 4))
        assertApproxEqual(a.pow(3), A(2, 11))
        
        assertApproxEqual(a.pow(-1), A(0.4, -0.2))
        assertApproxEqual(a.pow(-2), A(0.12, -0.16))
        assertApproxEqual(a.pow(-3), A(0.016, -0.088))
    }
    
    func testAbs() {
        let a = A(2, 4)
        assertApproxEqual(a.abs, √20)
        assertApproxEqual((-a).abs, √20)
        assertApproxEqual(a.conjugate.abs, √20)
    }
    
    func testArg() {
        let a = A(1, 1)
        assertApproxEqual(a.arg, π / 4)
    }
    
    func testRandom() {
        var results: Set<A> = []
        
        for _ in 0 ..< 100 {
            let x = A.random()
            results.insert(x)
        }
        XCTAssertTrue(results.isUnique)
        XCTAssertTrue(results.contains{ $0.realPart > 0 && $0.imaginaryPart > 0 })
        XCTAssertTrue(results.contains{ $0.realPart > 0 && $0.imaginaryPart < 0 })
        XCTAssertTrue(results.contains{ $0.realPart < 0 && $0.imaginaryPart > 0 })
        XCTAssertTrue(results.contains{ $0.realPart < 0 && $0.imaginaryPart < 0 })
    }
    
    func testRandomInRange() {
        let range: Range<A.Base> = -100 ..< 100
        var results: Set<A> = []
        
        for _ in 0 ..< 100 {
            let x = A.random(in: range)
            results.insert(x)
            XCTAssertTrue(range.contains(x.realPart))
            XCTAssertTrue(range.contains(x.imaginaryPart))
        }
        XCTAssertTrue(results.isUnique)
        XCTAssertTrue(results.contains{ $0.realPart > 0 && $0.imaginaryPart > 0 })
        XCTAssertTrue(results.contains{ $0.realPart > 0 && $0.imaginaryPart < 0 })
        XCTAssertTrue(results.contains{ $0.realPart < 0 && $0.imaginaryPart > 0 })
        XCTAssertTrue(results.contains{ $0.realPart < 0 && $0.imaginaryPart < 0 })
    }

    func testRandomInClosedRange() {
        let range: ClosedRange<A.Base> = -100 ... 100
        var results: Set<A> = []
        
        for _ in 0 ..< 100 {
            let x = A.random(in: range)
            results.insert(x)
            XCTAssertTrue(range.contains(x.realPart))
            XCTAssertTrue(range.contains(x.imaginaryPart))
        }
        XCTAssertTrue(results.isUnique)
        XCTAssertTrue(results.contains{ $0.realPart > 0 && $0.imaginaryPart > 0 })
        XCTAssertTrue(results.contains{ $0.realPart > 0 && $0.imaginaryPart < 0 })
        XCTAssertTrue(results.contains{ $0.realPart < 0 && $0.imaginaryPart > 0 })
        XCTAssertTrue(results.contains{ $0.realPart < 0 && $0.imaginaryPart < 0 })
    }

    
    private func assertApproxEqual(_ x: 𝐑, _ y: 𝐑, error e: 𝐑 = 0.0001) {
        XCTAssertTrue(x.isApproximatelyEqualTo(y, error: e))
    }
    
    private func assertApproxEqual(_ x: 𝐂, _ y: 𝐂, error e: 𝐑 = 0.0001) {
        XCTAssertTrue(x.isApproximatelyEqualTo(y, error: e))
    }
}
