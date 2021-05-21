//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwiftyMath

class RingTests: XCTestCase {
    private typealias A = 𝐙
    
    func testSum() {
        let a = A(3)
        let b = A(4)
        XCTAssertEqual(a + b, A(7))
    }
    
    func testZero() {
        let z = A.zero
        let a = A(3)
        XCTAssertEqual(a + z, a)
        XCTAssertEqual(z + a, a)
    }
    
    func testNegative() {
        let a = A(3)
        XCTAssertEqual(-a, A(-3))
    }
    
    func testMul() {
        let a = A(3)
        let b = A(4)
        XCTAssertEqual(a * b, A(12))
    }
    
    func testIdentity() {
        let e = A.identity
        let a = A(3)
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }
    
    func testInverse() {
        XCTAssertNil(A(2).inverse)
        XCTAssertEqual(A(1).inverse!, A(1))
        XCTAssertEqual(A(-1).inverse!, A(-1))
    }
    
    func testPow() {
        let a = A(2)
        XCTAssertEqual(a.pow(0), A.identity)
        XCTAssertEqual(a.pow(1), a)
        XCTAssertEqual(a.pow(2), A(4))
        XCTAssertEqual(a.pow(3), A(8))
        
        let b = A(-1)
        XCTAssertEqual(b.pow(0), A.identity)
        XCTAssertEqual(b.pow(-1), A(-1))
        XCTAssertEqual(b.pow(-2), A(1))
        XCTAssertEqual(b.pow(-3), A(-1))
    }
    
    func testProductRingSum() {
        typealias P = Pair<A, A>
        let a = P(A(1), A(2))
        let b = P(A(3), A(4))
        XCTAssertEqual(a + b, P(A(4), A(6)))
    }
    
    func testProductRingZero() {
        typealias P = Pair<A, A>
        let a = P(A(1), A(2))
        let z = P.zero
        XCTAssertEqual(z + z, z)
        XCTAssertEqual(a + z, a)
        XCTAssertEqual(z + a, a)
    }
    
    func testProductRingNegative() {
        typealias P = Pair<A, A>
        let a = P(A(3), A(4))
        XCTAssertEqual(-a, P(A(-3), A(-4)))
    }
    
    func testProductRingMul() {
        typealias P = Pair<A, A>
        let a = P(A(1), A(2))
        let b = P(A(3), A(4))
        XCTAssertEqual(a * b, P(A(3), A(8)))
    }
    
    func testProductRingIdentity() {
        typealias P = Pair<A, A>
        let a = P(A(1), A(2))
        let e = P.identity
        XCTAssertEqual(e * e, e)
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }
    
    func testProductRingInverse() {
        typealias P = Pair<A, A>
        let a = P(A(1), A(-1))
        XCTAssertEqual(a.inverse!, P(A(1), A(-1)))
        
        let b = P(A(2), A(1))
        XCTAssertNil(b.inverse)
    }
    
    func testRingHom() {
        typealias F = RingHom<A, A>
        let f = F { a in a * 2 }
        let a = A(3)
        XCTAssertEqual(f(a), A(6))
    }
}
