//
//  FreeModuleBase.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/12/15.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public protocol FreeModuleBase: SetType {
    var degree: Int { get }
}

public extension FreeModuleBase {
    public var degree: Int { return 1 }
}

extension Int:    FreeModuleBase { }
extension String: FreeModuleBase { }

// Derived Bases

public typealias DualFreeModule<A: FreeModuleBase, R: Ring> = FreeModule<Dual<A>, R>

public struct Dual<A: FreeModuleBase>: FreeModuleBase {
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

    public var description: String {
        return "\(base)*"
    }
}

public extension FreeModule {
    public func evaluate(_ f: FreeModule<Dual<A>, R>) -> R {
        return self.reduce(.zero) { (res, next) -> R in
            let (a, r) = next
            return res + r * f[Dual(a)]
        }
    }

    public func evaluate<B>(_ b: FreeModule<B, R>) -> R where A == Dual<B> {
        return b.reduce(.zero) { (res, next) -> R in
            let (a, r) = next
            return res + r * self[Dual(a)]
        }
    }
}

// Direct Sum

public typealias DirectSumFreeModule<A: FreeModuleBase, B: FreeModuleBase, R: Ring> = FreeModule<Sum<A, B>, R>

public enum Sum<A: FreeModuleBase, B: FreeModuleBase>: FreeModuleBase {
    case _1(_: A)
    case _2(_: B)

    public init(_ a: A) { self = ._1(a) }
    public init(_ b: B) { self = ._2(b) }

    public var degree: Int {
        switch self {
        case let ._1(a): return a.degree
        case let ._2(b): return b.degree
        }
    }

    public var hashValue: Int {
        switch self {
        case let ._1(a): return a.hashValue
        case let ._2(b): return b.hashValue
        }
    }

    public static func ==(s1: Sum<A, B>, s2: Sum<A, B>) -> Bool {
        switch (s1, s2) {
        case let (._1(a1), ._1(a2)): return a1 == a2
        case let (._2(b1), ._2(b2)): return b1 == b2
        default: return false
        }
    }

    public var description: String {
        switch self {
        case let ._1(a): return a.description
        case let ._2(b): return b.description
        }
    }
}

public func ⊕<A, B, R>(x: FreeModule<A, R>, y: FreeModule<B, R>) -> DirectSumFreeModule<A, B, R> {
    let elements =
        x.map { (a, r) -> (Sum<A, B>, R) in
            (Sum._1(a), r)
        } + y.map { (b, r) -> (Sum<A, B>, R) in
            (Sum._2(b), r)
        }

    return FreeModule(elements)
}

public func pr1<A, B, R>(_ x: DirectSumFreeModule<A, B, R>) -> FreeModule<A, R> {
    return FreeModule( x.flatMap{ (c, r) -> (A, R)? in
        switch c {
        case let ._1(a): return (a, r)
        default:         return nil
        }
    })
}

public func pr2<A, B, R>(_ x: DirectSumFreeModule<A, B, R>) -> FreeModule<B, R> {
    return FreeModule( x.flatMap{ (c, r) -> (B, R)? in
        switch c {
        case let ._2(b): return (b, r)
        default:         return nil
        }
    })
}

// Tensor Product

public typealias TensorProductFreeModule<A: FreeModuleBase, B: FreeModuleBase, R: Ring> = FreeModule<Tensor<A, B>, R>

public struct Tensor<A: FreeModuleBase, B: FreeModuleBase>: FreeModuleBase {
    public let _1: A
    public let _2: B
    public init(_ a: A, _ b: B) {
        _1 = a
        _2 = b
    }

    public var degree: Int {
        return _1.degree + _2.degree
    }

    public var hashValue: Int {
        return _1.hashValue &* 31 &+ _2.hashValue % 31
    }

    public static func ==(t1: Tensor<A, B>, t2: Tensor<A, B>) -> Bool {
        return t1._1 == t2._1 && t1._2 == t2._2
    }

    public var description: String {
        return "\(_1)⊗\(_2)"
    }
}

public func ⊗<A, B>(a: A, b: B) -> Tensor<A, B> {
    return Tensor(a, b)
}

public func ⊗<A, B, R>(x: FreeModule<A, R>, y: FreeModule<B, R>) -> TensorProductFreeModule<A, B, R> {
    let elements = x.basis.allCombinations(with: y.basis).map{ (a, b) -> (Tensor<A, B>, R) in
        return (a ⊗ b, x[a] * y[b])
    }
    return FreeModule(elements)
}
