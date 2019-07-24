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

    func testRawPermutations_4() {
        let n = 4
        let ps = DPermutation.rawPermutations(length: n)
        XCTAssertEqual(ps.count, n.factorial)
        XCTAssertTrue(ps.isUnique)
    }
    
    func testRawPermutations_5() {
        let n = 5
        let ps = DPermutation.rawPermutations(length: n)
        XCTAssertEqual(ps.count, n.factorial)
        XCTAssertTrue(ps.isUnique)
    }
    
    func testRawTranspositions_4() {
        let n = 4
        let ps = DPermutation.rawTranspositions(within: n)
        XCTAssertEqual(ps.count, n * (n - 1) / 2)
        XCTAssertTrue(ps.map{ [$0, $1] }.isUnique)
    }

    func testRawTranspositions_5() {
        let n = 5
        let ps = DPermutation.rawTranspositions(within: n)
        XCTAssertEqual(ps.count, n * (n - 1) / 2)
        XCTAssertTrue(ps.map{ [$0, $1] }.isUnique)
    }
}
