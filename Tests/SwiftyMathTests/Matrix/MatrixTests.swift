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
    typealias M = Matrix2x2<R>
    
    func testInitByInitializer() {
        let a = M { setEntry in setEntry(0, 1, 2); setEntry(1, 0, 5)}
        XCTAssertEqual(a.serialize(), [0,2,5,0])
    }
    
    func testInitByGrid() {
        let a = M(grid: [1,2,3,4])
        XCTAssertEqual(a.serialize(), [1,2,3,4])
    }
    
    func testInitByArrayLiteral() {
        let a: M = [1,2,3,4]
        XCTAssertEqual(a.serialize(), [1,2,3,4])
    }
    
    func testEquality() {
        let a: M = [1,2,3,4]
        let b: M = [1,2,3,4]
        let c: M = [1,3,2,4]
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }
    
    func testInitWithMissingGrid() {
        let a: M = [1,2,3]
        XCTAssertEqual(a.serialize(), [1,2,3,0])
    }

    func testSubscript() {
        let a: M = [1,2,0,4]
        XCTAssertEqual(a[0, 0], 1)
        XCTAssertEqual(a[0, 1], 2)
        XCTAssertEqual(a[1, 0], 0)
        XCTAssertEqual(a[1, 1], 4)
    }
    
    func testSubscriptSet() {
        var a: M = [1,2,0,4]
        a[0, 0] = 0
        a[0, 1] = 0
        a[1, 1] = 2
        XCTAssertEqual(a[0, 0], 0)
        XCTAssertEqual(a[0, 1], 0)
        XCTAssertEqual(a[1, 0], 0)
        XCTAssertEqual(a[1, 1], 2)
    }
    
    func testCopyOnMutate() {
        let a: M = [1,2,0,4]
        var b = a
        
        b[0, 0] = 0
        
        XCTAssertEqual(a[0, 0], 1)
        XCTAssertEqual(b[0, 0], 0)
    }
    
    func testSum() {
        let a: M = [1,2,3,4]
        let b: M = [2,3,4,5]
        XCTAssertEqual(a + b, [3,5,7,9])
    }
    
    func testZero() {
        let a: M = [1,2,3,4]
        let o = M.zero
        XCTAssertEqual(a + o, a)
        XCTAssertEqual(o + a, a)
    }

    func testNeg() {
        let a: M = [1,2,3,4]
        XCTAssertEqual(-a, [-1,-2,-3,-4])
        XCTAssertEqual(a - a, M.zero)
    }

    func testSub() {
        let a: M = [1,0,3,4]
        let b: M = [2,1,7,2]
        XCTAssertEqual(a - b, [-1,-1,-4,2])
    }
    
    func testMul() {
        let a: M = [1,2,3,4]
        let b: M = [2,3,4,5]
        XCTAssertEqual(a * b, [10,13,22,29])
    }
    
    func testMul2() {
        let a: M = [1,1,-1,1]
        let b: M = [1,1,1,-1]
        XCTAssertEqual(a * b, [2, 0, 0, -2])
    }
    
    func testScalarMul() {
        let a: M = [1,2,3,4]
        XCTAssertEqual(2 * a, [2,4,6,8])
        XCTAssertEqual(a * 3, [3,6,9,12])
    }
    
    func testId() {
        let a: M = [1,2,3,4]
        let e = M.identity
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }
    
    func testInv() {
        let a: M = [1,2,2,3]
        XCTAssertEqual(a.inverse!, [-3,2,2,-1])
    }

    func testNonInvertible() {
        let b: M = [1,2,3,4]
        XCTAssertFalse(b.isInvertible)
        XCTAssertNil(b.inverse)
    }
    
    func testPow() {
        let a: M = [1,2,3,4]
        XCTAssertEqual(a.pow(0), M.identity)
        XCTAssertEqual(a.pow(1), a)
        XCTAssertEqual(a.pow(2), [7,10,15,22])
        XCTAssertEqual(a.pow(3), [37,54,81,118])
    }
    
    func testTrace() {
        let a: M = [1,2,3,4]
        XCTAssertEqual(a.trace, 5)
    }
    
    func testDet() {
        let a: M = [1,2,3,4]
        XCTAssertEqual(a.determinant, -2)
    }

    func testDet4() {
        let a: Matrix4x4 =
            [3,-1,2,4,
             2,1,1,3,
             -2,0,3,-1,
             0,-2,1,3]
        XCTAssertEqual(a.determinant, 66)
    }
    
    func testTransposed() {
        let a: M = [1,2,3,4]
        XCTAssertEqual(a.transposed, [1,3,2,4])
    }
    
    func testAsStatic() {
        let a = MatrixDxD(size: (2, 3), grid: [1,2,3,4,5,6])
        let b = a.as(Matrix<R, _2, _3>.self)
        XCTAssertEqual(b, Matrix<R, _2, _3>(grid: [1,2,3,4,5,6]))
    }
    
    func testAsDynamic() {
        let a = Matrix<R, _2, _3>(grid: [1,2,3,4,5,6])
        let b = a.as(MatrixDxD<R>.self)
        XCTAssertEqual(b, MatrixDxD(size: (2, 3), grid: [1,2,3,4,5,6]))
    }
    
    func testSubmatrixRow() {
        let a: M = [1,2,3,4]
        let a1 = a.submatrix(rowRange: 0 ..< 1).as(Matrix<R, _1, _2>.self)
        XCTAssertEqual(a1, [1, 2])
    }
    
    func testSubmatrixCol() {
        let a: M = [1,2,3,4]
        let a2 = a.submatrix(colRange: 1 ..< 2).as(Matrix<R, _2, _1>.self)
        XCTAssertEqual(a2, [2, 4])
    }
    
    func testSubmatrixBoth() {
        let a: M = [1,2,3,4]
        let a3 = a.submatrix(rowRange: 1 ..< 2, colRange: 0 ..< 1).as(Matrix1x1<R>.self)
        XCTAssertEqual(a3, [3])
    }
    
    func testConcat() {
        let a: M = [1,2,3,4]
        let b: M = [5,6,7,8]
        let c = a.concat(b).as(Matrix<R, _2, _4>.self)

        let r: Matrix<R, _2, _4> = [
            1,2,5,6,
            3,4,7,8
        ]

        XCTAssertEqual(c, r)
    }

    func testStack() {
        let a: M = [1,2,3,4]
        let b: M = [5,6,7,8]
        let c = a.stack(b).as(Matrix<R, _4, _2>.self)

        let r: Matrix<R, _4, _2> = [
            1,2,
            3,4,
            5,6,
            7,8
        ]

        XCTAssertEqual(c, r)
    }
    
    func testPermuteRows() {
        let a: M = [1,2,3,4]
        let s = Permutation<_2>.transposition(0, 1)
        let b = a.permuteRows(by: s)

        XCTAssertEqual(b, [3,4,1,2])
    }

    func testPermuteCols() {
        let a: M = [1,2,3,4]
        let s = Permutation<_2>.transposition(0, 1)
        let b = a.permuteCols(by: s)

        XCTAssertEqual(b, [2,1,4,3])
    }

    func testDirectSum() {
        let a: M = [1,2,3,4]
        let b: M = [5,6,7,8]
        let c = (a ⊕ b).as( Matrix4x4<R>.self )

        let r: Matrix4x4 = [
            1,2,0,0,
            3,4,0,0,
            0,0,5,6,
            0,0,7,8
        ]

        XCTAssertEqual(c, r)
    }

    func testTensorProduct() {
        let a: M = [1,2,0,3]
        let b: M = [1,2,3,4]
        let c = (a ⊗ b).as( Matrix4x4<R>.self )
        
        let r: Matrix4x4 = [
            1,2,2,4,
            3,4,6,8,
            0,0,3,6,
            0,0,9,12
        ]
        
        XCTAssertEqual(c, r)
    }
}
