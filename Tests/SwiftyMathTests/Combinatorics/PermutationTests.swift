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
}
