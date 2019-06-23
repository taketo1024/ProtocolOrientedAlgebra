//
//  MatrixDecompositionTest.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/05/09.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

import XCTest
@testable import SwiftyMath

class MatrixImplTests: XCTestCase {
    
    private typealias R = 𝐙
    
    private func M2(_ xs: R...) -> MatrixImpl<R> {
        return MatrixImpl(rows: 2, cols: 2, grid: xs)
    }
    
    private func M2c(_ xs: R...) -> MatrixImpl<R> {
        return MatrixImpl(rows: 2, cols: 2, align: .Cols, grid: xs)
    }
    
    func testEqual() {
        let a = M2(1,2,3,4)
        XCTAssertEqual(a, M2(1,2,3,4))
        XCTAssertNotEqual(a, M2(1,3,2,4))
    }
    
    func testEqual_differentAlign() {
        let a = M2(1,2,3,4)
        let b = M2c(1,2,3,4)
        XCTAssertEqual(a, b)
    }
    
    func testSwitchFromRow() {
        let a = M2(1,2,3,4)
        a.switchAlignment(.Cols)
        XCTAssertEqual(a, M2(1,2,3,4))
    }
    
    func testSwitchFromCol() {
        let a = M2c(1,2,3,4)
        a.switchAlignment(.Rows)
        XCTAssertEqual(a, M2(1,2,3,4))
    }
    
    func testSubscript() {
        let a = M2(1,2,0,4)
        XCTAssertEqual(a[0, 0], 1)
        XCTAssertEqual(a[0, 1], 2)
        XCTAssertEqual(a[1, 0], 0)
        XCTAssertEqual(a[1, 1], 4)
    }
    
    func testSubscript_c() {
        let a = M2c(1,2,0,4)
        XCTAssertEqual(a[0, 0], 1)
        XCTAssertEqual(a[0, 1], 2)
        XCTAssertEqual(a[1, 0], 0)
        XCTAssertEqual(a[1, 1], 4)
    }
    
    func testSubscriptSet() {
        let a = M2(1,2,0,4)
        a[0, 0] = 0
        a[0, 1] = -1
        a[1, 1] = 2
        XCTAssertEqual(a.grid, [0, -1, 0, 2])
    }

    func testSubscriptSet_c() {
        let a = M2c(1,2,0,4)
        a[0, 0] = 0
        a[0, 1] = -1
        a[1, 1] = 2
        XCTAssertEqual(a.grid, [0, -1, 0, 2])
    }

    func testAdd1() {
        let a = M2(1,2,3,4)
        let b = M2(2,3,6,4)
        let c = a + b
        XCTAssertEqual(c, M2(3,5,9,8))
    }
    
    func testAdd2() {
        let a = M2(1,2,3,4)
        let b = M2c(2,3,6,4)
        let c = a + b
        XCTAssertEqual(c, M2(3,5,9,8))
    }
    
    func testAdd3() {
        let a = M2c(1,2,3,4)
        let b = M2(2,3,6,4)
        let c = a + b
        XCTAssertEqual(c, M2(3,5,9,8))
    }
    
    func testAdd4() {
        let a = M2c(1,2,3,4)
        let b = M2c(2,3,6,4)
        let c = a + b
        XCTAssertEqual(c, M2(3,5,9,8))
    }
    
    func testAddRow() {
        let a = M2(1,2,3,4)
        a.addRow(at: 0, to: 1)
        XCTAssertEqual(a, M2(1,2,4,6))
    }
    
    func testAddRowWithMul() {
        let a = M2(1,2,3,4)
        a.addRow(at: 0, to: 1, multipliedBy: 2)
        XCTAssertEqual(a, M2(1,2,5,8))
    }
    
    func testAddCol() {
        let a = M2(1,2,3,4)
        a.addCol(at: 0, to: 1)
        XCTAssertEqual(a, M2(1,3,3,7))
    }
    
    func testAddColWithMul() {
        let a = M2(1,2,3,4)
        a.addCol(at: 0, to: 1, multipliedBy: 2)
        XCTAssertEqual(a, M2(1,4,3,10))
    }
    
    func testMulRow() {
        let a = M2(1,2,3,4)
        a.multiplyRow(at: 0, by: 2)
        XCTAssertEqual(a, M2(2,4,3,4))
    }
    
    func testMulRow_zero() {
        let a = M2(1,2,3,4)
        a.multiplyRow(at: 0, by: 0)
        XCTAssertEqual(a, M2(0,0,3,4))
    }
    
    func testMulCol() {
        let a = M2(1,2,3,4)
        a.multiplyCol(at: 0, by: 2)
        XCTAssertEqual(a, M2(2,2,6,4))
    }
    
    func testMulCol_zero() {
        let a = M2(1,2,3,4)
        a.multiplyCol(at: 0, by: 0)
        XCTAssertEqual(a, M2(0,2,0,4))
    }
    
    func testSwapRows() {
        let a = M2(1,2,3,4)
        a.swapRows(0, 1)
        XCTAssertEqual(a, M2(3,4,1,2))
    }
    
    func testSwapCols() {
        let a = M2(1,2,3,4)
        a.swapCols(0, 1)
        XCTAssertEqual(a, M2(2,1,4,3))
    }
}
