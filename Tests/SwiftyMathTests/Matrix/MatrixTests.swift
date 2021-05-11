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
    
    func testInitByInitializer() {
        let a = Matrix2<𝐙> { setEntry in setEntry(0, 1, 2); setEntry(1, 0, 5)}
        XCTAssertEqual(a.serialize(), [0,2,5,0])
    }
    
    func testInitByGrid() {
        let a = Matrix2(grid: [1,2,3,4])
        XCTAssertEqual(a.serialize(), [1,2,3,4])
    }
    
    func testInitByArrayLiteral() {
        let a: Matrix2 = [1,2,3,4]
        XCTAssertEqual(a.serialize(), [1,2,3,4])
    }
    
    func testEquality() {
        let a: Matrix2 = [1,2,3,4]
        let b: Matrix2 = [1,2,3,4]
        let c: Matrix2 = [1,3,2,4]
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }
    
    func testInitWithMissingGrid() {
        let a: Matrix2 = [1,2,3]
        XCTAssertEqual(a.serialize(), [1,2,3,0])
    }

    func testSubscript() {
        let a: Matrix2 = [1,2,0,4]
        XCTAssertEqual(a[0, 0], 1)
        XCTAssertEqual(a[0, 1], 2)
        XCTAssertEqual(a[1, 0], 0)
        XCTAssertEqual(a[1, 1], 4)
    }
    
    func testSubscriptSet() {
        var a: Matrix2 = [1,2,0,4]
        a[0, 0] = 0
        a[0, 1] = 0
        a[1, 1] = 2
        XCTAssertEqual(a[0, 0], 0)
        XCTAssertEqual(a[0, 1], 0)
        XCTAssertEqual(a[1, 0], 0)
        XCTAssertEqual(a[1, 1], 2)
    }
    
    func testCopyOnMutate() {
        let a: Matrix2 = [1,2,0,4]
        var b = a
        
        b[0, 0] = 0
        
        XCTAssertEqual(a[0, 0], 1)
        XCTAssertEqual(b[0, 0], 0)
    }
    
    func testSum() {
        let a: Matrix2 = [1,2,3,4]
        let b: Matrix2 = [2,3,4,5]
        XCTAssertEqual(a + b, [3,5,7,9])
    }
    
    func testZero() {
        let a: Matrix2 = [1,2,3,4]
        let o = Matrix2<R>.zero
        XCTAssertEqual(a + o, a)
        XCTAssertEqual(o + a, a)
    }

    func testNeg() {
        let a: Matrix2 = [1,2,3,4]
        XCTAssertEqual(-a, [-1,-2,-3,-4])
        XCTAssertEqual(a - a, Matrix2.zero)
    }

    func testSub() {
        let a: Matrix2 = [1,2,3,4]
        let b: Matrix2 = [2,1,7,2]
        XCTAssertEqual(a - b, [-1,1,-4,2])
    }
    
    func testMul() {
        let a: Matrix2 = [1,2,3,4]
        let b: Matrix2 = [2,3,4,5]
        XCTAssertEqual(a * b, [10,13,22,29])
    }
    
    func testMul2() {
        let a: Matrix2 = [1,1,-1,1]
        let b: Matrix2 = [1,1,1,-1]
        XCTAssertEqual(a * b, [2, 0, 0, -2])
    }
    
    func testScalarMul() {
        let a: Matrix2 = [1,2,3,4]
        XCTAssertEqual(2 * a, [2,4,6,8])
        XCTAssertEqual(a * 3, [3,6,9,12])
    }
    
    func testMapComps() {
        let a: Matrix2 = [1,2,0,4]
        XCTAssertEqual(a.mapNonZeroComponents{ (_, _, a) in 2 * a }, [2,4,0,8])
    }
    
    func testId() {
        let a: Matrix2 = [1,2,3,4]
        let e = Matrix2<R>.identity
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }
    
    func testInv() {
        let a: Matrix2 = [1,2,2,3]
        XCTAssertEqual(a.inverse!, [-3,2,2,-1])
    }

    func testNonInvertible() {
        let b: Matrix2 = [1,2,3,4]
        XCTAssertFalse(b.isInvertible)
        XCTAssertNil(b.inverse)
    }
    
    func testPow() {
        let a: Matrix2 = [1,2,3,4]
        XCTAssertEqual(a.pow(0), Matrix2.identity)
        XCTAssertEqual(a.pow(1), a)
        XCTAssertEqual(a.pow(2), [7,10,15,22])
        XCTAssertEqual(a.pow(3), [37,54,81,118])
    }
    
    func testTrace() {
        let a: Matrix2 = [1,2,3,4]
        XCTAssertEqual(a.trace, 5)
    }
    
    func testDet() {
        let a: Matrix2 = [1,2,3,4]
        XCTAssertEqual(a.determinant, -2)
    }

    func testDet4() {
        let a: Matrix4 =
            [3,-1,2,4,
             2,1,1,3,
             -2,0,3,-1,
             0,-2,1,3]
        XCTAssertEqual(a.determinant, 66)
    }
    
    func testTransposed() {
        let a: Matrix2 = [1,2,3,4]
        XCTAssertEqual(a.transposed, [1,3,2,4])
    }
    
    func testAsStatic() {
        let a = DMatrix(size: (2, 3), grid: [1,2,3,4,5,6])
        let b = a.as(Matrix<_2, _3, R>.self)
        XCTAssertEqual(b, Matrix<_2, _3, R>(grid: [1,2,3,4,5,6]))
    }
    
    func testAsDynamic() {
        let a = Matrix<_2, _3, R>(grid: [1,2,3,4,5,6])
        let b = a.as(DMatrix<R>.self)
        XCTAssertEqual(b, DMatrix(size: (2, 3), grid: [1,2,3,4,5,6]))
    }
    
    func testSubmatrixRow() {
        let a: Matrix2 = [1,2,3,4]
        let a1 = a.submatrix(rowRange: 0 ..< 1).as(Matrix<_1, _2, R>.self)
        XCTAssertEqual(a1, [1, 2])
    }
    
    func testSubmatrixCol() {
        let a: Matrix2 = [1,2,3,4]
        let a2 = a.submatrix(colRange: 1 ..< 2).as(Matrix<_2, _1, R>.self)
        XCTAssertEqual(a2, [2, 4])
    }
    
    func testSubmatrixBoth() {
        let a: Matrix2 = [1,2,3,4]
        let a3 = a.submatrix(rowRange: 1 ..< 2, colRange: 0 ..< 1).as(Matrix1<R>.self)
        XCTAssertEqual(a3, [3])
    }
    
//    func testConcatHor() {
//        let a: Matrix2 = [1,2,3,4]
//        let b: Matrix2 = [5,6,7,8]
//        let c = a.concatHorizontally(b).as(Matrix<_2, _4, R>.self)
//
//        let r = Matrix<_2, _4, R>(
//            1,2,5,6,
//            3,4,7,8
//        )
//
//        XCTAssertEqual(c, r)
//    }
//
//    func testConcatVer() {
//        let a: Matrix2 = [1,2,3,4]
//        let b: Matrix2 = [5,6,7,8]
//        let c = a.concatVertically(b).as(Matrix<_4, _2, R>.self)
//
//        let r = Matrix<_4, _2, R>(
//            1,2,
//            3,4,
//            5,6,
//            7,8
//        )
//
//        XCTAssertEqual(c, r)
//    }
//
//    func testDirectSum() {
//        let a: Matrix2 = [1,2,3,4]
//        let b: Matrix2 = [5,6,7,8]
//        let c = (a ⊕ b).as(Matrix4<R>.self)
//
//        let r = Matrix4(
//            1,2,0,0,
//            3,4,0,0,
//            0,0,5,6,
//            0,0,7,8
//        )
//
//        XCTAssertEqual(c, r)
//    }
//
//    func testTensorProduct() {
//        let a: Matrix2 = [1,2,0,3]
//        let b: Matrix2 = [1,2,3,4]
//        let c = (a ⊗ b).as(Matrix4<R>.self)
//        
//        let r = Matrix4(
//            1,2,2,4,
//            3,4,6,8,
//            0,0,3,6,
//            0,0,9,12
//        )
//        
//        XCTAssertEqual(c, r)
//    }
    
//    func testCodable() {
//        let a: Matrix2 = [1,2,3,4]
//        let d = try! JSONEncoder().encode(a)
//        let b = try! JSONDecoder().decode(Matrix2<R>.self, from: d)
//        XCTAssertEqual(a, b)
//    }
//
//    func testConcurrent() {
//        let (n, m) = (10, 10)
//        let a = DMatrix<R>(size: (n, m), concurrentIterations: n) { (i, setEntry) in
//            for j in 0 ..< m {
//                setEntry(i, j, i * m + j)
//            }
//        }
//        XCTAssertEqual(a.asArray, (0 ..< n * m).toArray())
//    }
}
