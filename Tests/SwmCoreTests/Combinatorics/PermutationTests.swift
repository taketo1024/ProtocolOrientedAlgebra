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
    
    func testLength() {
        let p = S3(indices: 2, 0, 1)
        XCTAssertEqual(p.length, 3)
    }
    
    func testIndices() {
        let p = S3(indices: 2, 0, 1)
        XCTAssertEqual(p.indices, [2,0,1])
    }
    
    func testSubscript() {
        let p = S3(indices: 2, 0, 1)
        XCTAssertEqual(p[0], 2)
        XCTAssertEqual(p[1], 0)
        XCTAssertEqual(p[2], 1)
    }

    func testIdentity() {
        let id = S3.identity
        XCTAssertEqual(id.indices, [0,1,2])
    }

    func testMul() {
        let p = S3(indices: 2, 0, 1)
        let q = S3(indices: 0, 2, 1)
        let s = q * p
        XCTAssertEqual(s[0], 1)
        XCTAssertEqual(s[1], 0)
        XCTAssertEqual(s[2], 2)
    }
    
    func testFill() {
        let p = Permutation<anySize>.fill(length: 10, indices: [2, 1, 5, 8])
        XCTAssertEqual(p.indices, [2,1,5,8,0,3,4,6,7,9])
    }

    func testTransposition() {
        let p = S4.transposition(0, 2)
        XCTAssertEqual(p.indices, [2,1,0,3])
    }

    func testCyclic() {
        let p = S4.cyclic(0,2,3)
        XCTAssertEqual(p.indices, [2,1,3,0])
    }

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
    
    func testCyclicDecomposition() {
        let n = 10
        let σ = Permutation<anySize>(indices: 3,2,1,5,9,7,8,0,4,6)
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
        let σ = Permutation<anySize>(indices: 3,2,1,5,9,7,8,0,4,6)
        let trans = σ.transpositionDecomposition
        
        let τ = trans.map { t in
            Permutation<anySize>.transposition(length: n, indices: t)
        }.reduce(Permutation<anySize>.identity(length: n)) {
            $1 * $0 
        }
        
        XCTAssertEqual(σ, τ)
    }
}
