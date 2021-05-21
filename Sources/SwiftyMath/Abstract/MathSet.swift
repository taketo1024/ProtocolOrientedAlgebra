//
//  BasicTypes.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/06/05.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public protocol MathSet: Equatable, CustomStringConvertible {}

extension MathSet {
    public func asSubset<S: Subset>(of: S.Type) -> S where S.Super == Self {
        assert(S.contains(self), "\(S.self) does not contain \(self).")
        return S.init(self)
    }
    
    // TODO remove
    public static var symbol: String { "" }
}

public protocol FiniteSet: MathSet {
    static var allElements: [Self] { get }
    static var countElements: Int { get }
}

public protocol Subset: MathSet {
    associatedtype Super: MathSet
    init(_ a: Super)
    var asSuper: Super { get }
    static func contains(_ a: Super) -> Bool
}

extension Subset {
    public var description: String {
        asSuper.description
    }
}

public protocol ProductSet: MathSet {
    associatedtype Left: MathSet
    associatedtype Right: MathSet
    
    init(_ left: Left, _ right: Right)
    var left:  Left  { get }
    var right: Right { get }
}

public extension ProductSet {
    var description: String {
        "(\(left), \(right))"
    }
}

public struct Pair<Left: MathSet, Right: MathSet>: ProductSet {
    public let left: Left
    public let right: Right
    public init(_ left: Left, _ right: Right) {
        self.left = left
        self.right = right
    }
}

public protocol QuotientSet: MathSet {
    associatedtype Base: MathSet
    init (_ a: Base)
    var representative: Base { get }
    static func isEquivalent(_ a: Base, _ b: Base) -> Bool
}

public extension QuotientSet {
    var description: String {
        representative.description
    }
    
    static func == (a: Self, b: Self) -> Bool {
        isEquivalent(a.representative, b.representative)
    }
}

extension QuotientSet where Base: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Base.IntegerLiteralType) {
        self.init(Base(integerLiteral: value))
    }
}

public protocol MapType: MathSet {
    associatedtype Domain: MathSet
    associatedtype Codomain: MathSet
    
    init (_ f: @escaping (Domain) -> Codomain)
    var function: (Domain) -> Codomain { get }
    func callAsFunction(_ x: Domain) -> Codomain
    static func ∘<G: MapType>(g: G, f: Self) -> Map<Self.Domain, G.Codomain> where Self.Codomain == G.Domain
}

public extension MapType {
    init(_ f: Map<Domain, Codomain>) {
        self.init(f.function)
    }
    
    var asMap: Map<Domain, Codomain> {
        Map(function)
    }
    
    func callAsFunction(_ x: Domain) -> Codomain {
        function(x)
    }
    
    static func ∘<G: MapType>(g: G, f: Self) -> Map<Self.Domain, G.Codomain> where Self.Codomain == G.Domain {
        Map<Self.Domain, G.Codomain>{ x in g(f(x)) }
    }
}

public struct Map<Domain: MathSet, Codomain: MathSet>: MapType {
    public let function: (Domain) -> Codomain
    public init(_ f: @escaping (Domain) -> Codomain) {
        self.function = f
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        fatalError("MapType is not equatable.")
    }

    public var description: String {
        "map: \(Domain.self) -> \(Codomain.self)"
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
        Self { x in g(f(x)) }
    }
}

extension Map: EndType where Domain == Codomain{}
public typealias End<Domain: MathSet> = Map<Domain, Domain>
