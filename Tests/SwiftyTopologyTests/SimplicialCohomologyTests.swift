//
//  HomologyTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/11/10.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
import SwiftyMath
@testable import SwiftyTopology

class SimplicialCohomologyTests: XCTestCase {

    internal typealias cH = Cohomology

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testD3_Z() {
        let K = SimplicialComplex.ball(dim: 3)
        let h = cH(K, 𝐙.self)
        XCTAssert(h[0].isFree && h[0].rank == 1)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
    }

    func testS2_Z() {
        let K = SimplicialComplex.sphere(dim: 2)
        let h = cH(K, 𝐙.self)
        XCTAssert(h[0].isFree && h[0].rank == 1)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isFree && h[2].rank == 1)
    }

    func testD3_S2_Z() {
        let K = SimplicialComplex.ball(dim: 3)
        let L = K.skeleton(2)
        let h = cH(K, L, 𝐙.self)
        XCTAssert(h[0].isTrivial)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
        XCTAssert(h[3].isFree && h[3].rank == 1)
    }

    func testT2_Z() {
        let K = SimplicialComplex.torus(dim: 2)
        let h = cH(K, 𝐙.self)
        XCTAssert(h[0].isFree && h[0].rank == 1)
        XCTAssert(h[1].isFree && h[1].rank == 2)
        XCTAssert(h[2].isFree && h[2].rank == 1)
    }

    func testRP2_Z() {
        let K = SimplicialComplex.realProjectiveSpace(dim: 2)
        let h = cH(K, 𝐙.self)
        XCTAssert(h[0].isFree && h[0].rank == 1)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].summands.count == 1 && h[2].torsionCoeffs[0] == 2)
    }

    func testD3_Z2() {
        let K = SimplicialComplex.ball(dim: 3)
        let h = cH(K, 𝐙₂.self)
        XCTAssert(h[0].isFree && h[0].rank == 1)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
    }

    func testS2_Z2() {
        let K = SimplicialComplex.sphere(dim: 2)
        let h = cH(K, 𝐙₂.self)
        XCTAssert(h[0].isFree && h[0].rank == 1)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isFree && h[2].rank == 1)
    }

    func testD3_S2_Z2() {
        let K = SimplicialComplex.ball(dim: 3)
        let L = K.skeleton(2)
        let h = cH(K, L, 𝐙₂.self)
        XCTAssert(h[0].isTrivial)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
        XCTAssert(h[3].isFree && h[3].rank == 1)
    }

    func testT2_Z2() {
        let K = SimplicialComplex.torus(dim: 2)
        let h = cH(K, 𝐙₂.self)
        XCTAssert(h[0].isFree && h[0].rank == 1)
        XCTAssert(h[1].isFree && h[1].rank == 2)
        XCTAssert(h[2].isFree && h[2].rank == 1)
    }

    func testRP2_Z2() {
        let K = SimplicialComplex.realProjectiveSpace(dim: 2)
        let h = cH(K, 𝐙₂.self)
        XCTAssert(h[0].isFree && h[0].rank == 1)
        XCTAssert(h[1].isFree && h[1].rank == 1)
        XCTAssert(h[2].isFree && h[2].rank == 1)
    }

    func testD3_Q() {
        let K = SimplicialComplex.ball(dim: 3)
        let h = cH(K, 𝐐.self)
        XCTAssert(h[0].isFree && h[0].rank == 1)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
    }

    func testS2_Q() {
        let K = SimplicialComplex.sphere(dim: 2)
        let h = cH(K, 𝐐.self)
        XCTAssert(h[0].isFree && h[0].rank == 1)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isFree && h[2].rank == 1)
    }

    func testD3_S2_Q() {
        let K = SimplicialComplex.ball(dim: 3)
        let L = K.skeleton(2)
        let h = cH(K, L, 𝐐.self)
        XCTAssert(h[0].isTrivial)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
        XCTAssert(h[3].isFree && h[3].rank == 1)
    }

    func testT2_Q() {
        let K = SimplicialComplex.torus(dim: 2)
        let h = cH(K, 𝐐.self)
        XCTAssert(h[0].isFree && h[0].rank == 1)
        XCTAssert(h[1].isFree && h[1].rank == 2)
        XCTAssert(h[2].isFree && h[2].rank == 1)
    }

    func testRP2_Q() {
        let K = SimplicialComplex.realProjectiveSpace(dim: 2)
        let h = cH(K, 𝐐.self)
        XCTAssert(h[0].isFree && h[0].rank == 1)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
    }
}
