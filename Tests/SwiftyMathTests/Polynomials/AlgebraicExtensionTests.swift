//
//  SwiftyMathTests.swift
//  SwiftyMathTests
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import XCTest
@testable import SwiftyMath

// TODO move to Quotient Ring
extension AlgebraicExtension: ExpressibleByIntegerLiteral where Base: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Base.IntegerLiteralType) {
        self.init(Base(integerLiteral: value))
    }
}

class AlgebraicExtensionTests: XCTestCase {
    struct _x: PolynomialIndeterminate {
        static let symbol: String = "x"
    }
    typealias P = Polynomial<𝐐, _x>
    
    struct p1: IrrPolynomialTP {
        static let value = P(coeffs: -2, 0, 1)
    }
    
    typealias A = AlgebraicExtension<𝐐, p1>
    
    struct p2: IrrPolynomialTP {
        static let value = Polynomial<A, _x>(coeffs: -3, 0, 1)
    }
    
    typealias B = AlgebraicExtension<A, p2>
    
    let α = A(.indeterminate)
    let β = B(.indeterminate)

    func testIsField() {
        XCTAssertTrue(A.isField)
    }
    
    func testIntLiteral() {
        let a: A = 2
        XCTAssertEqual(a, A(2))
    }
    
    func testFromInt() {
        let a = A(from: 1)
        XCTAssertEqual(a, A(1))
    }
    
    func testSum() {
        let a = 1 + 2 * α
        let b = 3 + 4 * α
        XCTAssertEqual(a + b, 4 + 6 * α)
    }
    
    func testZero() {
        let a = 1 + 2 * α
        let o = A.zero
        XCTAssertEqual(o + o, o)
        XCTAssertEqual(a + o, a)
        XCTAssertEqual(o + a, a)
    }
    
    func testNeg() {
        let a = 1 + 2 * α
        XCTAssertEqual(-a, -1 - 2 * α)
    }
    
    func testExtension() {
        XCTAssertEqual(α * α, 2)
        XCTAssertEqual(β * β, 3)
    }
    
    func testMul() {
        let a = 1 + 2 * α
        let b = 3 + 4 * α
        XCTAssertEqual(a * b, 19 + 10 * α)
    }
    
    func testId() {
        let a = 3 + 4 * α
        let e = A.identity
        XCTAssertEqual(e * e, e)
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }
    
    func testInv() {
        XCTAssertEqual(α.inverse!, A(1./2) * α)

        let a = 1 + 3 * α
        XCTAssertEqual(a.inverse!, A(-1./17) + A(3./17) * α)

        let o = A.zero
        XCTAssertNil(o.inverse)
    }

    func testPow() {
        let a = 1 + 2 * α
        XCTAssertEqual(a.pow(0), 1)
        XCTAssertEqual(a.pow(1), 1 + 2 * α)
        XCTAssertEqual(a.pow(2), 9 + 4 * α)

        XCTAssertEqual(a.pow(-1), A(-1./7) + A(2./7) * α)
        XCTAssertEqual(a.pow(-2), A(9./49) + A(-4./49) * α)

    }
}
