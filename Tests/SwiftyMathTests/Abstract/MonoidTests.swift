//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwiftyMath

class MonoidTests: XCTestCase {
    private struct A: Monoid {
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
    
    private struct B: Submonoid {
        typealias Super = A

        let a: A
        init(_ a: A) {
            self.a = a
        }
        
        var asSuper: A {
            return a
        }
        
        static func contains(_ a: A) -> Bool {
            return true
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
    
    func testPow() {
        let a = A(2)
        XCTAssertEqual(a.pow(0), A.identity)
        XCTAssertEqual(a.pow(1), a)
        XCTAssertEqual(a.pow(2), A(4))
        XCTAssertEqual(a.pow(3), A(6))
    }
    
    func testSubmonoidMul() {
        let a = B(A(3))
        let b = B(A(4))
        XCTAssertEqual(a * b, B(A(7)))
    }
    
    func testSubmonoidIdentity() {
        let a = B(A(3))
        let e = B.identity
        XCTAssertEqual(e * e, e)
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }
    
    func testProductMonoidMul() {
        typealias P = ProductMonoid<A, A>
        let a = P(A(1), A(2))
        let b = P(A(3), A(4))
        XCTAssertEqual(a * b, P(A(4), A(6)))
    }
    
    func testProductMonoidIdentity() {
        typealias P = ProductMonoid<A, A>
        let a = P(A(1), A(2))
        let e = P.identity
        XCTAssertEqual(e * e, e)
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }
    
    func testMonoidHom() {
        typealias F = MonoidHom<A, A>
        let f = F { a in A(a.value * 2) }
        let a = A(3)
        XCTAssertEqual(f.applied(to: a), A(6))
    }
}
