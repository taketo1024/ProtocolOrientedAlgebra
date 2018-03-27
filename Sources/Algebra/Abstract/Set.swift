//
//  BasicTypes.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/06/05.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public protocol SetType: Hashable, CustomStringConvertible {
    var detailDescription: String { get }
    static var symbol: String { get }
}

public extension SetType {
    public func asSubset<S: SubsetType>(of: S.Type) -> S where S.Super == Self {
        assert(S.contains(self), "\(S.self) does not contain \(self).")
        return S.init(self)
    }

    public func asQuotient<Q: QuotientSetType>(in: Q.Type) -> Q where Q.Base == Self {
        return Q.init(self)
    }

    public var detailDescription: String {
        return description
    }

    public static var symbol: String {
        return String(describing: self)
    }
}

public protocol FiniteSetType: SetType {
    static var allElements: [Self] { get }
    static var countElements: Int { get }
}

public protocol SubsetType: SetType {
    associatedtype Super: SetType
    init(_ g: Super)
    var asSuper: Super { get }
    static func contains(_ g: Super) -> Bool
}

public extension SubsetType {
    public static func == (a: Self, b: Self) -> Bool {
        return a.asSuper == b.asSuper
    }

    public var hashValue: Int {
        return asSuper.hashValue
    }

    public var description: String {
        return asSuper.description
    }
}

public protocol ProductSetType: SetType {
    associatedtype Left: SetType
    associatedtype Right: SetType
    var _1: Left  { get }
    var _2: Right { get }
    init(_ a1: Left, _ a2: Right)
}

public extension ProductSetType {
    public static func == (a: Self, b: Self) -> Bool {
        return (a._1 == b._1) && (a._2 == b._2)
    }

    public var hashValue: Int {
        return (_1.hashValue &* 31) &+ _2.hashValue
    }

    public var description: String {
        return "(\(_1), \(_2))"
    }

    public static var symbol: String {
        return "\(Left.symbol)×\(Right.symbol)"
    }
}

public struct ProductSet<S1: SetType, S2: SetType>: ProductSetType {
    public typealias Left = S1
    public typealias Right = S2

    public let _1: S1
    public let _2: S2

    public init(_ s1: S1, _ s2: S2) {
        self._1 = s1
        self._2 = s2
    }
}

public protocol QuotientSetType: SetType {
    associatedtype Base: SetType

    init(_ g: Base)
    var representative: Base { get }
    static func isEquivalent(_ a: Base, _ b: Base) -> Bool
}

public extension QuotientSetType {
    public static func == (a: Self, b: Self) -> Bool {
        return isEquivalent(a.representative, b.representative)
    }

    public var description: String {
        return "\(representative)"
    }

    public static var symbol: String {
        return "\(Base.symbol)/~"
    }
}
