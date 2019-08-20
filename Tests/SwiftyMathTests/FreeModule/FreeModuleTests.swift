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
    typealias M = FreeModule<String, 𝐙>
    
    func testWrap() {
        let z = M.wrap("a")
        XCTAssertEqual(z, M(("a", 1)))
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
        let z = M(("a", 2))
        if let _ = z.unwrap() {
            XCTFail()
        } else {
            // OK
        }
    }
    
    func testEqual() {
        let z = M(("a", 3), ("b", 2))
        let w = M(("b", -1), ("c", 5))
        XCTAssertEqual(z, z)
        XCTAssertNotEqual(z, w)
    }
    
    func testEqual_commutative() {
        let z = M(("a", 3), ("b", 2))
        let w = M(("b", 2), ("a", 3))
        XCTAssertEqual(z, w)
    }
    
    func testZero() {
        let z = M(("a", 3),  ("b", 2))
        let o = M.zero
        XCTAssertEqual(z + o, z)
        XCTAssertEqual(o + z, z)
    }
    
    func testSum() {
        let z = M(("a", 3),  ("b", 2))
        let w = M(("b", -1), ("c", 5))
        XCTAssertEqual(z + w, M(("a", 3), ("b", 1), ("c", 5)))
    }
    
    func testNeg() {
        let z = M(("a", 3),  ("b", 2))
        XCTAssertEqual(-z, M(("a", -3), ("b", -2)))
    }
    
    func testSub() {
        let z = M(("a", 3),  ("b", 2))
        let w = M(("b", -1), ("c", 5))
        XCTAssertEqual(z - w, M(("a", 3), ("b", 3), ("c", -5)))
    }
    
    func testScalMul() {
        let z = M(("a", 3),  ("b", 2))
        XCTAssertEqual(2 * z, M(("a", 6), ("b", 4)))
        XCTAssertEqual(z * 2, M(("a", 6), ("b", 4)))
    }
    
    func testDecomposed() {
        let z1 = M(("a", 3),  ("b", 2))
        let decomp1 = z1.decomposed()
        XCTAssertEqual(decomp1.count, 2)
        XCTAssert(decomp1[0] == ("a", 3))
        XCTAssert(decomp1[1] == ("b", 2))
        
        let z2 = M(("b", 2), ("a", 3))
        let decomp2 = z2.decomposed()
        XCTAssertEqual(decomp2.count, 2)
        XCTAssert(decomp2[0] == ("b", 2))
        XCTAssert(decomp2[1] == ("a", 3))
    }
    
    func testFreeModuleHom() {
        let f = ModuleEnd<M>.linearlyExtend { a in
            switch a {
            case "a": return M(("a", 2),  ("b", 3))
            case "b": return M(("b", -1), ("d", 1))
            default: return .zero
            }
        }
        let z = M(("a", 3), ("b", 2), ("c", 4))
        let w = f.applied(to: z)
        XCTAssertEqual(w, M(("a", 6), ("b", 7), ("d", 2)))
    }
}
