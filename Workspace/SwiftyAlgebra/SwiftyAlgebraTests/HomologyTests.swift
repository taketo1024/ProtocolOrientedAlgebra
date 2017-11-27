//
//  HomologyTests.swift
//  SwiftyAlgebraTests
//
//  Created by Taketo Sano on 2017/11/10.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwiftyAlgebra

class HomologyTests: XCTestCase {

    internal typealias H = Homology
    internal typealias cH = Cohomology

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_H_D3_Z() {
        let K = SimplicialComplex.ball(dim: 3)
        let h  = H(K, Z.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
        XCTAssert(h[3].isTrivial)
    }

    func test_H_S2_Z() {
        let K = SimplicialComplex.sphere(dim: 2)
        let h  = H(K, Z.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].summands.count == 1 && h[2][0].isFree)
    }

    func test_H_D3_S2_Z() {
        let K = SimplicialComplex.ball(dim: 3)
        let L = K.skeleton(2)
        let h  = H(K, L, Z.self)
        XCTAssert(h[0].isTrivial)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
        XCTAssert(h[3].summands.count == 1 && h[3][0].isFree)
    }

    func test_H_T2_Z() {
        let K = SimplicialComplex.torus(dim: 2)
        let h  = H(K, Z.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].summands.count == 2 && h[1].summands.forAll{ $0.isFree} )
        XCTAssert(h[2].summands.count == 1 && h[2][0].isFree)
    }

    func test_H_RP2_Z() {
        let K = SimplicialComplex.realProjectiveSpace(dim: 2)
        let h  = H(K, Z.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].summands.count == 1 && h[1][0].factor == 2 )
        XCTAssert(h[2].isTrivial)
    }

    func test_H_D3_Z2() {
        let K = SimplicialComplex.ball(dim: 3)
        let h  = H(K, Z_2.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
    }

    func test_H_S2_Z2() {
        let K = SimplicialComplex.sphere(dim: 2)
        let h  = H(K, Z_2.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].summands.count == 1 && h[2][0].isFree)
    }

    func test_H_D3_S2_Z2() {
        let K = SimplicialComplex.ball(dim: 3)
        let L = K.skeleton(2)
        let h  = H(K, L, Z_2.self)
        XCTAssert(h[0].isTrivial)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
        XCTAssert(h[3].summands.count == 1 && h[3][0].isFree)
    }

    func test_H_T2_Z2() {
        let K = SimplicialComplex.torus(dim: 2)
        let h  = H(K, Z_2.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].summands.count == 2 && h[1].summands.forAll{ $0.isFree} )
        XCTAssert(h[2].summands.count == 1 && h[2][0].isFree)
    }

    func test_H_RP2_Z2() {
        let K = SimplicialComplex.realProjectiveSpace(dim: 2)
        let h  = H(K, Z_2.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].summands.count == 1 && h[1][0].isFree)
        XCTAssert(h[2].summands.count == 1 && h[2][0].isFree)
    }

    func test_H_D3_Q() {
        let K = SimplicialComplex.ball(dim: 3)
        let h  = H(K, Q.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
    }

    func test_H_S2_Q() {
        let K = SimplicialComplex.sphere(dim: 2)
        let h  = H(K, Q.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].summands.count == 1 && h[2][0].isFree)
    }

    func test_H_D3_S2_Q() {
        let K = SimplicialComplex.ball(dim: 3)
        let L = K.skeleton(2)
        let h  = H(K, L, Q.self)
        XCTAssert(h[0].isTrivial)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
        XCTAssert(h[3].summands.count == 1 && h[3][0].isFree)
    }

    func test_H_T2_Q() {
        let K = SimplicialComplex.torus(dim: 2)
        let h  = H(K, Q.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].summands.count == 2 && h[1].summands.forAll{ $0.isFree} )
        XCTAssert(h[2].summands.count == 1 && h[2][0].isFree)
    }

    func test_H_RP2_Q() {
        let K = SimplicialComplex.realProjectiveSpace(dim: 2)
        let h  = H(K, Q.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
    }

    func test_cH_D3_Z() {
        let K = SimplicialComplex.ball(dim: 3)
        let h  = cH(K, Z.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
    }

    func test_cH_S2_Z() {
        let K = SimplicialComplex.sphere(dim: 2)
        let h  = cH(K, Z.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].summands.count == 1 && h[2][0].isFree)
    }

    func test_cH_D3_S2_Z() {
        let K = SimplicialComplex.ball(dim: 3)
        let L = K.skeleton(2)
        let h  = cH(K, L, Z.self)
        XCTAssert(h[0].isTrivial)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
        XCTAssert(h[3].summands.count == 1 && h[3][0].isFree)
    }

    func test_cH_T2_Z() {
        let K = SimplicialComplex.torus(dim: 2)
        let h  = cH(K, Z.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].summands.count == 2 && h[1].summands.forAll{ $0.isFree} )
        XCTAssert(h[2].summands.count == 1 && h[2][0].isFree)
    }

    func test_cH_RP2_Z() {
        let K = SimplicialComplex.realProjectiveSpace(dim: 2)
        let h  = cH(K, Z.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].summands.count == 1 && h[2][0].factor == 2 )
    }

    func test_cH_D3_Z2() {
        let K = SimplicialComplex.ball(dim: 3)
        let h  = cH(K, Z_2.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
    }

    func test_cH_S2_Z2() {
        let K = SimplicialComplex.sphere(dim: 2)
        let h  = cH(K, Z_2.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].summands.count == 1 && h[2][0].isFree)
    }

    func test_cH_D3_S2_Z2() {
        let K = SimplicialComplex.ball(dim: 3)
        let L = K.skeleton(2)
        let h  = cH(K, L, Z_2.self)
        XCTAssert(h[0].isTrivial)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
        XCTAssert(h[3].summands.count == 1 && h[3][0].isFree)
    }

    func test_cH_T2_Z2() {
        let K = SimplicialComplex.torus(dim: 2)
        let h  = cH(K, Z_2.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].summands.count == 2 && h[1].summands.forAll{ $0.isFree} )
        XCTAssert(h[2].summands.count == 1 && h[2][0].isFree)
    }

    func test_cH_RP2_Z2() {
        let K = SimplicialComplex.realProjectiveSpace(dim: 2)
        let h  = cH(K, Z_2.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].summands.count == 1 && h[1][0].isFree)
        XCTAssert(h[2].summands.count == 1 && h[2][0].isFree)
    }

    func test_cH_D3_Q() {
        let K = SimplicialComplex.ball(dim: 3)
        let h  = cH(K, Q.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
    }

    func test_cH_S2_Q() {
        let K = SimplicialComplex.sphere(dim: 2)
        let h  = cH(K, Q.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].summands.count == 1 && h[2][0].isFree)
    }

    func test_cH_D3_S2_Q() {
        let K = SimplicialComplex.ball(dim: 3)
        let L = K.skeleton(2)
        let h  = cH(K, L, Q.self)
        XCTAssert(h[0].isTrivial)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
        XCTAssert(h[3].summands.count == 1 && h[3][0].isFree)
    }

    func test_cH_T2_Q() {
        let K = SimplicialComplex.torus(dim: 2)
        let h  = cH(K, Q.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].summands.count == 2 && h[1].summands.forAll{ $0.isFree} )
        XCTAssert(h[2].summands.count == 1 && h[2][0].isFree)
    }

    func test_cH_RP2_Q() {
        let K = SimplicialComplex.realProjectiveSpace(dim: 2)
        let h  = cH(K, Q.self)
        XCTAssert(h[0].summands.count == 1 && h[0][0].isFree)
        XCTAssert(h[1].isTrivial)
        XCTAssert(h[2].isTrivial)
    }
}
