//
//  BasisElementType.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/12/15.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public protocol BasisElementType: SetType, Comparable {
    var degree: Int { get }
    var dual: Dual<Self> { get }
}

public extension BasisElementType {
    public var degree: Int { return 1 }

    public var dual: Dual<Self> {
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

    public var hashValue: Int {
        return base.hashValue
    }

    public func pair(_ s: A) -> Int {
        return (base == s) ? 1 : 0
    }

    public static func ==(a: Dual<A>, b: Dual<A>) -> Bool {
        return a.base == b.base
    }

    public static func < (a1: Dual<A>, a2: Dual<A>) -> Bool {
        return a1.base < a2.base
    }

    public var description: String {
        return "\(base)*"
    }
}

public struct Tensor<A: BasisElementType>: BasisElementType {
    public let factors: [A]
    public init(_ factors: [A]) {
        self.factors = factors
    }

    public init(_ factors: A ...) {
        self.init(factors)
    }

    public var degree: Int {
        return factors.sum { $0.degree }
    }

    public static func generateBasis(from basis: [A], pow n: Int) -> [Tensor<A>] {
        return (0 ..< n).reduce([[]]) { (res, _) -> [[A]] in
            res.flatMap{ (factors: [A]) -> [[A]] in
                basis.map{ x in factors + [x] }
            }
        }.map{ factors in Tensor(factors) }
    }

    public static func ⊗(t1: Tensor<A>, t2: Tensor<A>) -> Tensor<A> {
        return Tensor(t1.factors + t2.factors)
    }

    public static func < (t1: Tensor<A>, t2: Tensor<A>) -> Bool {
        return t1.factors.lexicographicallyPrecedes(t2.factors)
    }
    public var description: String {
        return factors.map{ $0.description }.joined(separator: "⊗")
    }

    public var hashValue: Int {
        let p = 31
        return factors.reduce(0){ (res, f) in res &* p &+ f.hashValue }
    }
}
