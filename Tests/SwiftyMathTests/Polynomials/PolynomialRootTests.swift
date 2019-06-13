//
//  PolynomialRootTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2019/06/12.
//

import XCTest
@testable import SwiftyMath

class PolynomialRootTests: XCTestCase {

    typealias P = Polynomial<𝐂, Indeterminate_x>
    
    func testExample() {
        let f = P(coeffs: 1, 0, 1)
        let i = 𝐂.imaginaryUnit
        let zs = f.findAllRoots()
        XCTAssertEqual(Set(zs), Set([i, -i]))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
