//
//  KHTests.swift
//  SwiftyKnots
//
//  Created by Taketo Sano on 2018/04/04.
//

import XCTest
import SwiftyMath
@testable import SwiftyKnots

class KhHomologyTests: XCTestCase {

    func test3_1() {
        let L = Link.knot(3, 1)
        assert(L)
    }

    func test4_1() {
        let L = Link.knot(4, 1)
        assert(L)
    }

    func test5_1() {
        let L = Link.knot(5, 1)
        assert(L)
    }

    func assert(_ L: Link) {
        let J = L.unnormalizedJonesPolynomial

        let Kh = L.khHomology(𝐙.self)
        let χ = Kh.gradedEulerCharacteristic.withSymbol("q")

        XCTAssertEqual(χ, J)
    }
}
