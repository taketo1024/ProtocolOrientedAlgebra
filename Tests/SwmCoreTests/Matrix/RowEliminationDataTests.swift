//
//  RowEliminationDataTests.swift
//  SwiftySolverTests
//
//  Created by Taketo Sano on 2019/11/05.
//

import XCTest
@testable import SwmCore

class RowEliminationDataTests: XCTestCase {
    private typealias R = 𝐙
    private typealias M2 = Matrix2x2<R>
    private typealias data = MatrixEliminationWorker<R>
    
    func testEqual() {
        let a: M2 = [1,2,3,4]
        let w = data(a)
        XCTAssertEqual(a, w.resultAs(M2.self))
    }
    
    func testAddRow() {
        let a: M2 = [1,2,3,4]
        let w = data(a)
        w.addRow(at: 0, to: 1, multipliedBy: 1)
        XCTAssertEqual(w.resultAs(M2.self), [1,2,4,6])
    }
    
    func testAddRowWithMul() {
        let a: M2 = [1,2,3,4]
        let w = data(a)
        w.addRow(at: 0, to: 1, multipliedBy: 2)
        XCTAssertEqual(w.resultAs(M2.self), [1,2,5,8])
    }
    
    func testMulRow() {
        let a: M2 = [1,2,3,4]
        let w = data(a)
        w.multiplyRow(at: 0, by: 2)
        XCTAssertEqual(w.resultAs(M2.self), [2,4,3,4])
    }
    
    func testSwapRows() {
        let a: M2 = [1,2,3,4]
        let w = data(a)
        w.swapRows(0, 1)
        XCTAssertEqual(w.resultAs(M2.self), [3,4,1,2])
    }
}
