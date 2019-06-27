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
    
    func testInit() {
        let a = Matrix2(1,2,3,4)
        XCTAssertEqual(a.grid, [1,2,3,4])
    }
    
    func testEquality() {
        let a = Matrix2(1,2,3,4)
        let b = Matrix2(1,2,3,4)
        let c = Matrix2(1,3,2,4)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }
    
    func testInitByGenerator() {
        let a = Matrix2 { (i, j) in i * 10 + j}
        XCTAssertEqual(a, Matrix2(0,1,10,11))
    }
    
    func testInitByData() {
        let a = Matrix2(size: (2, 2), data: [MatrixCoord(0,0) : 3, MatrixCoord(0,1) : 2, MatrixCoord(1,1) : 5])
        XCTAssertEqual(a, Matrix2(3,2,0,5))
    }
    
    func testInitWithMissingGrid() {
        let a = Matrix2(1,2,3)
        XCTAssertEqual(a, Matrix2(1,2,3,0))
    }

    func testSubscript() {
        let a = Matrix2(1,2,0,4)
        XCTAssertEqual(a[0, 0], 1)
        XCTAssertEqual(a[0, 1], 2)
        XCTAssertEqual(a[1, 0], 0)
        XCTAssertEqual(a[1, 1], 4)
    }
    
    func testSubscriptSet() {
        var a = Matrix2(1,2,0,4)
        a[0, 0] = 0
        a[0, 1] = 0
        a[1, 1] = 2
        XCTAssertEqual(a[0, 0], 0)
        XCTAssertEqual(a[0, 1], 0)
        XCTAssertEqual(a[1, 0], 0)
        XCTAssertEqual(a[1, 1], 2)
    }
    
    func testSubscriptSet_zeroExcluded() {
        var a = Matrix2(1,2,3,4)
        XCTAssertEqual(a.data.count, 4)
        
        a[0, 0] = 0
        XCTAssertEqual(a.data.count, 3)
        
        a[0, 0] = 1
        XCTAssertEqual(a.data.count, 4)
    }
    
    func testCopyOnMutate() {
        let a = Matrix2(1,2,0,4)
        var b = a
        
        b[0, 0] = 0
        
        XCTAssertEqual(a[0, 0], 1)
        XCTAssertEqual(b[0, 0], 0)
    }
    
    func testSum() {
        let a = Matrix2(1,2,3,4)
        let b = Matrix2(2,3,4,5)
        XCTAssertEqual(a + b, Matrix2(3,5,7,9))
    }
    
    func testSum_zeroExcluded() {
        let a = Matrix2(1,2,3,4)
        let b = Matrix2(-1,3,-3,5)
        XCTAssertEqual((a + b).data.count, 2)
    }
    
    func testZero() {
        let a = Matrix2(1,2,3,4)
        let o = Matrix2<R>.zero
        XCTAssertEqual(a + o, a)
        XCTAssertEqual(o + a, a)
    }

    func testNeg() {
        let a = Matrix2(1,2,3,4)
        XCTAssertEqual(-a, Matrix2(-1,-2,-3,-4))
    }

    func testSub() {
        let a = Matrix2(1,2,3,4)
        let b = Matrix2(2,1,7,2)
        XCTAssertEqual(a - b, Matrix2(-1,1,-4,2))
    }
    
    func testMul() {
        let a = Matrix2(1,2,3,4)
        let b = Matrix2(2,3,4,5)
        XCTAssertEqual(a * b, Matrix2(10,13,22,29))
    }
    
    func testScalarMul() {
        let a = Matrix2(1,2,3,4)
        XCTAssertEqual(2 * a, Matrix2(2,4,6,8))
        XCTAssertEqual(a * 3, Matrix2(3,6,9,12))
    }
    
    func testScalarMul_zeroExcluded() {
        let a = Matrix2(1,2,3,4)
        XCTAssertEqual((0 * a).data.count, 0)
    }
    
    func testMapComps() {
        let a = Matrix2(1,2,0,4)
        XCTAssertEqual(a.mapComponents{ $0 * 2 }, Matrix2(2,4,0,8))
    }
    
    func testMapComps_zeroExcluded() {
        let a = Matrix2(1,2,0,4)
        XCTAssertEqual(a.mapComponents{ $0 * 0 }.data.count, 0)
    }
    
    func testId() {
        let a = Matrix2(1,2,3,4)
        let e = Matrix2<R>.identity
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }
    
    func testInv() {
        let a = Matrix2(1,2,2,3)
        XCTAssertEqual(a.inverse!, Matrix2(-3,2,2,-1))
    }
    
    func testNonInvertible() {
        let b = Matrix2(1,2,3,4)
        XCTAssertFalse(b.isInvertible)
        XCTAssertNil(b.inverse)
    }
    
    func testPow() {
        let a = Matrix2(1,2,3,4)
        XCTAssertEqual(a.pow(0), Matrix2.identity)
        XCTAssertEqual(a.pow(1), a)
        XCTAssertEqual(a.pow(2), Matrix2(7,10,15,22))
        XCTAssertEqual(a.pow(3), Matrix2(37,54,81,118))
    }
    
    func testTrace() {
        let a = Matrix2(1,2,3,4)
        XCTAssertEqual(a.trace, 5)
    }
    
    func testDet() {
        let a = Matrix2(1,2,3,4)
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
        let a = Matrix2(1,2,3,4)
        XCTAssertEqual(a.transposed, Matrix2(1,3,2,4))
    }
    
    func testSubmatrixRow() {
        let a = Matrix2(1,2,3,4)
        let a1 = a.submatrix(rowRange: 0 ..< 1).as(Matrix<_1, _2, R>.self)
        XCTAssertEqual(a1, Matrix<_1, _2, 𝐙>(1, 2))
    }
    
    func testSubmatrixCol() {
        let a = Matrix2(1,2,3,4)
        let a2 = a.submatrix(colRange: 1 ..< 2).as(Matrix<_2, _1, R>.self)
        XCTAssertEqual(a2, Matrix<_2, _1, 𝐙>(2, 4))
    }
    
    func testSubmatrixBoth() {
        let a = Matrix2(1,2,3,4)
        let a3 = a.submatrix(rowRange: 1 ..< 2, colRange: 0 ..< 1).as(Matrix1<R>.self)
        XCTAssertEqual(a3, Matrix1(3))
    }
    
    func testConcatHor() {
        var a = Matrix2(1,2,3,4).asDynamicMatrix
        let b = Matrix2(5,6,7,8)
        a.concatHorizontally(b)
        
        let r = Matrix<_2, _4, R>(
            1,2,5,6,
            3,4,7,8
        ).asDynamicMatrix
        
        XCTAssertEqual(a, r)
    }
    
    func testConcatVer() {
        var a = Matrix2(1,2,3,4).asDynamicMatrix
        let b = Matrix2(5,6,7,8)
        a.concatVertically(b)
        
        let r = Matrix<_4, _2, R>(
            1,2,
            3,4,
            5,6,
            7,8
        ).asDynamicMatrix
        
        XCTAssertEqual(a, r)
    }
    
    func testConcatDiag() {
        var a = Matrix2(1,2,3,4).asDynamicMatrix
        let b = Matrix2(5,6,7,8)
        a.concatDiagonally(b)
        
        let r = Matrix4(
            1,2,0,0,
            3,4,0,0,
            0,0,5,6,
            0,0,7,8
        ).asDynamicMatrix
        
        XCTAssertEqual(a, r)
    }
    
    func testTensorProduct() {
        let a = Matrix2(1,2,0,3)
        let b = Matrix2(1,2,3,4)
        let x = (a ⊗ b).as(Matrix4<R>.self)
        XCTAssertEqual(x, Matrix4(
            1,2,2,4,
            3,4,6,8,
            0,0,3,6,
            0,0,9,12
        ))
    }
    
    func testAsDynamic() {
        let a = Matrix<_2, _3, R>(1,2,3,4,5,6)
        let b = a.as(DMatrix<R>.self)
        XCTAssertEqual(b, DMatrix(size: (2, 3), grid: [1,2,3,4,5,6]))
    }
    
    func testAsStatic() {
        let a = DMatrix(size: (2, 3), grid: [1,2,3,4,5,6])
        let b = a.as(Matrix<_2, _3, R>.self)
        XCTAssertEqual(b, Matrix<_2, _3, R>(1,2,3,4,5,6))
    }
    
    func testCodable() {
        let a = Matrix2(1,2,3,4)
        let d = try! JSONEncoder().encode(a)
        let b = try! JSONDecoder().decode(Matrix2<R>.self, from: d)
        XCTAssertEqual(a, b)
    }
}
