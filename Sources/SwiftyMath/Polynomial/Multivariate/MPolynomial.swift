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
    
    // e.g. [(2, 1, 3) : 5] -> 5 * x^2 * y * z^3
    private let coeffs: [IntList : R]
    
    public init(from n: 𝐙) {
        self.init(R(from: n))
    }
    
    public init(_ a: R) {
        self.init(coeffs: [IntList.empty : a])
    }
    
    public init(coeffs: [IntList : R]) {
        assert(!xn.isFinite || coeffs.keys.allSatisfy{ I in I.length <= xn.numberOfIndeterminates } )
        self.coeffs = coeffs.filter{ $0.value != .zero }
    }
    
    public static var zero: MPolynomial<xn, R> {
        return MPolynomial(coeffs: [:])
    }
    
    public var inverse: MPolynomial<xn, R>? {
        return (isConst) ? constTerm.inverse.map{ inv in MPolynomial(inv) } : nil
    }
    
    internal var multiIndices: [IntList] {
        return coeffs.keys.sorted()
    }
    
    public func coeff(_ I: IntList) -> R {
        return coeffs[I] ?? .zero
    }
    
    public func coeff(_ indices: Int ...) -> R {
        return coeff(IntList(indices))
    }
    
    public var leadCoeff: R {
        return self.coeff(leadDegree)
    }
    
    public var leadDegree: IntList {
        return multiIndices.last ?? .empty // lex-order
    }
    
    public var totalDegree: Int {
        return coeffs.keys.map { I in xn.degree(exponents: I)}.max() ?? 0
    }
    
    public var isConst: Bool {
        return coeffs.isEmpty || (coeffs.count == 1 && coeffs.keys.contains(.empty))
    }
    
    public var constTerm: R {
        return self.coeff(.empty)
    }
    
    public func map(_ f: ((R) -> R)) -> MPolynomial<xn, R> {
        return MPolynomial(coeffs: coeffs.mapValues(f) )
    }
    
    public static func + (f: MPolynomial<xn, R>, g: MPolynomial<xn, R>) -> MPolynomial<xn, R> {
        var coeffs = f.coeffs
        for (I, a) in g.coeffs {
            coeffs[I] = coeffs[I, default: .zero] + a
        }
        return MPolynomial(coeffs: coeffs)
    }
    
    public static prefix func - (f: MPolynomial<xn, R>) -> MPolynomial<xn, R> {
        return f.map { -$0 }
    }
    
    public static func * (f: MPolynomial<xn, R>, g: MPolynomial<xn, R>) -> MPolynomial<xn, R> {
        var coeffs = [IntList : R]()
        for (I, J) in f.multiIndices.allCombinations(with: g.multiIndices) {
            let K = I + J
            coeffs[K] = coeffs[K, default: .zero] + f.coeff(I) * g.coeff(J)
        }
        return MPolynomial(coeffs: coeffs)
    }
    
    public static func * (r: R, f: MPolynomial<xn, R>) -> MPolynomial<xn, R> {
        return f.map { r * $0 }
    }
    
    public static func * (f: MPolynomial<xn, R>, r: R) -> MPolynomial<xn, R> {
        return f.map { $0 * r }
    }
    
    public func evaluate(mapping: (Int) -> R) -> R {
        let indices = coeffs.keys.reduce(into: Set()) { (set: inout Set<Int>, I: IntList) in
            set = set.union( (0 ..< I.length).exclude{i in I[i] == 0} )
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
        
        let mInds = n.choose(i).map { combi -> IntList in
            // e.g.  [0, 1, 3] -> (1, 1, 0, 1)
            let l = combi.last.flatMap{ $0 + 1 } ?? 0
            return IntList( (0 ..< l).map { combi.contains($0) ? 1 : 0 } )
        }
        
        let coeffs = Dictionary(pairs: mInds.map{ ($0, R.identity) } )
        return MPolynomial(coeffs: coeffs)
    }
    
    public var description: String {
        func toTerm(_ I: IntList) -> String {
            return I.enumerated().compactMap { (i, n) -> String? in
                if n > 0 {
                    return (n > 1) ? "\(xn.symbol(i))\(Format.sup(n))" : xn.symbol(i)
                } else {
                    return nil
                }
            }.joined()
        }
        
        let res = multiIndices.reversed().map { i -> String in
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
            return "\(R.symbol)\( (0 ..< n).map{ i in xn.symbol(i) })"
        } else {
            return "\(R.symbol)\( (0 ..< 3).map{ i in xn.symbol(i) } + ["…"])"
        }
    }
}

