//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwiftyMath

class MatrixTests: XCTestCase {
    
    typealias R = 𝐙
    typealias C = MatrixComponent<R>
    typealias M = Matrix2<R>
    
    func testEquality() {
        let a = M(1,2,3,4)
        let b = M(1,2,3,4)
        let c = M(1,3,2,4)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }
    
    func testInitByGenerator() {
        let a = M { (i, j) in i * 10 + j}
        XCTAssertEqual(a, M(0,1,10,11))
    }
    
    func testInitByComponents() {
        let a = M(components: [C(0,0,3), C(0,1,2), C(1,1,5)])
        XCTAssertEqual(a, M(3,2,0,5))
    }
    
    func testInitWithMissingGrid() {
        let a = M(1,2,3)
        XCTAssertEqual(a, M(1,2,3,0))
    }

    func testSubscript() {
        let a = M(1,2,0,4)
        XCTAssertEqual(a[0, 0], 1)
        XCTAssertEqual(a[0, 1], 2)
        XCTAssertEqual(a[1, 0], 0)
        XCTAssertEqual(a[1, 1], 4)
    }
    
    func testSubscriptSet() {
        var a = M(1,2,0,4)
        a[0, 0] = 0
        a[0, 1] = 0
        a[1, 1] = 2
        XCTAssertEqual(a[0, 0], 0)
        XCTAssertEqual(a[0, 1], 0)
        XCTAssertEqual(a[1, 0], 0)
        XCTAssertEqual(a[1, 1], 2)
    }
    
    func testCopyOnMutate() {
        let a = M(1,2,0,4)
        var b = a
        
        b[0, 0] = 0
        
        XCTAssertEqual(a[0, 0], 1)
        XCTAssertEqual(b[0, 0], 0)
    }
    
    func testSum() {
        let a = M(1,2,3,4)
        let b = M(2,3,4,5)
        XCTAssertEqual(a + b, M(3,5,7,9))
    }
    
    func testZero() {
        let a = M(1,2,3,4)
        let o = M.zero
        XCTAssertEqual(a + o, a)
        XCTAssertEqual(o + a, a)
    }

    func testNeg() {
        let a = M(1,2,3,4)
        XCTAssertEqual(-a, M(-1,-2,-3,-4))
    }

    func testMul() {
        let a = M(1,2,3,4)
        let b = M(2,3,4,5)
        XCTAssertEqual(a * b, M(10,13,22,29))
    }
    
    func testScalarMul() {
        let a = M(1,2,3,4)
        XCTAssertEqual(2 * a, M(2,4,6,8))
        XCTAssertEqual(a * 3, M(3,6,9,12))
    }
    
    func testId() {
        let a = M(1,2,3,4)
        let e = M.identity
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }
    
    func testInv() {
        let a = M(1,2,2,3)
        XCTAssertEqual(a.inverse!, M(-3,2,2,-1))
        
        let b = M(1,2,3,4)
        XCTAssertNil(b.inverse)
    }
    
    func testPow() {
        let a = M(1,2,3,4)
        XCTAssertEqual(a.pow(0), M.identity)
        XCTAssertEqual(a.pow(1), a)
        XCTAssertEqual(a.pow(2), M(7,10,15,22))
        XCTAssertEqual(a.pow(3), M(37,54,81,118))
    }
    
    func testTrace() {
        let a = M(1,2,3,4)
        XCTAssertEqual(a.trace, 5)
    }
    
    func testDet() {
        let a = M(1,2,3,4)
        XCTAssertEqual(a.determinant, -2)
    }
    
    func testDet4() {
        let a = Matrix4(3,-1,2,4,
                        2,1,1,3,
                        -2,0,3,-1,
                        0,-2,1,3)
        XCTAssertEqual(a.determinant, 66)
    }
    
    func testTransposed() {
        let a = M(1,2,3,4)
        XCTAssertEqual(a.transposed, M(1,3,2,4))
    }
    
    func testAsDynamic() {
        let a = Matrix<_2, _3, R>(1,2,3,4,5,6)
        let b = a.asDynamic
        XCTAssertEqual(b, DMatrix(rows: 2, cols: 3, grid: [1,2,3,4,5,6]))
        
        let c = b.as(Matrix<_2, _3, R>.self)
        XCTAssertEqual(a, c)
    }
    
    func testCodable() {
        let a = M(1,2,3,4)
        let d = try! JSONEncoder().encode(a)
        let b = try! JSONDecoder().decode(M.self, from: d)
        XCTAssertEqual(a, b)
    }
}
