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
        let (q, r) = a /% b
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
    
    func testIsDivisible() {
        XCTAssertTrue(6.isDivible(by: 3))
        XCTAssertFalse(3.isDivible(by: 6))
        XCTAssertTrue(0.isDivible(by: 0))
        XCTAssertTrue(0.isDivible(by: 2))
        XCTAssertFalse(2.isDivible(by: 0))
    }
    
    func testDivides() {
        XCTAssertFalse(6.divides(3))
        XCTAssertTrue(3.divides(6))
        XCTAssertTrue(0.divides(0))
        XCTAssertFalse(0.divides(2))
        XCTAssertTrue(2.divides(0))
    }
}
