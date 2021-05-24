//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwmCore

class ModuleTests: XCTestCase {
    private typealias A = AsModule<𝐙>
    
    private struct B: Submodule {
        typealias BaseRing = 𝐙
        typealias Super = A
        
        let a: A
        init(_ a: A) {
            self.a = a
        }
        
        var asSuper: A {
            return a
        }
        
        static func contains(_ a: A) -> Bool {
            return a.value % 4 == 0
        }
    }
    
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
    
    func testScalarMul() {
        let a = A(3)
        XCTAssertEqual(4 * a, A(12))
        XCTAssertEqual(a * 4, A(12))
    }
    
    func testSubmoduleSum() {
        let a = B(A(3))
        let b = B(A(4))
        XCTAssertEqual(a + b, B(A(7)))
    }
    
    func testSubmoduleZero() {
        let a = B(A(3))
        let e = B.zero
        XCTAssertEqual(e + e, e)
        XCTAssertEqual(a + e, a)
        XCTAssertEqual(e + a, a)
    }
    
    func testSubmoduleNegative() {
        let a = B(A(3))
        XCTAssertEqual(-a, B(A(-3)))
    }
    
    func testProductModuleSum() {
        typealias P = Pair<A, A>
        let a = P(A(1), A(2))
        let b = P(A(3), A(4))
        XCTAssertEqual(a + b, P(A(4), A(6)))
    }
    
    func testProductModuleZero() {
        typealias P = Pair<A, A>
        let a = P(A(1), A(2))
        let z = P.zero
        XCTAssertEqual(z + z, z)
        XCTAssertEqual(a + z, a)
        XCTAssertEqual(z + a, a)
    }
    
    func testProductModuleNegative() {
        typealias P = Pair<A, A>
        let a = P(A(3), A(4))
        XCTAssertEqual(-a, P(A(-3), A(-4)))
    }
    
    func testProductModuleScalarMul() {
        typealias P = Pair<A, A>
        let a = P(A(1), A(2))
        XCTAssertEqual(3 * a, P(A(3), A(6)))
        XCTAssertEqual(a * 3, P(A(3), A(6)))
    }
    
    func testModuleHom() {
        typealias F = ModuleHom<A, A>
        let f = F { a in a * 2 }
        let a = A(3)
        XCTAssertEqual(f(a), A(6))
        XCTAssertEqual((f + f)(a), A(12))
        XCTAssertEqual((2 * f)(a), A(12))
        XCTAssertEqual((f * 3)(a), A(18))
    }
}
