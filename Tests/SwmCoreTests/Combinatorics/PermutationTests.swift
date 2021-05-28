//
//  PermutationTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2019/05/30.
//

import XCTest
@testable import SwmCore

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
        let σ = S3(indices: 2,0,1)
        let A = σ.asMatrix
        XCTAssertEqual(A, [0,1,0,0,0,1,1,0,0])
    }

    func testAsMatrixProduct() {
        let σ = S3(indices: 2,0,1)
        let τ = S3(indices: 1,2,0)
        XCTAssertEqual(σ.asMatrix * τ.asMatrix, (σ * τ).asMatrix)
    }
    
    func testCyclic() {
        let σ = S3.cyclic(2,0,1)
        XCTAssertEqual(σ[2], 0)
        XCTAssertEqual(σ[0], 1)
        XCTAssertEqual(σ[1], 2)
    }
    
    func testCyclicDecomposition() {
        let n = 10
        let σ = Permutation<anySize>(length: n, indices: 3,2,1,5,9,7,8,0,4,6)
        let cyclics = σ.cyclicDecomposition
        
        XCTAssertEqual(cyclics.count, 3)
        XCTAssertEqual(Set(cyclics.map{ $0.count}), [2, 4, 4])
        
        let τ = cyclics.map { c in
            Permutation<anySize>.cyclic(length: n, indices: c)
        }.reduce(Permutation<anySize>.identity(length: n)) {
            $1 * $0
        }
        
        XCTAssertEqual(σ, τ)
    }
    
    func testTranspositionDecomposition() {
        let n = 10
        let σ = Permutation<anySize>(length: 10, indices: 3,2,1,5,9,7,8,0,4,6)
        let trans = σ.transpositionDecomposition
        
        let τ = trans.map { t in
            Permutation<anySize>.transposition(length: n, indices: t)
        }.reduce(Permutation<anySize>.identity(length: n)) {
            $1 * $0 
        }
        
        XCTAssertEqual(σ, τ)
    }
}
