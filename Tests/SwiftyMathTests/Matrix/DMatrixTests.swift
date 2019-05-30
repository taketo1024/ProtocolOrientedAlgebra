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
    
    private func D(_ a: R, _ b: R, _ c: R, _ d: R) -> DMatrix<R> {
        return DMatrix(rows: 2, cols: 2, grid: [a, b, c, d])
    }
    
    func testDirSum() {
        let a = M(1,2,3,4)
        let b = M(5,6,7,8)
        let x = a ⊕ b
        XCTAssertEqual(x.rows, 4)
        XCTAssertEqual(x.cols, 4)
        XCTAssertEqual(x.grid, [1,2,0,0,
                                3,4,0,0,
                                0,0,5,6,
                                0,0,7,8])
    }
    
    func testSubmatrix() {
        let a = M(1,2,3,4)
        
        let a1 = a.submatrix(rowRange: 0 ..< 1)
        XCTAssertEqual(a1.rows, 1)
        XCTAssertEqual(a1.cols, 2)
        XCTAssertEqual(a1.grid, [1, 2])
        
        let a2 = a.submatrix(colRange: 1 ..< 2)
        XCTAssertEqual(a2.rows, 2)
        XCTAssertEqual(a2.cols, 1)
        XCTAssertEqual(a2.grid, [2, 4])
        
        let a3 = a.submatrix(rowRange: 1 ..< 2, colRange: 0 ..< 1)
        XCTAssertEqual(a3.rows, 1)
        XCTAssertEqual(a3.cols, 1)
        XCTAssertEqual(a3.grid, [3])
        
        let a4 = a.submatrix(rowsMatching: { $0 % 2 == 0}, colsMatching: { $0 % 2 != 0})
        XCTAssertEqual(a4.rows, 1)
        XCTAssertEqual(a4.cols, 1)
        XCTAssertEqual(a4.grid, [2])
    }
    
    func testConcat() {
        let a = M(1,2,3,4)
        let b = M(5,6,7,8)

        let x = a.concatRows(with: b)
        XCTAssertEqual(x.rows, 4)
        XCTAssertEqual(x.cols, 2)
        XCTAssertEqual(x.grid, [1,2,3,4,5,6,7,8])
        
        let y = a.concatCols(with: b)
        XCTAssertEqual(y.rows, 2)
        XCTAssertEqual(y.cols, 4)
        XCTAssertEqual(y.grid, [1,2,5,6,3,4,7,8])
    }
}
