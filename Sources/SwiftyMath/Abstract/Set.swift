//
//  BasicTypes.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/06/05.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public protocol SetType: Hashable, CustomStringConvertible {
    static var symbol: String { get }
}

public extension SetType {
    static var symbol: String {
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
    var description: String {
        return asSuper.description
    }
}

public extension SetType {
    func asSubset<S: SubsetType>(of: S.Type) -> S where S.Super == Self {
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
    var description: String {
        return "(\(left), \(right))"
    }
    
    static var symbol: String {
        return "\(Left.symbol)×\(Right.symbol)"
    }
}

public struct ProductSet<X: SetType, Y: SetType>: ProductSetType {
    public let left: X
    public let right: Y
    public init(_ x: X, _ y: Y) {
        self.left = x
        self.right = y
    }
}

public protocol QuotientSetType: SetType {
    associatedtype Base: SetType
    init (_ x: Base)
    var representative: Base { get }
    static func isEquivalent(_ x: Base, _ y: Base) -> Bool
}

public extension QuotientSetType {
    var description: String {
        return representative.description
    }
    
    static func == (a: Self, b: Self) -> Bool {
        return isEquivalent(a.representative, b.representative)
    }
    
    static var symbol: String {
        return "\(Base.symbol)/~"
    }
}

public protocol EquivalenceRelation {
    associatedtype Base: SetType
    static func isEquivalent(_ x: Base, _ y: Base) -> Bool
}

public struct QuotientSet<X, E: EquivalenceRelation>: QuotientSetType where X == E.Base {
    public let representative: X
    
    public init(_ x: Base) {
        self.representative = x
    }
    
    public static func isEquivalent(_ x: X, _ y: X) -> Bool {
        return E.isEquivalent(x, y)
    }
}

public protocol MapType: SetType {
    associatedtype Domain: SetType
    associatedtype Codomain: SetType
    init (_ f: @escaping (Domain) -> Codomain)
    func applied(to x: Domain) -> Codomain
}

public extension MapType {
    var description: String {
        return "\(Domain.symbol) -> \(Codomain.symbol)"
    }
    
    static var symbol: String {
        return "Map(\(Domain.symbol), \(Codomain.symbol))"
    }
    
    func hash(into hasher: inout Hasher) {
        fatalError("MapType is not hashable.")
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        fatalError("MapType is not equatable.")
    }

}

public struct Map<X: SetType, Y: SetType>: MapType {
    public typealias Domain = X
    public typealias Codomain = Y
    
    private let f: (X) -> Y
    public init(_ f: @escaping (X) -> Y) {
        self.f = f
    }
    
    public func applied(to x: X) -> Y {
        return f(x)
    }
    
    public func composed<W>(with g: Map<W, X>) -> Map<W, Y> {
        return Map<W, Y>{ x in self.applied( to: g.applied(to: x) ) }
    }
    
    public static func ∘<W>(g: Map<X, Y>, f: Map<W, X>) -> Map<W, Y> {
        return g.composed(with: f)
    }
}

public protocol EndType: MapType where Domain == Codomain {
    static var identity: Self { get }
    func composed(with f: Self) -> Self
    static func ∘(g: Self, f: Self) -> Self
}

public extension EndType {
    static var identity: Self {
        return Self { $0 }
    }
    
    func composed(with g: Self) -> Self {
        return Self { x in self.applied( to: g.applied(to: x) ) }
    }

    static func ∘(g: Self, f: Self) -> Self {
        return g.composed(with: f)
    }
}

extension Map: EndType where X == Y {}
public typealias End<X: SetType> = Map<X, X>
