//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwiftyMath

class GroupTests: XCTestCase {
    private struct A: Group {
        let value: Int
        init(_ a: Int) {
            self.value = a
        }
        var description: String {
            return value.description
        }
        
        static func * (a: A, b: A) -> A {
            return A(a.value + b.value)
        }
        
        static var identity: A {
            return A(0)
        }
        
        var inverse: A? {
            return A(-value)
        }
    }
    
    private struct B: NormalSubgroup {
        typealias Super = A
        
        private let a: A
        init(_ a: A) {
            self.a = a
        }
        
        var asSuper: A {
            return a
        }
        
        static func contains(_ a: GroupTests.A) -> Bool {
            return a.value % 3 == 0
        }
        
    }
    
    func testMul() {
        let a = A(3)
        let b = A(4)
        XCTAssertEqual(a * b, A(7))
    }
    
    func testIdentity() {
        let e = A.identity
        let a = A(3)
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }
    
    func testInverse() {
        let a = A(3)
        XCTAssertEqual(a.inverse, .some(A(-3)))
    }
    
    func testPow() {
        let a = A(2)
        XCTAssertEqual(a.pow(0), A.identity)
        XCTAssertEqual(a.pow(1), a)
        XCTAssertEqual(a.pow(2), A(4))
        XCTAssertEqual(a.pow(3), A(6))
        XCTAssertEqual(a.pow(-1), a.inverse)
        XCTAssertEqual(a.pow(-2), A(-4))
        XCTAssertEqual(a.pow(-3), A(-6))
    }
    
    func testSubgroupMul() {
        let a = B(A(3))
        let b = B(A(4))
        XCTAssertEqual(a * b, B(A(7)))
    }
    
    func testSubgroupIdentity() {
        let a = B(A(3))
        let e = B.identity
        XCTAssertEqual(e * e, e)
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }
    
    func testSubgroupInverse() {
        let a = B(A(3))
        guard let aInv = a.inverse else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(aInv, B(A(-3)))
        XCTAssertEqual(a * aInv, B.identity)
        XCTAssertEqual(aInv * a, B.identity)
    }
    
    func testProductGroupMul() {
        typealias P = ProductGroup<A, A>
        let a = P(A(1), A(2))
        let b = P(A(3), A(4))
        XCTAssertEqual(a * b, P(A(4), A(6)))
    }
    
    func testProductGroupIdentity() {
        typealias P = ProductGroup<A, A>
        let a = P(A(1), A(2))
        let e = P.identity
        XCTAssertEqual(e * e, e)
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }
    
    func testProductGroupInverse() {
        typealias P = ProductGroup<A, A>
        let a = P(A(3), A(4))
        XCTAssertEqual(a.inverse, P(A(-3), A(-4)))
    }
    
    func testQuotientGroupMul() {
        typealias Q = QuotientGroup<A, B>
        let a = Q(A(1))
        let b = Q(A(2))
        XCTAssertEqual(a * b, Q(A(0)))
    }
    
    func testQuotientGroupIdentity() {
        typealias Q = QuotientGroup<A, B>
        let a = Q(A(1))
        let e = Q.identity
        XCTAssertEqual(e * e, e)
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }
    
    func testQuotientGroupInverse() {
        typealias Q = QuotientGroup<A, B>
        let a = Q(A(1))
        XCTAssertEqual(a.inverse, Q(A(2)))
    }
    
    func testGroupHom() {
        typealias F = GroupHom<A, A>
        let f = F { a in A(a.value * 2) }
        let a = A(3)
        XCTAssertEqual(f.applied(to: a), A(6))
    }
}
