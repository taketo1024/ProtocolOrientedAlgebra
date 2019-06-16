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

class MatrixEliminationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
//        MatrixEliminator<𝐙>.debug = true
    }
    
    private func M<R: Ring>(_ rows: Int, _ cols: Int, _ grid: [R]) -> MatrixImpl<R> {
        return MatrixImpl(rows: rows, cols: cols, grid: grid)
    }
    
    func testNormalize_Z() {
        let A = M(1, 1, [-2])
        let E = A.eliminate()
        XCTAssertEqual(E.result, M(1, 1, [2]))
    }
    
    func testNormalize_Q() {
        let A = M(1, 1, [-3./1])
        let E = A.eliminate()
        XCTAssertEqual(E.result, M(1, 1, [1]))
    }
    
    func testZ55_regular() {
        let A = M(5, 5, [2, -1, -2, -2, -3, 1, 2, -1, 1, -1, 2, -2, -4, -3, -6, 1, 7, 1, 5, 3, 1, -12, -6, -10, -11])
        let E = A.copy().eliminate(form: .Smith)
        
        XCTAssertEqual(E.result,
                       M(5, 5, [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1]))
        
        XCTAssertEqual(E.left * A * E.right, E.result)
        XCTAssertEqual(E.leftInverse * E.result * E.rightInverse, A)
    }
    
    func testZ55_rank4() {
        let A = M(5, 5, [3, -5, -22, 20, 8, 6, -11, -50, 45, 18, -1, 2, 10, -9, -3, 3, -6, -30, 27, 10, -1, 2, 7, -6, -3])
        let E = A.copy().eliminate(form: .Smith)
        
        XCTAssertEqual(E.result,
                       M(5, 5, [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0]))
        
        XCTAssertEqual(E.left * A * E.right, E.result)
        XCTAssertEqual(E.leftInverse * E.result * E.rightInverse, A)
    }
    
    func testZ55_fullRankWithFactors() {
        let A = M(5, 5, [-20, -7, -27, 2, 29, 17, 8, 14, -4, -10, 13, 8, 10, -4, -6, -9, -2, -14, 0, 16, 5, 0, 5, -1, -4])
        let E = A.copy().eliminate(form: .Smith)
        
        XCTAssertEqual(E.result,
                       M(5, 5, [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 60]))
        
        XCTAssertEqual(E.left * A * E.right, E.result)
        XCTAssertEqual(E.leftInverse * E.result * E.rightInverse, A)
    }
    
    func testZ55_rank3WithFactors() {
        let A = M(5, 5, [4, 6, -18, -15, -46, -1, 0, 6, 4, 13, -13, -12, 36, 30, 97, -7, -6, 18, 15, 49, -6, -6, 18, 15, 48])
        let E = A.copy().eliminate(form: .Smith)
        
        XCTAssertEqual(E.result,
                       M(5, 5, [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
        
        XCTAssertEqual(E.left * A * E.right, E.result)
        XCTAssertEqual(E.leftInverse * E.result * E.rightInverse, A)
    }
    
    func testZ46_rank4WithFactors() {
        let A = M(4, 6, [8, -6, 14, -10, -14, 6, 12, -8, 18, -18, -20, 8, -16, 7, -23, 22, 23, -7, 32, -17, 44, -49, -49, 17])
        let E = A.copy().eliminate(form: .Smith)
        
        XCTAssertEqual(E.result,
                       M(4, 6, [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 12, 0, 0]))
        
        XCTAssertEqual(E.left * A * E.right, E.result)
        XCTAssertEqual(E.leftInverse * E.result * E.rightInverse, A)
    }
    
    func testZ46_zero() {
        let A = M(4, 6, Array(repeating: 0, count: 24))
        let E = A.copy().eliminate(form: .Smith)
        
        XCTAssertEqual(E.result, A)
    }
    
    func testQ55_regular() {
        let A = M(5, 5, [-3./1, 0./1, 0./1, -9./2, 0./1, 10./3, 2./1, 0./1, -15./2, 6./1, -10./3, -2./1, 0./1, 15./2, -10./1, 0./1, 0./1, 3./4, -5./1, 0./1, 0./1, 0./1, 1./1, 0./1, 0./1])
        let E = A.copy().eliminate(form: .Smith)
        
        XCTAssertEqual(E.result,
                       M(5, 5, [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1]))
        
        XCTAssertEqual(E.left * A * E.right, E.result)
        XCTAssertEqual(E.leftInverse * E.result * E.rightInverse, A)
    }
    
    func testQ55_rank3() {
        let A = M(5, 5, [1./1, 1./1, 0./1, 8./3, 10./3, -3./1, 0./1, 0./1, -3./1, -5./1, 2./1, 0./1, 10./3, 2./1, 16./3, 79./8, 0./1, 395./24, 79./8, 79./3, 7./2, 0./1, 35./6, 7./2, 28./3])
        let E = A.copy().eliminate(form: .Smith)
        
        XCTAssertEqual(E.result,
                       M(5, 5, [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
        
        XCTAssertEqual(E.left * A * E.right, E.result)
        XCTAssertEqual(E.leftInverse * E.result * E.rightInverse, A)
    }
}
