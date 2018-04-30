//
//  BasicTypes.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/06/05.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public protocol SetType: Hashable, CustomStringConvertible {
    static var symbol: String { get }
}

public extension SetType {
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

public extension SetType {
    public func asSubset<S: SubsetType>(of: S.Type) -> S where S.Super == Self {
        assert(S.contains(self), "\(S.self) does not contain \(self).")
        return S.init(self)
    }
}

public protocol ProductSetType: SetType {
    associatedtype Left: SetType
    associatedtype Right: SetType

    init(_ x: Left, _ y: Right)
    var left:  Left  { get }
    var right: Right { get }
}

public extension ProductSetType {
    public static func == (a: Self, b: Self) -> Bool {
        return (a.left, a.right) == (b.left, b.right)
    }

    public var hashValue: Int {
        return (left.hashValue &* 31) &+ right.hashValue
    }

    public var description: String {
        return "(\(left), \(right))"
    }

    public static var symbol: String {
        return "\(Left.symbol)×\(Right.symbol)"
    }
}

public struct ProductSet<Left: SetType, Right: SetType>: ProductSetType {
    public let left : Left
    public let right: Right

    public init(_ x: Left, _ y: Right) {
        self.left  = x
        self.right = y
    }
}

// MEMO When "parametrized extension" is supported, we could defile:
//
//   struct QuotientSet<X: Base, Rel: EquivalenceRelation>
//
// and extend as subtypes like:
//
//   public typealias QuotientGroup<G, H: NormalSubgroup> = QuotientSet<G, ModSubgroupRelation<H>> where G == H.Super
//   extension<H: NormalSubgroup> QuotientGroup where X == H.Super, Rel == ModSubgroupRelation<H> { ... }
//
// see: https://github.com/apple/swift/blob/master/docs/GenericsManifesto.md#parameterized-extensions

public protocol QuotientSetType: SetType {
    associatedtype Base: SetType
    init (_ x: Base)
    var representative: Base { get }
    static func isEquivalent(_ x: Base, _ y: Base) -> Bool
}

public extension QuotientSetType {
    public var description: String {
        return representative.description
    }

    public static func == (a: Self, b: Self) -> Bool {
        return isEquivalent(a.representative, b.representative)
    }

    public static var symbol: String {
        return "\(Base.symbol)/~"
    }
}
