//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwiftyMath

class ModuleTests: XCTestCase {
    private typealias A = AsModule<𝐙>
    
    private struct B: Submodule {
        typealias CoeffRing = 𝐙
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
        
        static func normalizedInQuotient(_ a: A) -> A {
            return A(a.value % 4)
        }
        
        static func inverseInQuotient(_ a: A) -> A? {
            switch a.value % 4 {
            case 0, 2: return nil
            case 1: return A(1)
            case 3: return A(3)
            default: fatalError()
            }
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
        typealias P = ProductModule<A, A>
        let a = P(A(1), A(2))
        let b = P(A(3), A(4))
        XCTAssertEqual(a + b, P(A(4), A(6)))
    }
    
    func testProductModuleZero() {
        typealias P = ProductModule<A, A>
        let a = P(A(1), A(2))
        let z = P.zero
        XCTAssertEqual(z + z, z)
        XCTAssertEqual(a + z, a)
        XCTAssertEqual(z + a, a)
    }
    
    func testProductModuleNegative() {
        typealias P = ProductModule<A, A>
        let a = P(A(3), A(4))
        XCTAssertEqual(-a, P(A(-3), A(-4)))
    }
    
    func testProductModuleScalarMul() {
        typealias P = ProductModule<A, A>
        let a = P(A(1), A(2))
        XCTAssertEqual(3 * a, P(A(3), A(6)))
        XCTAssertEqual(a * 3, P(A(3), A(6)))
    }
    
    func testQuotientModuleSum() {
        typealias Q = QuotientModule<A, B>
        let a = Q(A(1))
        let b = Q(A(2))
        XCTAssertEqual(a + b, Q(A(3)))
    }
    
    func testQuotientModuleZero() {
        typealias Q = QuotientModule<A, B>
        let a = Q(A(1))
        let z = Q.zero
        XCTAssertEqual(z + z, z)
        XCTAssertEqual(a + z, a)
        XCTAssertEqual(z + a, a)
    }
    
    func testQuotientModuleNegative() {
        typealias Q = QuotientModule<A, B>
        let a = Q(A(1))
        XCTAssertEqual(-a, Q(A(3)))
    }
    
    func testQuotientModuleScalarMul() {
        typealias Q = QuotientModule<A, B>
        let a = Q(A(2))
        XCTAssertEqual(a * 3, Q(A(2)))
    }
    
    func testModuleHom() {
        typealias F = ModuleHom<A, A>
        let f = F { a in a * 2 }
        let a = A(3)
        XCTAssertEqual(f.applied(to: a), A(6))
    }
    
    func testMatrixMul() {
        let v = [A(1), A(2), A(3)]
        let X = Matrix<_3, _2, 𝐙>(
             1, 0,
             0, 3,
            -1, 2)
        XCTAssertEqual(v * X, [A(-2), A(12)])
    }
}
