//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwiftyMath

class MapTests: XCTestCase {
    private struct A: MathSet {
        let value: Int
        init(_ a: Int) {
            self.value = a
        }

        var description: String {
            return value.description
        }
    }
    
    private struct B: MathSet {
        let value: Int
        init(_ a: Int) {
            self.value = a
        }
        var description: String {
            return value.description
        }
    }
    
    private struct C: MathSet {
        let value: Int
        init(_ a: Int) {
            self.value = a
        }
        var description: String {
            return value.description
        }
    }
    
    func testApplyTo() {
        typealias F = Map<A, B>
        let f = F { a in B(a.value + 1) }
        let a = A(1)
        XCTAssertEqual(f(a), B(2))
    }

    func testIdentity() {
        typealias F = Map<A, A>
        let id = F.identity
        let a = A(1)
        XCTAssertEqual(id(a), A(1))
    }

    func testComposition() {
        typealias F = Map<A, B>
        typealias G = Map<B, C>
        let f = F { a in B(a.value + 1) }
        let g = G { b in C(b.value * 3) }
        let a = A(1)
        XCTAssertEqual((g ∘ f)(a), C(6))
    }
    
    func testEnd() {
        typealias F = End<A>
        let f = F { a in A(a.value + 1)}
        let g = F { a in A(a.value * 3)}
        let a = A(1)
        XCTAssertEqual((g ∘ f)(a), A(6))
        XCTAssertEqual((f ∘ g)(a), A(4))
    }
}
