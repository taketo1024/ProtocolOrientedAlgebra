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
        static func symbolOfIndeterminate(at i: Int) -> String {
            switch i {
            case 0: return "x"
            case 1: return "y"
            case 2: return "z"
            default: fatalError()
            }
        }
        
        static func degreeOfIndeterminate(at i: Int) -> Int {
            i + 1
        }
    }
    
    struct xn: MultivariatePolynomialIndeterminates {
        typealias NumberOfIndeterminates = DynamicSize
        static func symbolOfIndeterminate(at i: Int) -> String {
            "x\(Format.sub(i))"
        }
        
        static func degreeOfIndeterminate(at i: Int) -> Int {
            i + 1
        }
    }

    typealias A = MultivariatePolynomial<𝐙, xyz>
    typealias B = MultivariatePolynomial<𝐙, xn>

    func testFiniteVariateIndeterminates() {
        XCTAssertTrue (xyz.isFinite)
        XCTAssertEqual(xyz.numberOfIndeterminates, 3)
        XCTAssertEqual(xyz.degreeOfIndeterminate(at: 0), 1)
        XCTAssertEqual(xyz.degreeOfIndeterminate(at: 1), 2)
        XCTAssertEqual(xyz.degreeOfIndeterminate(at: 2), 3)
        XCTAssertEqual(xyz.degreeOfMonomial(withExponent: [1, 0, 3]), 10)
        
        XCTAssertEqual(xyz.symbolOfIndeterminate(at: 0), "x")
        XCTAssertEqual(xyz.symbolOfIndeterminate(at: 1), "y")
        XCTAssertEqual(xyz.symbolOfIndeterminate(at: 2), "z")
        XCTAssertEqual(xyz.descriptionOfMonomial(withExponent: [1, 2, 3]), "xy²z³")
    }
    
    func testInfiniteVariateIndeterminates() {
        XCTAssertFalse(xn.isFinite)
        XCTAssertEqual(xn.degreeOfIndeterminate(at: 0), 1)
        XCTAssertEqual(xn.degreeOfIndeterminate(at: 1), 2)
        XCTAssertEqual(xn.degreeOfIndeterminate(at: 2), 3)
        XCTAssertEqual(xn.degreeOfMonomial(withExponent: [0, 2, 2]), 10)

        XCTAssertEqual(xn.symbolOfIndeterminate(at: 0), "x₀")
        XCTAssertEqual(xn.symbolOfIndeterminate(at: 1), "x₁")
        XCTAssertEqual(xn.symbolOfIndeterminate(at: 2), "x₂")
        XCTAssertEqual(xn.descriptionOfMonomial(withExponent: [1, 0, 3, 4]), "x₀x₂³x₃⁴")
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
    
    func testDegree() {
        let a = A(coeffs: [.zero: 1, [1,2,3]: 2, [5,2]: 3])
        XCTAssertEqual(a.leadExponent, [1,2,3])
        XCTAssertEqual(a.degree, 14)
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

    func testMonomialsOfDegree() {
        let mons = A.monomials(ofDegree: 5)
        XCTAssertEqual(mons.count, 5)
        XCTAssertTrue(mons.allSatisfy{ $0.degree == 5 })
    }
    
    //    func testSymmetricPolynomial() {
    //        XCTAssertEqual(A.elementarySymmetric(0), A(1))
    //        XCTAssertEqual(A.elementarySymmetric(1), A(coeffs: [[1]: 1, [0, 1]: 1]))
    //        XCTAssertEqual(A.elementarySymmetric(2), A(coeffs: [[1, 1]: 1]))
    //    }
}
