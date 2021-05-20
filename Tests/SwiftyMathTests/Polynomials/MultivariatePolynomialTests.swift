//
//  PolynomialTests.swift
//  SwiftyKnotsTests
//
//  Created by Taketo Sano on 2018/04/10.
//

import XCTest
@testable import SwiftyMath

class MPolynomialTests: XCTestCase {
    struct xyz: MultivariatePolynomialIndeterminates {
        typealias NumberOfIndeterminates = _3
        static func symbol(_ i: Int) -> String {
            switch i {
            case 0: return "x"
            case 1: return "y"
            case 2: return "z"
            default: fatalError()
            }
        }
    }
    
    struct xn: MultivariatePolynomialIndeterminates {
        typealias NumberOfIndeterminates = DynamicSize
        static func symbol(_ i: Int) -> String {
            "x\(Format.sub(i))"
        }
    }

    typealias A = MultivariatePolynomial<𝐙, xyz>
    typealias B = MultivariatePolynomial<𝐙, xn>

    func testFiniteVariateIndeterminates() {
        XCTAssertTrue (xyz.isFinite)
        XCTAssertEqual(xyz.numberOfIndeterminates, 3)
        XCTAssertEqual(xyz.degree(0), 1)
        XCTAssertEqual(xyz.degree(1), 1)
        XCTAssertEqual(xyz.degree(2), 1)
        XCTAssertEqual(xyz.symbol(0), "x")
        XCTAssertEqual(xyz.symbol(1), "y")
        XCTAssertEqual(xyz.symbol(2), "z")
//        XCTAssertEqual(xyz.totalDegree(exponents: [2, 3, 7]), 12)
    }
    
    func testInfiniteVariateIndeterminates() {
        XCTAssertFalse(xn.isFinite)
        XCTAssertEqual(xn.degree(0), 1)
        XCTAssertEqual(xn.degree(1), 1)
        XCTAssertEqual(xn.degree(2), 1)
        XCTAssertEqual(xn.symbol(0), "x₀")
        XCTAssertEqual(xn.symbol(1), "x₁")
        XCTAssertEqual(xn.symbol(1), "x₁")
//        XCTAssertEqual(xn.totalDegree(exponents: [2, 3, 7]), 12)
    }
    
    func testInitFromInt() {
        let a = A(3)
        XCTAssertTrue(a.isConst)
        XCTAssertEqual(a.constTerm, A(3))
        XCTAssertEqual(a.constCoeff, 3)
        XCTAssertEqual(a.degree, 0)
    }

    func testInitFromIntLiteral() {
        let a: A = 3
        XCTAssertTrue(a.isConst)
        XCTAssertEqual(a.constTerm, A(3))
        XCTAssertEqual(a.constCoeff, 3)
        XCTAssertEqual(a.degree, 0)
    }
    
    func testInitFromCoeffList() {
        // 3x²y + 2x + y + 1
        let a = A(coeffs: [[]: 1, [1]: 2, [0, 1]: 1, [2, 1]: 3])
        XCTAssertTrue(!a.isConst)
        XCTAssertEqual(a.constTerm, A(1))
        XCTAssertEqual(a.coeff(1), 2)
        XCTAssertEqual(a.coeff(0, 1), 1)
        XCTAssertEqual(a.coeff(2, 1), 3)
        XCTAssertEqual(a.leadExponent, [2, 1])
    }
    
    func testCoeff() {
        let a = A(coeffs: [[1]: 2])
        XCTAssertEqual(a.coeff([1]), 2)
        XCTAssertEqual(a.coeff([1, 0]), 2)
    }
    
    func testUniqueness() {
        let a = A(13)
        let b = A(coeffs: [[0,0]: 13])
        XCTAssertEqual(a, b)
    }
    
    func testUniqueness2() {
        let a = A(coeffs: [[1]: 1])
        let b = A(coeffs: [[1,0]: 1, [0,1]: 0])
        XCTAssertEqual(a, b)
    }
    
    func testSum() {
        let a = A(coeffs: [[]: 1, [1]: 1, [0, 1]: 1]) // x + y + 1
        let b = A(coeffs: [[1]: -1, [0, 1]: 2, [1, 1]: 3]) // 3xy - x + 2y
        XCTAssertEqual(a + b, A(coeffs: [[]: 1, [0, 1]: 3, [1, 1]: 3]))
    }

    func testZero() {
        let a = A(coeffs: [[]: 1, [1]: 1, [0, 1]: 1]) // x + y + 1
        XCTAssertEqual(a + A.zero, a)
        XCTAssertEqual(A.zero + a, a)
    }

    func testNeg() {
        let a = A(coeffs: [[]: 1, [1]: 1, [0, 1]: 1])
        XCTAssertEqual(-a, A(coeffs: [[]: -1, [1]: -1, [0, 1]: -1]))
    }

    func testMul() {
        let a = A(coeffs: [[1]: 1, [0, 1]: 1]) // x + y
        let b = A(coeffs: [[1]: 2, [0, 1]: -1]) // 2x - y
        XCTAssertEqual(a * b, A(coeffs: [[2]: 2, [1, 1]: 1, [0, 2]: -1]))
    }

    func testId() {
        let a = A(coeffs: [[]: 1, [1]: 1, [0, 1]: 1])
        let e = A.identity
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }

    func testInv() {
        let a = A(-1)
        XCTAssertEqual(a.inverse, .some(a))

        let b = A(3)
        XCTAssertNil(b.inverse)

        let c = A(coeffs: [[]: 1, [1]: 1, [0, 1]: 1])
        XCTAssertNil(c.inverse)
    }

    func testEvaluate() {
        let a = A(coeffs: [[]: 2, [1]: -1, [0, 1]: 2, [1, 1]: 3]) // f(x,y) = 3xy - x + 2y + 2
        XCTAssertEqual(a.evaluate(by: 1, 2), 11)                  // f(1, 2) = 6 - 1 + 4 + 2
    }

//    func testGenerateMonomials() {
//        let mons = A.monomials(ofTotalExponent: 3)
//        XCTAssertEqual(mons.count, 4)
//        XCTAssertTrue(mons.allSatisfy{ $0.degree == 3 })
//    }
    
    //    func testSymmetricPolynomial() {
    //        XCTAssertEqual(A.elementarySymmetric(0), A(1))
    //        XCTAssertEqual(A.elementarySymmetric(1), A(coeffs: [[1]: 1, [0, 1]: 1]))
    //        XCTAssertEqual(A.elementarySymmetric(2), A(coeffs: [[1, 1]: 1]))
    //    }
}
