//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwmCore

class AdditiveGroupTests: XCTestCase {
    private struct A: AdditiveGroup {
        let value: Int
        init(_ a: Int) {
            self.value = a
        }
        var description: String {
            return value.description
        }
        
        static func + (a: A, b: A) -> A {
            return A(a.value + b.value)
        }
        
        static var zero: A {
            return A(0)
        }
        
        static prefix func - (x: A) -> A {
            return A(-x.value)
        }
    }
    
    private struct B: AdditiveSubgroup {
        typealias Super = A
        
        private let a: A
        init(_ a: A) {
            self.a = a
        }
        
        var asSuper: A {
            return a
        }
        
        static func contains(_ a: AdditiveGroupTests.A) -> Bool {
            return a.value % 3 == 0
        }
        
    }
    
    func testSum() {
        let a = A(3)
        let b = A(4)
        XCTAssertEqual(a + b, A(7))
    }
    
    func testZero() {
        let e = A.zero
        let a = A(3)
        XCTAssertEqual(a + e, a)
        XCTAssertEqual(e + a, a)
    }
    
    func testNegative() {
        let a = A(3)
        XCTAssertEqual(-a, A(-3))
    }
    
    func testSubgroupSum() {
        let a = B(A(3))
        let b = B(A(4))
        XCTAssertEqual(a + b, B(A(7)))
    }
    
    func testSubgroupZero() {
        let a = B(A(3))
        let e = B.zero
        XCTAssertEqual(e + e, e)
        XCTAssertEqual(a + e, a)
        XCTAssertEqual(e + a, a)
    }
    
    func testSubgroupNegative() {
        let a = B(A(3))
        XCTAssertEqual(-a, B(A(-3)))
    }
    
    func testPairSum() {
        typealias P = Pair<A, A>
        let a = P(A(1), A(2))
        let b = P(A(3), A(4))
        XCTAssertEqual(a + b, P(A(4), A(6)))
    }
    
    func testPairZero() {
        typealias P = Pair<A, A>
        let a = P(A(1), A(2))
        let e = P.zero
        XCTAssertEqual(e + e, e)
        XCTAssertEqual(a + e, a)
        XCTAssertEqual(e + a, a)
    }
    
    func testPairNegative() {
        typealias P = Pair<A, A>
        let a = P(A(3), A(4))
        XCTAssertEqual(-a, P(A(-3), A(-4)))
    }
    
    private struct Q: AdditiveQuotientGroup {
        typealias Base = A
        typealias Mod = B
        let representative: AdditiveGroupTests.A
        init(_ a: AdditiveGroupTests.A) {
            self.representative = a
        }
    }
    
    func testAdditiveQuotientGroupSum() {
        let a = Q(A(1))
        let b = Q(A(2))
        XCTAssertEqual(a + b, Q(A(0)))
    }
    
    func testAdditiveQuotientGroupZero() {
        let a = Q(A(1))
        let e = Q.zero
        XCTAssertEqual(e + e, e)
        XCTAssertEqual(a + e, a)
        XCTAssertEqual(e + a, a)
    }
    
    func testAdditiveQuotientGroupNegative() {
        let a = Q(A(1))
        XCTAssertEqual(-a, Q(A(2)))
    }
    
    func testAdditiveGroupHom() {
        typealias F = AdditiveGroupHom<A, A>
        let f = F { a in A(a.value * 2) }
        let a = A(3)
        XCTAssertEqual(f(a), A(6))
        XCTAssertEqual((f + f)(a), A(12))
    }
}
