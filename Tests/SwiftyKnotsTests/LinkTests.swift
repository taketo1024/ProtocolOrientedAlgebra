//
//  LinkTests.swift
//  SwiftyKnots
//
//  Created by Taketo Sano on 2018/04/04.
//

import XCTest
import SwiftyMath
@testable import SwiftyKnots

class LinkTests: XCTestCase {

    typealias A = LaurentPolynomial<𝐙>

    func testEmpty() {
        let e = Link.empty
        XCTAssertEqual(e.components.count, 0)
        XCTAssertEqual(e.crossingNumber, 0)
        XCTAssertEqual(e.unnormalizedJonesPolynomial, A(1))
    }

    func testUnknot() {
        let O = Link.unknot
        XCTAssertEqual(O.components.count, 1)
        XCTAssertEqual(O.crossingNumber, 0)
        XCTAssertEqual(O.JonesPolynomial, A(1))
    }

    func testHopfLink() {
        let L = Link.HopfLink
        XCTAssertEqual(L.components.count, 2)
        XCTAssertEqual(L.crossingNumber, 2)
        XCTAssertEqual(L.writhe, -2)
        XCTAssertEqual(L.JonesPolynomial, A(symbol: "q", coeffs: [-5: 1, -1: 1]) )
    }

    func testHopfLinkReversed() {
        let L = Link.HopfLink.reversed
        XCTAssertEqual(L.components.count, 2)
        XCTAssertEqual(L.crossingNumber, 2)
        XCTAssertEqual(L.writhe, -2)
        XCTAssertEqual(L.JonesPolynomial, A(symbol: "q", coeffs: [-5: 1, -1: 1]) )
    }

    func testHopfLinkMirrored() {
        let L = Link.HopfLink.mirrored
        XCTAssertEqual(L.components.count, 2)
        XCTAssertEqual(L.crossingNumber, 2)
        XCTAssertEqual(L.writhe, 2)
        XCTAssertEqual(L.JonesPolynomial, A(symbol: "q", coeffs: [5: 1, 1: 1]) )
    }

    func testTrefoil() {
        let K = Link.trefoil
        XCTAssertEqual(K.components.count, 1)
        XCTAssertEqual(K.crossingNumber, 3)
        XCTAssertEqual(K.writhe, -3)
        XCTAssertEqual(K.JonesPolynomial, A(symbol: "q", coeffs: [-8: -1, -6: 1, -2: 1]))
    }

    func testTrefoilReversed() {
        let K = Link.trefoil.reversed
        XCTAssertEqual(K.components.count, 1)
        XCTAssertEqual(K.crossingNumber, 3)
        XCTAssertEqual(K.writhe, -3)
        XCTAssertEqual(K.JonesPolynomial, A(symbol: "q", coeffs: [-8: -1, -6: 1, -2: 1]))
    }

    func testTrefoilMirrored() {
        let K = Link.trefoil.mirrored
        XCTAssertEqual(K.components.count, 1)
        XCTAssertEqual(K.crossingNumber, 3)
        XCTAssertEqual(K.writhe, 3)
        XCTAssertEqual(K.JonesPolynomial, A(symbol: "q", coeffs: [8: -1, 6: 1, 2: 1]))
    }

    func testCoding() {
        let K = Link.trefoil
        let d = try! JSONEncoder().encode(K)
        let K2 = try! JSONDecoder().decode(Link.self, from: d)
        XCTAssertEqual(K, K2)
    }
}
