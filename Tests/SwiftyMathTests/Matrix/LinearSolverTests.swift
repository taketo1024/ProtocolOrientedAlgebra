//
//  LinearSolverTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2019/10/29.
//

import XCTest
import SwiftyMath

class LinearSolverTests: XCTestCase {
    func testHasSolution() {
        typealias R = 𝐙₂
        
        let size = (5, 4)
        let grid: [R] = [
            1, 0, 1, 0,
            0, 1, 1, 1,
            0, 0, 0, 0,
            1, 1, 0, 1,
            1, 0, 1, 0
        ]
        
        let A = DMatrix<R>(size: size, grid: grid)
        let b = DVector<R>(size: (size.0, 1), grid: [1, 1, 0, 0, 1])
        
        XCTAssertTrue(LinearSolver.hasSolution(A, b))
    }

    func testHasSolution_trivial() {
        typealias R = 𝐙₂
        let size = (5, 4)
        let grid: [R] = [
            1, 0, 1, 0,
            0, 1, 1, 1,
            0, 0, 0, 0,
            1, 1, 0, 1,
            1, 0, 1, 0
        ]
        
        let A = DMatrix<R>(size: size, grid: grid)
        let b = DVector<R>(size: (size.0, 1), grid: [0, 0, 0, 0, 0])
        
        XCTAssertTrue(LinearSolver.hasSolution(A, b))
    }
    
    func testHasSolution_noSolution() {
        typealias R = 𝐙₂
        let size = (5, 4)
        let grid: [R] = [
            1, 0, 1, 0,
            0, 1, 1, 1,
            0, 0, 0, 0,
            1, 1, 0, 1,
            1, 0, 1, 0
        ]
        
        let A = DMatrix<R>(size: size, grid: grid)
        let b = DVector<R>(size: (size.0, 1), grid: [1, 1, 0, 0, 0])
        
        XCTAssertFalse(LinearSolver.hasSolution(A, b))
    }
}
