//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwiftyMath

class SetTests: XCTestCase {
    
    private struct A: MathSet {
        let value: Int
        init(_ a: Int) {
            self.value = a
        }
        var description: String {
            return value.description
        }
    }
    
    private struct B: Subset {
        typealias Super = A
        
        let a: A
        init(_ a: A) {
            self.a = a
        }
        
        var asSuper: A {
            return a
        }
        
        static func contains(_ a: A) -> Bool {
            return a.value % 2 == 0
        }
    }
    
    private struct C: FiniteSet {
        static var allElements: [C] {
            return [C()]
        }
        
        static var countElements: Int {
            return 1
        }
        
        var description: String {
            return ""
        }
    }
    
    func testEquality() {
        let a1 = A(1)
        let a2 = A(2)
        XCTAssertTrue(a1 == a1)
        XCTAssertTrue(a1 != a2)
    }
    
    func testSubsetType() {
        let b = B(A(0))
        XCTAssertEqual(b.description, "0")
        XCTAssertTrue(B.contains(A(0)))
        XCTAssertFalse(B.contains(A(1)))
    }
    
    func testFiniteSetType() {
        XCTAssertEqual(C.countElements, 1)
        XCTAssertEqual(C.allElements, [C()])
    }
    
    func testProductSet() {
        typealias P = Pair<A, A>
        let a1 = P(A(1), A(2))
        let a2 = P(A(3), A(4))
        XCTAssertEqual(a1.description, "(1, 2)")
        XCTAssertEqual(a1, a1)
        XCTAssertNotEqual(a1, a2)
    }
}
