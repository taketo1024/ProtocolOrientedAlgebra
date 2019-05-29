//
//  MPolynomial.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/03/10.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public struct MPolynomial<R: Ring>: Ring, Module {
    public typealias CoeffRing = R
    
    // e.g. [(2, 1, 3) : 5] -> 5 * x^2 * y * z^3
    private let coeffs: [IntList : R]
    
    public init(from n: 𝐙) {
        self.init(R(from: n))
    }
    
    public init(_ a: R) {
        self.init([IntList.empty : a])
    }
    
    public init(_ I: IntList) {
        self.init([I : .identity])
    }
    
    public init(_ elements: ([Int], R) ...) {
        let coeffs = Dictionary(pairs: elements.map{ (I, a) in (IntList(I), a) } )
        self.init(coeffs)
    }
    
    public init(_ coeffs: [IntList : R]) {
        self.coeffs = coeffs.filter{ $0.value != .zero }
    }
    
    public static var zero: MPolynomial<R> {
        return MPolynomial([:])
    }
    
    public var inverse: MPolynomial<R>? {
        return (maxDegree == 0) ? coeff(.empty).inverse.flatMap{ a in MPolynomial(a) } : nil
    }
    
    internal var mIndices: [IntList] {
        return coeffs.keys.sorted()
    }
    
    public var numberOfIndeterminates: Int {
        return coeffs.keys.reduce(0){ max($0, $1.length) }
    }
    
    public var maxDegree: Int {
        return coeffs.keys.reduce(0) { max($0, $1.total) }
    }
    
    public func coeff(_ indices: Int ...) -> R {
        return coeff(IntList(indices))
    }
    
    public func coeff(_ I: IntList) -> R {
        return coeffs[I] ?? .zero
    }
    
    public var leadDegree: IntList {
        return mIndices.last ?? .empty
    }
    
    public var leadCoeff: R {
        return self.coeff(leadDegree)
    }
    
    public var constantTerm: R {
        return self.coeff(.empty)
    }
    
    public func map(_ f: ((R) -> R)) -> MPolynomial<R> {
        return MPolynomial( coeffs.mapValues(f) )
    }
    
    public static func + (f: MPolynomial<R>, g: MPolynomial<R>) -> MPolynomial<R> {
        var coeffs = f.coeffs
        for (I, a) in g.coeffs {
            coeffs[I] = coeffs[I, default: .zero] + a
        }
        return MPolynomial(coeffs)
    }
    
    public static prefix func - (f: MPolynomial<R>) -> MPolynomial<R> {
        return f.map { -$0 }
    }
    
    public static func * (f: MPolynomial<R>, g: MPolynomial<R>) -> MPolynomial<R> {
        var coeffs = [IntList : R]()
        for (I, J) in f.mIndices.allCombinations(with: g.mIndices) {
            let K = I + J
            coeffs[K] = coeffs[K, default: .zero] + f.coeff(I) * g.coeff(J)
        }
        return MPolynomial(coeffs)
    }
    
    public static func * (r: R, f: MPolynomial<R>) -> MPolynomial<R> {
        return f.map { r * $0 }
    }
    
    public static func * (f: MPolynomial<R>, r: R) -> MPolynomial<R> {
        return f.map { $0 * r }
    }
    
    public var description: String {
        func toTerm(_ I: IntList) -> String {
            return I.components.enumerated().compactMap { (i, n) -> String? in
                if n > 0 {
                    return (n > 1) ? "x\(Format.sub(i+1))\(Format.sup(n))" : "x\(Format.sub(i+1))"
                } else {
                    return nil
                }
            }.joined()
        }
        
        let res = mIndices.reversed().map { i -> String in
            let a = self.coeff(i)
            let x = toTerm(i)
            switch a {
            case  .identity: return x
            case -.identity: return "-\(x)"
            default: return "\(a)\(x)"
            }
        }.joined(separator: " + ")
        
        return res.isEmpty ? "0" : res
    }
    
    public static var symbol: String {
        return "\(R.symbol)[x₁ … ]"
    }
}

