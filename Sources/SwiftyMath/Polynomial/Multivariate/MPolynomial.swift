//
//  MPolynomial.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/03/10.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public typealias  xyPolynomial<R: Ring> = MPolynomial<_xy , R>
public typealias xyzPolynomial<R: Ring> = MPolynomial<_xyz, R>
public typealias  xnPolynomial<R: Ring> = MPolynomial<_xn,  R>

public struct MPolynomial<xn: MPolynomialIndeterminate, R: Ring>: Ring, Module {
    public typealias CoeffRing = R
    public typealias MultiDegree = [Int]
    
    // e.g. [[2, 1, 3] : 5] -> 5 * x^2 * y * z^3
    private let coeffs: [MultiDegree : R]
    
    public init(from n: 𝐙) {
        self.init(R(from: n))
    }
    
    public init(_ a: R) {
        self.init(coeffs: [MultiDegree.empty : a])
    }
    
    public init(coeffs: [MultiDegree : R]) {
        assert(!xn.isFinite || coeffs.keys.allSatisfy{ I in I.count <= xn.numberOfIndeterminates } )
        self.coeffs = coeffs.filter{ $0.value != .zero }.mapKeys{ $0.droppedLast{ $0 == 0 } }
    }
    
    public static var zero: MPolynomial<xn, R> {
        MPolynomial(coeffs: [:])
    }
    
    public var inverse: MPolynomial<xn, R>? {
        (isConst) ? constTerm.inverse.map{ inv in MPolynomial(inv) } : nil
    }
    
    internal var multiDegrees: [MultiDegree] {
        coeffs.keys.sorted()
    }
    
    public var degree: Int {
        coeffs.keys.map { I in xn.totalDegree(exponents: I)}.max() ?? 0
    }
    
    public func coeff(_ I: MultiDegree) -> R {
        coeffs[I] ?? .zero
    }
    
    public func coeff(_ indices: Int ...) -> R {
        coeff(MultiDegree(indices))
    }
    
    public var isMonomial: Bool {
        coeffs.count <= 1
    }
    
    public var isMonic: Bool {
        leadCoeff == .identity
    }
    
    public var isConst: Bool {
        coeffs.isEmpty || (coeffs.count == 1 && coeffs.keys.contains(.empty))
    }
    
    public var constTerm: R {
        self.coeff(.empty)
    }
    
    public var leadCoeff: R {
        self.coeff(leadMultiDegree)
    }
    
    public var leadMultiDegree: MultiDegree {
        multiDegrees.last ?? .empty // lex-order
    }
    
    public var leadTerm: MPolynomial<xn, R> {
        MPolynomial(coeffs: [leadMultiDegree : leadCoeff])
    }
    
    public func map(_ f: ((R) -> R)) -> MPolynomial<xn, R> {
        MPolynomial(coeffs: coeffs.mapValues(f) )
    }
    
    // decompose into pairs of (multidegree, coeff)
    public func decomposed() -> [(MultiDegree, R)] {
        coeffs.map{ (I, a) in (I, a) }
    }

    public static func indeterminate(_ i: Int) -> MPolynomial {
        .init(coeffs: [[0].repeated(i) + [1] : R.identity] )
    }
    
    public static func monomial(ofMultiDegree I: MultiDegree) -> MPolynomial<xn, R> {
        .init(coeffs: [I: .identity])
    }
    
    public static func monomials(ofDegree degree: Int) -> [MPolynomial<xn, R>] {
        assert(xn.isFinite)
        return monomials(ofDegree: degree, usingIndeterminates: (0 ..< xn.numberOfIndeterminates).toArray())
    }
    
    public static func monomials(ofDegree degree: Int, usingIndeterminates indices: [Int]) -> [MPolynomial<xn, R>] {
        assert(indices.allSatisfy{ i in xn.degree(i) != 0 })
        
        func multiDegs(_ degree: Int, _ index: Int) -> [[Int]] {
            guard index >= 0 else {
                return (degree == 0) ? [[]] : []
            }
            
            let d = xn.degree(indices[index])
            let m = degree.abs / d.abs // max exponent of x_i
            return (0 ... m).flatMap { c -> [[Int]] in
                multiDegs(degree - c * d, index - 1).map{ $0.appended(c) }
            }
        }
        
        let last = indices.count - 1
        return multiDegs(degree, last).map{ I in .monomial(ofMultiDegree: I) }
    }
    
    public static func + (f: MPolynomial<xn, R>, g: MPolynomial<xn, R>) -> MPolynomial<xn, R> {
        var coeffs = f.coeffs
        for (I, a) in g.coeffs {
            coeffs[I] = coeffs[I, default: .zero] + a
        }
        return MPolynomial(coeffs: coeffs)
    }
    
    public static prefix func - (f: MPolynomial<xn, R>) -> MPolynomial<xn, R> {
        f.map { -$0 }
    }
    
    public static func * (f: MPolynomial<xn, R>, g: MPolynomial<xn, R>) -> MPolynomial<xn, R> {
        var coeffs = [MultiDegree : R]()
        for (I, J) in (f.multiDegrees * g.multiDegrees) {
            let K = I.merging(J, with: +)
            coeffs[K] = coeffs[K, default: .zero] + f.coeff(I) * g.coeff(J)
        }
        return MPolynomial(coeffs: coeffs)
    }
    
    public static func * (r: R, f: MPolynomial<xn, R>) -> MPolynomial<xn, R> {
        f.map { r * $0 }
    }
    
    public static func * (f: MPolynomial<xn, R>, r: R) -> MPolynomial<xn, R> {
        f.map { $0 * r }
    }
    
    public static func sum(_ elements: [MPolynomial]) -> MPolynomial {
        if elements.count == 1 {
            return elements.first!
        } else {
            let sum = elements.reduce(into: [:]) { (res: inout [MultiDegree : R], x) in
                res.merge(x.coeffs) { (r1, r2) in r1 + r2 }
            }
            return MPolynomial(coeffs: sum)
        }
    }
    
    public func evaluate(at values: [R]) -> R {
        assert(xn.isFinite && values.count == xn.numberOfIndeterminates)
        return evaluate{ i in values[i] }
    }
    
    public func evaluate(at values: R...) -> R {
        evaluate(at: values)
    }
    
    public func evaluate(mapping: (Int) -> R) -> R {
        let indices = coeffs.keys.reduce(into: Set()) { (set: inout Set<Int>, I: MultiDegree) in
            set = set.union( (0 ..< I.count).exclude{i in I[i] == 0} )
        }
        let dict = Dictionary(keys: indices) { i in mapping(i) }
        return coeffs.sum{ (I, a) in a * I.enumerated().multiply{ (i, k) in dict[i]!.pow(k) } }
    }
    
    // see: https://en.wikipedia.org/wiki/Symmetric_polynomial#Elementary_symmetric_polynomials
    public static func elementarySymmetric(_ i: Int) -> MPolynomial<xn, R> {
        assert(xn.isFinite)
        
        let n = xn.numberOfIndeterminates
        if i > n {
            return .zero
        }
        
        let mInds = n.choose(i).map { combi -> MultiDegree in
            // e.g.  [0, 1, 3] -> (1, 1, 0, 1)
            let l = combi.last.flatMap{ $0 + 1 } ?? 0
            return MultiDegree( (0 ..< l).map { combi.contains($0) ? 1 : 0 } )
        }
        
        let coeffs = Dictionary(pairs: mInds.map{ ($0, R.identity) } )
        return MPolynomial(coeffs: coeffs)
    }
    
    public var description: String {
        func toTerm(_ I: MultiDegree) -> String {
            return I.enumerated().compactMap { (i, n) -> String? in
                if n > 0 {
                    return (n > 1) ? "\(xn.symbol(i))\(Format.sup(n))" : xn.symbol(i)
                } else {
                    return nil
                }
            }.joined()
        }
        
        let res = multiDegrees.reversed().map { i -> String in
            let a = self.coeff(i)
            let x = toTerm(i)
            switch (a, x) {
            case (_, ""): return "\(a)"
            case ( .identity, _): return x
            case (-.identity, _): return "-\(x)"
            default: return "\(a)\(x)"
            }
        }.joined(separator: " + ")
        
        return res.isEmpty ? "0" : res
    }
    
    public static var symbol: String {
        if xn.isFinite {
            let n = xn.numberOfIndeterminates
            return "\(R.symbol)[\( (0 ..< n).map{ i in xn.symbol(i) }.joined(separator: ", "))]"
        } else {
            return "\(R.symbol)[\( (0 ..< 3).map{ i in xn.symbol(i) }.appended("…").joined(separator: ", "))]"
        }
    }
}

