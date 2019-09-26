//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwiftyMath

class QuaternionTests: XCTestCase {
    
    typealias A = 𝐇
    
    func testFromInt() {
        let a = A(from: 5)
        assertApproxEqual(a, A(5, 0, 0, 0))
    }
    
    func testFromReal() {
        let a = A(𝐑(3.14))
        assertApproxEqual(a, A(3.14, 0, 0, 0))
    }
    
    func testSum() {
        let a = A(1, 2, 3, 4)
        let b = A(3, 4, 5, 6)
        assertApproxEqual(a + b, A(4, 6, 8, 10))
    }
    
    func testZero() {
        let a = A(3, 4, 5, 6)
        let o = A.zero
        assertApproxEqual(o + o, o)
        assertApproxEqual(a + o, a)
        assertApproxEqual(o + a, a)
    }
    
    func testNeg() {
        let a = A(3, 4, -1, 2)
        assertApproxEqual(-a, A(-3, -4, 1, -2))
    }
    
    func testConj() {
        let a = A(3, 4, -1, 2)
        assertApproxEqual(a.conjugate, A(3, -4, 1, -2))
    }
    
    // (-1 + 3i + 4j + 3k) × (2 + 3i -1j + 4k)

    func testMulByIntLiteral() {
        let a = A(-1, 3, 4, 3)
        assertApproxEqual(A(3) * a, A(-3, 9, 12, 9))
    }
    
    func testMul() {
        let a = A(-1, 3, 4, 3)
        let b = A(2, 3, -1, 4)
        assertApproxEqual(a * b, A(-19, 22, 6, -13))
    }
    
    func testId() {
        let a = A(2, 1, 4, 3)
        let e = A.identity
        assertApproxEqual(e * e, e)
        assertApproxEqual(a * e, a)
        assertApproxEqual(e * a, a)
    }
    
    func testInv() {
        let a = A(1, -1, 1, 1)
        assertApproxEqual(a.inverse!, A(0.25, 0.25, -0.25, -0.25))
        
        let o = A.zero
        XCTAssertNil(o.inverse)
    }
    
    func testPow() {
        let a = A(1, 2, 3, 4)
        assertApproxEqual(a.pow(0), A.identity)
        assertApproxEqual(a.pow(1), A(1, 2, 3, 4))
        assertApproxEqual(a.pow(2), A(-28, 4, 6, 8))
        assertApproxEqual(a.pow(3), A(-86, -52, -78, -104))
    }
    
    func testAbs() {
        let a = A(1, 2, 3, 4)
        assertApproxEqual(a.abs, √30)
    }
    
    private func assertApproxEqual(_ x: 𝐑, _ y: 𝐑, error e: 𝐑 = 0.0001) {
        XCTAssertTrue(x.isApproximatelyEqualTo(y, error: e))
    }
    
    private func assertApproxEqual(_ x: 𝐇, _ y: 𝐇, error e: 𝐑 = 0.0001) {
        XCTAssertTrue(x.isApproximatelyEqualTo(y, error: e))
    }
}
