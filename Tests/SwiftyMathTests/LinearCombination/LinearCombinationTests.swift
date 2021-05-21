//
//  LinearCombinationTypeTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2019/08/20.
//

import XCTest
import SwiftyMath

private extension String: LinearCombinationGenerator {}

class LinearCombinationTypeTests: XCTestCase {
    typealias M = LinearCombination<String, 𝐙>
    
    func testInitByGenerator() {
        let z = M("a")
        XCTAssertEqual(z, M(elements: ["a": 1]))
    }
    
    func testInitByDictionary() {
        let z: M = ["a": 1, "b": 2]
        XCTAssertEqual(z, M(elements: ["a": 1, "b": 2]))
    }
    
    func testAsGenerator() {
        let z = M("a")
        if let a = z.asGenerator {
            XCTAssertEqual(a, "a")
        } else {
            XCTFail()
        }
    }
    
    func testUnwrap_invalid() {
        let z: M = ["a": 2]
        if let _ = z.asGenerator {
            XCTFail()
        } else {
            // OK
        }
    }
    
    func testEqual() {
        let z: M = ["a": 3, "b": 2]
        let w: M = ["b": -1, "c": 5]
        XCTAssertEqual(z, z)
        XCTAssertNotEqual(z, w)
    }
    
    func testEqual_commutative() {
        let z: M = ["a": 3, "b": 2]
        let w: M = ["b": 2, "a": 3]
        XCTAssertEqual(z, w)
    }
    
    func testZero() {
        let z: M = ["a": 3, "b": 2]
        let o = M.zero
        XCTAssertEqual(z + o, z)
        XCTAssertEqual(o + z, z)
    }
    
    func testSum() {
        let z: M = ["a": 3, "b": 2]
        let w: M = ["b": -1, "c": 5]
        XCTAssertEqual(z + w, ["a": 3, "b": 1, "c": 5])
    }
    
    func testNeg() {
        let z: M = ["a": 3, "b": 2]
        XCTAssertEqual(-z, ["a": -3, "b": -2])
    }
    
    func testSub() {
        let z: M = ["a": 3, "b": 2]
        let w: M = ["b": -1, "c": 5]
        XCTAssertEqual(z - w, ["a": 3, "b": 3, "c": -5])
    }
    
    func testScalMul() {
        let z: M = ["a": 3, "b": 2]
        XCTAssertEqual(2 * z, ["a": 6, "b": 4])
        XCTAssertEqual(z * 2, ["a": 6, "b": 4])
    }
    
    func testLinearCombinationTypeHom() {
        let f = ModuleEnd<M>.linearlyExtend { a in
            switch a {
            case "a": return ["a": 2, "b": 3]
            case "b": return ["b": -1, "d": 1]
            default: return .zero
            }
        }
        let z: M = ["a": 3, "b": 2, "c": 4]
        let w = f(z)
        XCTAssertEqual(w, ["a": 6, "b": 7, "d": 2])
    }
}
