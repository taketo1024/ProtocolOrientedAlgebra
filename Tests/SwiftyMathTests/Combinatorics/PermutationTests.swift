//
//  PermutationTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2019/05/30.
//

import XCTest
@testable import SwiftyMath

class PermutationTests: XCTestCase {
    
    typealias S3 = Permutation<_3>
    typealias S4 = Permutation<_4>

    func testAllPermutations_3() {
        let all = S3.allElements
        XCTAssertEqual(all.count, 6)
        XCTAssertTrue(all.isUnique)
    }
    
    func testAllPermutations_4() {
        let all = S4.allElements
        XCTAssertEqual(all.count, 24)
        XCTAssertTrue(all.isUnique)
    }
    
    func testAllTranspositions_3() {
        let all = S3.allTranspositions
        XCTAssertEqual(all.count, 3)
        XCTAssertTrue(all.isUnique)
    }

    func testAllTranspositions_4() {
        let all = S4.allTranspositions
        XCTAssertEqual(all.count, 6)
        XCTAssertTrue(all.isUnique)
    }
    
    func testAsMatrix() {
        let σ = S3(2,0,1)
        let A = σ.asMatrix
        XCTAssertEqual(A, Matrix3(0,1,0,0,0,1,1,0,0))
    }

    func testAsMatrixProduct() {
        let σ = S3(2,0,1)
        let τ = S3(1,2,0)
        XCTAssertEqual(σ.asMatrix * τ.asMatrix, (σ * τ).asMatrix)
    }
}
