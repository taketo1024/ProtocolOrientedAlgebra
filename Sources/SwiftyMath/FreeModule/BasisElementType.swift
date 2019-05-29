//
//  BasisElementType.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/12/15.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public protocol BasisElementType: SetType, Comparable {
    var degree: Int { get }
    var dual: Dual<Self> { get }
}

public extension BasisElementType {
    var degree: Int { return 1 }
    
    var dual: Dual<Self> {
        return Dual(self)
    }
}

// Derived Bases
public struct Dual<A: BasisElementType>: BasisElementType {
    public let base: A
    public init(_ a: A) {
        base = a
    }
    
    public var degree: Int {
        return base.degree
    }
    
    public func pair(_ s: A) -> Int {
        return (base == s) ? 1 : 0
    }
    
    public static func < (a1: Dual<A>, a2: Dual<A>) -> Bool {
        return a1.base < a2.base
    }
    
    public var description: String {
        return "\(base)*"
    }
}

public struct Tensor<A: BasisElementType, B: BasisElementType>: BasisElementType {
    private let a: A
    private let b: B
    
    public init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }
    
    public var left:  A { return a }
    public var right: B { return b }
    public var factors: (A, B) { return (a, b) }
    
    public static func < (t1: Tensor<A, B>, t2: Tensor<A, B>) -> Bool {
        return t1.a < t2.a || t1.a == t2.a && t1.b < t2.b
    }
    
    public var description: String {
        return "\(a)⊗\(b)"
    }
}

public struct FreeTensor<A: BasisElementType>: BasisElementType {
    public let factors: [A]
    public init(_ factors: [A]) {
        self.factors = factors
    }
    
    public init(_ factors: A ...) {
        self.init(factors)
    }
    
    public subscript(i: Int) -> A {
        return factors[i]
    }
    
    public var degree: Int {
        return factors.sum { $0.degree }
    }
    
    public static var identity: FreeTensor<A> {
        return FreeTensor()
    }
    
    public typealias   Product<R: Ring> = FreeModuleHom<Tensor<A, A>, A, R>
    public typealias Coproduct<R: Ring> = FreeModuleHom<A, Tensor<A, A>, R>
    
    public func applied<R: Ring>(_ m: Product<R>, at: (Int, Int), to j: Int) -> FreeModule<FreeTensor<A>, R> {
        let (i1, i2) = at
        let (e1, e2) = (self[i1], self[i2])
        let res = m.applied(to: Tensor(e1, e2))
        
        return res.elements.sum { (e, a) in
            var factors = self.factors
            factors.remove(at: i2)
            factors.remove(at: i1)
            factors.insert(e, at: j)
            return a * .wrap(FreeTensor(factors))
        }
    }
    
    public func applied<R: Ring>(_ c: Coproduct<R>, at i: Int, to: (Int, Int)) -> FreeModule<FreeTensor<A>, R> {
        let (j1, j2) = to
        let e = self[i]
        let res = c.applied(to: e)
        
        return res.elements.sum { (t, a)  in
            let (e1, e2) = t.factors
            var factors = self.factors
            factors.remove(at: i)
            factors.insert(e1, at: j1)
            factors.insert(e2, at: j2)
            return a * .wrap(FreeTensor(factors))
        }
    }
    
    public func mapFactors<R>(_ f: (A) -> [(A, R)]) -> FreeModule<FreeTensor<A>, R> {
        let all = factors.reduce([([], .identity)]) { (res, e) -> [([A], R)] in
            f(e).flatMap{ (e, r) in
                res.map{ (factors, r0) in (factors + [e], r0 * r) }
            }
        }
        return all.sum{ (factors, r) in
            return r * .wrap(FreeTensor(factors))
        }
    }
    
    public static func ⊗(t1: FreeTensor<A>, t2: FreeTensor<A>) -> FreeTensor<A> {
        return FreeTensor(t1.factors + t2.factors)
    }
    
    public static func < (t1: FreeTensor<A>, t2: FreeTensor<A>) -> Bool {
        return t1.factors.lexicographicallyPrecedes(t2.factors)
    }
    
    public static func generateBasis(from basis: [A], pow n: Int) -> [FreeTensor<A>] {
        return (0 ..< n).reduce([[]]) { (res, _) -> [[A]] in
            res.flatMap{ (factors: [A]) -> [[A]] in
                basis.map{ x in factors + [x] }
            }
            }.map{ factors in FreeTensor(factors) }
    }
    
    public var description: String {
        return factors.map{ $0.description }.joined(separator: "⊗")
    }
}

public func ⊗<A, R>(x1: FreeModule<FreeTensor<A>, R>, x2: FreeModule<FreeTensor<A>, R>) -> FreeModule<FreeTensor<A>, R> {
    return x1.elements.sum { (t1, r1) in
        x2.elements.sum { (t2, r2) in
            let r = r1 * r2
            let t = t1 ⊗ t2
            return r * .wrap(t)
        }
    }
}

extension FreeTensor: Codable where A: Codable {}
