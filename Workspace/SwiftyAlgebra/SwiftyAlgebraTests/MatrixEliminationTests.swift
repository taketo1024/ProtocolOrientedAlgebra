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

private extension ComputationalMatrix {
    convenience init(_ r: Int, _ c: Int, _ g: [R]) {
        self.init(rows: r, cols: c, grid: g)
    }
}

class MatrixEliminationTests: XCTestCase {

    typealias M<R: EuclideanRing> = ComputationalMatrix<R>
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testElimination_Z55_regular() {
        let A = M(5, 5, [2, -1, -2, -2, -3, 1, 2, -1, 1, -1, 2, -2, -4, -3, -6, 1, 7, 1, 5, 3, 1, -12, -6, -10, -11])
        let E = SmithEliminator(A.copy()).run()

        XCTAssertEqual(E.result,
                       M(5, 5, [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1]))

        XCTAssertEqual(E.left * A * E.right, E.result)
        XCTAssertEqual(E.leftInverse * E.result * E.rightInverse, A)
    }

    func testElimination_Z55_rank4() {
        let A = M(5, 5, [3, -5, -22, 20, 8, 6, -11, -50, 45, 18, -1, 2, 10, -9, -3, 3, -6, -30, 27, 10, -1, 2, 7, -6, -3])
        let E = SmithEliminator(A.copy()).run()

        XCTAssertEqual(E.result,
                       M(5, 5, [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0]))

        XCTAssertEqual(E.left * A * E.right, E.result)
        XCTAssertEqual(E.leftInverse * E.result * E.rightInverse, A)
    }

    func testElimination_Z55_fullRankWithFactors() {
        let A = M(5, 5, [-20, -7, -27, 2, 29, 17, 8, 14, -4, -10, 13, 8, 10, -4, -6, -9, -2, -14, 0, 16, 5, 0, 5, -1, -4])
        let E = SmithEliminator(A.copy()).run()

        XCTAssertEqual(E.result,
                       M(5, 5, [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 60]))

        XCTAssertEqual(E.left * A * E.right, E.result)
        XCTAssertEqual(E.leftInverse * E.result * E.rightInverse, A)
    }

    func testElimination_Z55_rank3WithFactors() {
        let A = M(5, 5, [4, 6, -18, -15, -46, -1, 0, 6, 4, 13, -13, -12, 36, 30, 97, -7, -6, 18, 15, 49, -6, -6, 18, 15, 48])
        let E = SmithEliminator(A.copy()).run()

        XCTAssertEqual(E.result,
                       M(5, 5, [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))

        XCTAssertEqual(E.left * A * E.right, E.result)
        XCTAssertEqual(E.leftInverse * E.result * E.rightInverse, A)
    }

    func testElimination_Z46_rank4WithFactors() {
        let A = M(4, 6, [8, -6, 14, -10, -14, 6, 12, -8, 18, -18, -20, 8, -16, 7, -23, 22, 23, -7, 32, -17, 44, -49, -49, 17])
        let E = SmithEliminator(A.copy()).run()

        XCTAssertEqual(E.result,
                       M(4, 6, [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 12, 0, 0]))

        XCTAssertEqual(E.left * A * E.right, E.result)
        XCTAssertEqual(E.leftInverse * E.result * E.rightInverse, A)
    }

    func testElimination_Z46_zero() {
        let A = M(4, 6, Array(repeating: 0, count: 24))
        let E = SmithEliminator(A.copy()).run()

        XCTAssertEqual(E.result, A)
    }

    func testElimination_Q55_regular() {
        let A = M(5, 5, [Q(-3, 1), Q(0, 1), Q(0, 1), Q(-9, 2), Q(0, 1), Q(10, 3), Q(2, 1), Q(0, 1), Q(-15, 2), Q(6, 1), Q(-10, 3), Q(-2, 1), Q(0, 1), Q(15, 2), Q(-10, 1), Q(0, 1), Q(0, 1), Q(3, 4), Q(-5, 1), Q(0, 1), Q(0, 1), Q(0, 1), Q(1, 1), Q(0, 1), Q(0, 1)])
        let E = SmithEliminator(A.copy()).run()

        XCTAssertEqual(E.result,
                       M<Q>(5, 5, [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1]))

        XCTAssertEqual(E.left * A * E.right, E.result)
        XCTAssertEqual(E.leftInverse * E.result * E.rightInverse, A)
    }

    func testElimination_Q55_rank3() {
        let A = M(5, 5, [Q(1, 1), Q(1, 1), Q(0, 1), Q(8, 3), Q(10, 3), Q(-3, 1), Q(0, 1), Q(0, 1), Q(-3, 1), Q(-5, 1), Q(2, 1), Q(0, 1), Q(10, 3), Q(2, 1), Q(16, 3), Q(79, 8), Q(0, 1), Q(395, 24), Q(79, 8), Q(79, 3), Q(7, 2), Q(0, 1), Q(35, 6), Q(7, 2), Q(28, 3)])
        let E = SmithEliminator(A.copy()).run()

        XCTAssertEqual(E.result,
                       M<Q>(5, 5, [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))

        XCTAssertEqual(E.left * A * E.right, E.result)
        XCTAssertEqual(E.leftInverse * E.result * E.rightInverse, A)
    }
}
