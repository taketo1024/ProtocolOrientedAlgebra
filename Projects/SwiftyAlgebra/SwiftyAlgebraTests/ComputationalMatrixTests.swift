//
//  MatrixDecompositionTest.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/05/09.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

import XCTest
@testable import SwiftyAlgebra

class MatrixTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    public func testSwitchFromRow() {
        let a = M(1,2,3,4)
        a.switchAlignment(.Cols)
        XCTAssertEqual(a, M(1,2,3,4))
    }

    public func testSwitchFromCol() {
        let a = M(align: .Cols, 1,2,3,4)
        a.switchAlignment(.Rows)
        XCTAssertEqual(a, M(1,2,3,4))
    }

    public func testMul() {
        let a = M(1, 2, 3, 4)
        let b = M(2, 1, 1, 2)
        XCTAssertEqual(a * b, M(4, 5, 10, 11))
    }

    public func testAddRow() {
        let a = M(1,2,3,4)
        a.addRow(at: 0, to: 1)
        XCTAssertEqual(a, M(1,2,4,6))
    }

    public func testAddRowWithMul() {
        let a = M(1,2,3,4)
        a.addRow(at: 0, to: 1, multipliedBy: 2)
        XCTAssertEqual(a, M(1,2,5,8))
    }

    public func testAddCol() {
        let a = M(1,2,3,4)
        a.addCol(at: 0, to: 1)
        XCTAssertEqual(a, M(1,3,3,7))
    }

    public func testAddColWithMul() {
        let a = M(1,2,3,4)
        a.addCol(at: 0, to: 1, multipliedBy: 2)
        XCTAssertEqual(a, M(1,4,3,10))
    }

    public func testMulRow() {
        let a = M(1,2,3,4)
        a.multiplyRow(at: 0, by: 2)
        XCTAssertEqual(a, M(2,4,3,4))
    }

    public func testMulCol() {
        let a = M(1,2,3,4)
        a.multiplyCol(at: 0, by: 2)
        XCTAssertEqual(a, M(2,2,6,4))
    }

    public func testSwapRows() {
        let a = M(1,2,3,4)
        a.swapRows(0, 1)
        XCTAssertEqual(a, M(3,4,1,2))
    }

    public func testSwapCols() {
        let a = M(1,2,3,4)
        a.swapCols(0, 1)
        XCTAssertEqual(a, M(2,1,4,3))
    }

    private func M<R: Ring>(align: ComputationalMatrixAlignment = .Rows, _ xs: R...) -> ComputationalMatrix<R> {
        return ComputationalMatrix(rows: 2, cols: 2, grid: xs)
    }
}
