//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwiftyMath

class EuclideanRingTests: XCTestCase {
    private typealias A = 𝐙

    func testEucDiv() {
        let a = 7
        let b = 3
        let (q, r) = a.eucDiv(by: b)
        XCTAssertEqual(q, 2)
        XCTAssertEqual(r, 1)
    }

    func testEucDivOp() {
        let a = 7
        let b = 3
        let (q, r) = a /% b
        XCTAssertEqual(q, 2)
        XCTAssertEqual(r, 1)
    }

    func testDiv() {
        let a = 7
        let b = 3
        let q = a / b
        XCTAssertEqual(q, 2)
    }

    func testRem() {
        let a = 7
        let b = 3
        let r = a % b
        XCTAssertEqual(r, 1)
    }
}
