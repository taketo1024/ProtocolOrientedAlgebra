//
//  PolynomialTests.swift
//  SwiftyKnotsTests
//
//  Created by Taketo Sano on 2018/04/10.
//

import XCTest
@testable import SwmCore

class MPolynomialTests: XCTestCase {
    struct xy: MultivariatePolynomialIndeterminates {
        typealias Exponent = MultiIndex<_2>
        typealias NumberOfIndeterminates = _2
        static func symbolOfIndeterminate(at i: Int) -> String {
            switch i {
            case 0: return "x"
            case 1: return "y"
            default: fatalError()
            }
        }
    }
    
    struct x: PolynomialIndeterminate {
        static let symbol = "x"
    }
    typealias xn = EnumeratedPolynomialIndeterminates<x, anySize>

    typealias A = MultivariatePolynomial<𝐙, xy>
    typealias B = MultivariatePolynomial<𝐙, xn>

    func testFiniteVariateIndeterminates() {
        XCTAssertTrue (xy.isFinite)
        XCTAssertEqual(xy.numberOfIndeterminates, 2)
        XCTAssertEqual(xy.degreeOfIndeterminate(at: 0), 1)
        XCTAssertEqual(xy.degreeOfIndeterminate(at: 1), 1)
        XCTAssertEqual(xy.degreeOfMonomial(withExponent: [1, 2]), 3)
        
        XCTAssertEqual(xy.symbolOfIndeterminate(at: 0), "x")
        XCTAssertEqual(xy.symbolOfIndeterminate(at: 1), "y")
        XCTAssertEqual(xy.descriptionOfMonomial(withExponent: [1, 2]), "xy²")
    }
    
    func testInfiniteVariateIndeterminates() {
        XCTAssertFalse(xn.isFinite)
        XCTAssertEqual(xn.degreeOfIndeterminate(at: 0), 1)
        XCTAssertEqual(xn.degreeOfIndeterminate(at: 1), 1)
        XCTAssertEqual(xn.degreeOfIndeterminate(at: 2), 1)
        XCTAssertEqual(xn.degreeOfMonomial(withExponent: [0, 2, 2]), 4)

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
        let a = A(elements: [.zero: 1, [1, 0]: 2, [0, 1]: 1, [2, 1]: 3])
        XCTAssertTrue(!a.isConst)
        XCTAssertEqual(a.constTerm, A(1))
        XCTAssertEqual(a.coeff(1, 0), 2)
        XCTAssertEqual(a.coeff(0, 1), 1)
        XCTAssertEqual(a.coeff(2, 1), 3)
        XCTAssertEqual(a.leadExponent, [2, 1])
    }
    
    func testCoeff() {
        let x = A.indeterminate(0)
        let y = A.indeterminate(1)
        XCTAssertEqual(x.coeff([1, 0]), 1)
        XCTAssertEqual(x.coeff([0, 1]), 0)
        XCTAssertEqual(y.coeff([1, 0]), 0)
        XCTAssertEqual(y.coeff([0, 1]), 1)
    }
    
    func testConstant() {
        let a = A(13)
        let b = A(elements: [[0,0]: 13])
        XCTAssertEqual(a, b)
    }
    
    func testDegree() {
        let a = A(elements: [.zero: 1, [1,2]: 2, [5,2]: 3])
        XCTAssertEqual(a.leadExponent, [5,2])
        XCTAssertEqual(a.degree, 7)
    }
    
    func testHomogeneous() {
        let a = A(elements: [[1, 0]: 1, [0, 1]: 1])
        XCTAssertTrue(a.isHomogeneous)

        let b = A(elements: [[2, 0]: 1, [1, 1]: 1, [0, 2]: 2])
        XCTAssertTrue(b.isHomogeneous)

        let c = A(elements: [[2, 0]: 1, [1, 0]: 1, [0, 0]: 1])
        XCTAssertFalse(c.isHomogeneous)
        
        let d = A(elements: [[2, 0]: 1, [100, 0]: 0])
        XCTAssertTrue(d.isHomogeneous)
    }
    
    func testSum() {
        let a = A(elements: [[0, 0]: 1, [1, 0]: 1, [0, 1]: 1]) // x + y + 1
        let b = A(elements: [[1, 0]: -1, [0, 1]: 2, [1, 1]: 3]) // 3xy - x + 2y
        XCTAssertEqual(a + b, A(elements: [[0, 0]: 1, [0, 1]: 3, [1, 1]: 3]))
    }

    func testZero() {
        let a = A(elements: [[0, 0]: 1, [1, 0]: 1, [0, 1]: 1]) // x + y + 1
        XCTAssertEqual(a + A.zero, a)
        XCTAssertEqual(A.zero + a, a)
    }

    func testNeg() {
        let a = A(elements: [[0, 0]: 1, [1, 0]: 1, [0, 1]: 1])
        XCTAssertEqual(-a, A(elements: [[0, 0]: -1, [1, 0]: -1, [0, 1]: -1]))
    }

    func testMul() {
        let a = A(elements: [[1, 0]: 1, [0, 1]: 1]) // x + y
        let b = A(elements: [[1, 0]: 2, [0, 1]: -1]) // 2x - y
        XCTAssertEqual(a * b, A(elements: [[2, 0]: 2, [1, 1]: 1, [0, 2]: -1]))
    }

    func testId() {
        let a = A(elements: [[0, 0]: 1, [1, 0]: 1, [0, 1]: 1])
        let e = A.identity
        XCTAssertEqual(a * e, a)
        XCTAssertEqual(e * a, a)
    }

    func testInv() {
        let a = A(-1)
        XCTAssertEqual(a.inverse, .some(a))

        let b = A(3)
        XCTAssertNil(b.inverse)

        let c = A(elements: [[0, 0]: 1, [1, 0]: 1, [0, 1]: 1])
        XCTAssertNil(c.inverse)
    }

    func testEvaluate() {
        let a = A(elements: [[0, 0]: 2, [1, 0]: -1, [0, 1]: 2, [1, 1]: 3]) // f(x,y) = 3xy - x + 2y + 2
        XCTAssertEqual(a.evaluate(by: 1, 2), 11)                  // f(1, 2) = 6 - 1 + 4 + 2
    }

    func testMonomialsOfDegree() {
        let mons = A.monomials(ofDegree: 5)
        XCTAssertEqual(mons.count, 6)
        XCTAssertTrue(mons.allSatisfy{ $0.degree == 5 })
    }
    
    func testSymmetricPolynomial() {
        XCTAssertEqual(A.elementarySymmetricPolynomial(ofDegree: 0), A(1))
        XCTAssertEqual(A.elementarySymmetricPolynomial(ofDegree: 1), A(elements: [[1, 0]: 1, [0, 1]: 1]))
        XCTAssertEqual(A.elementarySymmetricPolynomial(ofDegree: 2), A(elements: [[1, 1]: 1]))
        XCTAssertEqual(A.elementarySymmetricPolynomial(ofDegree: 3), .zero)
    }
}
