//
//  BasicTypes.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/06/05.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public protocol SetType: Equatable, CustomStringConvertible {
    static var symbol: String { get }
}

public extension SetType {
    static var symbol: String {
        String(describing: self)
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
        asSuper.description
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
        "(\(left), \(right))"
    }
    
    static var symbol: String {
        "\(Left.symbol)×\(Right.symbol)"
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
        representative.description
    }
    
    static func == (a: Self, b: Self) -> Bool {
        isEquivalent(a.representative, b.representative)
    }
    
    static var symbol: String {
        "\(Base.symbol)/~"
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
        E.isEquivalent(x, y)
    }
}

public protocol MapType: SetType {
    associatedtype Domain: SetType
    associatedtype Codomain: SetType
    
    init (_ f: @escaping (Domain) -> Codomain)
    var function: (Domain) -> Codomain { get }
    func applied(to x: Domain) -> Codomain
    static func ∘<G: MapType>(g: G, f: Self) -> Map<Self.Domain, G.Codomain> where Self.Codomain == G.Domain
}

public extension MapType {
    init(_ f: Map<Domain, Codomain>) {
        self.init(f.function)
    }
    
    var asMap: Map<Domain, Codomain> {
        Map(function)
    }
    
    func applied(to x: Domain) -> Codomain {
        function(x)
    }
    
    static func ∘<G: MapType>(g: G, f: Self) -> Map<Self.Domain, G.Codomain> where Self.Codomain == G.Domain {
        Map<Self.Domain, G.Codomain>{ x in g.applied( to: f.applied(to: x) ) }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        fatalError("MapType is not equatable.")
    }

    var description: String {
        "map(\(Domain.symbol) -> \(Codomain.symbol))"
    }
    
    static var symbol: String {
        "Map(\(Domain.symbol) -> \(Codomain.symbol))"
    }
}

public struct Map<X: SetType, Y: SetType>: MapType {
    public let function: (X) -> Y
    public init(_ f: @escaping (X) -> Y) {
        self.function = f
    }
}

public protocol EndType: MapType where Domain == Codomain {
    static var identity: Self { get }
    static func ∘(g: Self, f: Self) -> Self
}

public extension EndType {
    static var identity: Self {
        Self { $0 }
    }
    
    static func ∘(g: Self, f: Self) -> Self {
        Self { x in g.applied(to: f.applied(to: x)) }
    }
}

extension Map: EndType where X == Y {}
public typealias End<X: SetType> = Map<X, X>
