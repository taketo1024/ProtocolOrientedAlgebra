//
//  BasisElementType.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/12/15.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

// Derived Bases
public struct Dual<A: FreeModuleGenerator>: FreeModuleGenerator {
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

extension FreeModuleGenerator {
    public var dual: Dual<Self> { return Dual(self) }
}

public func pair<A, R>(_ x: FreeModule<A, R>, _ y: FreeModule<Dual<A>, R>) -> R {
    return x.elements.reduce(.zero) { (res, next) -> R in
        let (a, r) = next
        return res + r * y[Dual(a)]
    }
}

public func pair<A, R>(_ x: FreeModule<Dual<A>, R>, _ y: FreeModule<A, R>) -> R {
    return pair(y, x)
}

public struct Tensor<A: FreeModuleGenerator, B: FreeModuleGenerator>: FreeModuleGenerator {
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

public struct FreeTensor<A: FreeModuleGenerator>: FreeModuleGenerator {
    public let factors: [A]
    public init(_ factors: [A]) {
        self.factors = factors
    }
    
    public init(_ factors: A ...) {
        self.init(factors)
    }
    
    public static func generateBasis(from basis: [A], pow n: Int) -> [FreeTensor<A>] {
        return (0 ..< n).reduce([[]]) { (res, _) -> [[A]] in
            res.flatMap{ (factors: [A]) -> [[A]] in
                basis.map{ x in factors + [x] }
            }
        }.map{ factors in FreeTensor(factors) }
    }
    
    public subscript(i: Int) -> A {
        return factors[i]
    }
    
    public var degree: Int {
        return factors.sum { $0.degree }
    }
    
    public static func ⊗(t1: FreeTensor<A>, t2: FreeTensor<A>) -> FreeTensor<A> {
        return FreeTensor(t1.factors + t2.factors)
    }
    
    public static func < (t1: FreeTensor<A>, t2: FreeTensor<A>) -> Bool {
        return t1.factors.lexicographicallyPrecedes(t2.factors)
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
