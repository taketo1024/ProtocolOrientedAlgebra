//
//  FreeModuleTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2019/08/20.
//

import XCTest
import SwiftyMath

extension String: FreeModuleGenerator {}

class FreeModuleTests: XCTestCase {
    typealias M = LinearCombination<String, 𝐙>
    
    func testWrap() {
        let z = M.wrap("a")
        XCTAssertEqual(z, M(elements: ("a", 1)))
    }
    
    func testUnwrap() {
        let z = M.wrap("a")
        if let a = z.unwrap() {
            XCTAssertEqual(a, "a")
        } else {
            XCTFail()
        }
    }
    
    func testUnwrap_invalid() {
        let z = M(elements: ("a", 2))
        if let _ = z.unwrap() {
            XCTFail()
        } else {
            // OK
        }
    }
    
    func testEqual() {
        let z = M(elements: ("a", 3), ("b", 2))
        let w = M(elements: ("b", -1), ("c", 5))
        XCTAssertEqual(z, z)
        XCTAssertNotEqual(z, w)
    }
    
    func testEqual_commutative() {
        let z = M(elements: ("a", 3), ("b", 2))
        let w = M(elements: ("b", 2), ("a", 3))
        XCTAssertEqual(z, w)
    }
    
    func testZero() {
        let z = M(elements: ("a", 3),  ("b", 2))
        let o = M.zero
        XCTAssertEqual(z + o, z)
        XCTAssertEqual(o + z, z)
    }
    
    func testSum() {
        let z = M(elements: ("a", 3),  ("b", 2))
        let w = M(elements: ("b", -1), ("c", 5))
        XCTAssertEqual(z + w, M(elements: ("a", 3), ("b", 1), ("c", 5)))
    }
    
    func testNeg() {
        let z = M(elements: ("a", 3),  ("b", 2))
        XCTAssertEqual(-z, M(elements: ("a", -3), ("b", -2)))
    }
    
    func testSub() {
        let z = M(elements: ("a", 3),  ("b", 2))
        let w = M(elements: ("b", -1), ("c", 5))
        XCTAssertEqual(z - w, M(elements: ("a", 3), ("b", 3), ("c", -5)))
    }
    
    func testScalMul() {
        let z = M(elements: ("a", 3),  ("b", 2))
        XCTAssertEqual(2 * z, M(elements: ("a", 6), ("b", 4)))
        XCTAssertEqual(z * 2, M(elements: ("a", 6), ("b", 4)))
    }
    
    func testFreeModuleHom() {
        let f = ModuleEnd<M>.linearlyExtend { a in
            switch a {
            case "a": return M(elements: ("a", 2),  ("b", 3))
            case "b": return M(elements: ("b", -1), ("d", 1))
            default: return .zero
            }
        }
        let z = M(elements: ("a", 3), ("b", 2), ("c", 4))
        let w = f(z)
        XCTAssertEqual(w, M(elements: ("a", 6), ("b", 7), ("d", 2)))
    }
}
