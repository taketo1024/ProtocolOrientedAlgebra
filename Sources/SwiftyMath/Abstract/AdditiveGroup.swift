import Foundation

public protocol AdditiveGroup: SetType {
    static var zero: Self { get }
    static func + (a: Self, b: Self) -> Self
    prefix static func - (x: Self) -> Self
    static func -(a: Self, b: Self) -> Self
    static func sum(_ elements: [Self]) -> Self
}

public extension AdditiveGroup {
    static func -(a: Self, b: Self) -> Self {
        return (a + (-b))
    }
    
    static func sum(_ elements: [Self]) -> Self {
        return elements.reduce(.zero){ (res, e) in res + e }
    }
}

public protocol AdditiveSubgroup: AdditiveGroup, SubsetType where Super: AdditiveGroup {
    static func normalizedInQuotient(_ a: Super) -> Super
}

public extension AdditiveSubgroup {
    static var zero: Self {
        return Self(Super.zero)
    }
    
    static func + (a: Self, b: Self) -> Self {
        return Self(a.asSuper + b.asSuper)
    }
    
    prefix static func - (a: Self) -> Self {
        return Self(-a.asSuper)
    }
    
    static func normalizedInQuotient(_ a: Super) -> Super {
        return a
    }
}

public protocol AdditiveProductGroupType: ProductSetType, AdditiveGroup where Left: AdditiveGroup, Right: AdditiveGroup {}

public extension AdditiveProductGroupType {
    static var zero: Self {
        return Self(.zero, .zero)
    }
    
    static func + (a: Self, b: Self) -> Self {
        return Self(a.left + b.left, a.right + b.right)
    }
    
    static prefix func - (a: Self) -> Self {
        return Self(-a.left, -a.right)
    }
}

public struct AdditiveProductGroup<X: AdditiveGroup, Y: AdditiveGroup>: AdditiveProductGroupType {
    public let left: X
    public let right: Y
    public init(_ x: X, _ y: Y) {
        self.left = x
        self.right = y
    }
}

public protocol AdditiveQuotientGroupType: QuotientSetType, AdditiveGroup where Base == Sub.Super {
    associatedtype Sub: AdditiveSubgroup
}

public extension AdditiveQuotientGroupType {
    static var zero: Self {
        return Self(Base.zero)
    }
    
    static func + (a: Self, b: Self) -> Self {
        return Self(a.representative + b.representative)
    }
    
    static prefix func - (a: Self) -> Self {
        return Self(-a.representative)
    }
    
    static func isEquivalent(_ a: Base, _ b: Base) -> Bool {
        return Sub.contains( a - b )
    }
    
    static var symbol: String {
        return "\(Base.symbol)/\(Sub.symbol)"
    }
}

public struct AdditiveQuotientGroup<Base, Sub: AdditiveSubgroup>: AdditiveQuotientGroupType where Base == Sub.Super {
    private let x: Base
    public init(_ x: Base) {
        self.x = Sub.normalizedInQuotient(x)
    }
    
    public var representative: Base {
        return x
    }
}

public protocol AdditiveGroupHomType: MapType, AdditiveGroup where Domain: AdditiveGroup, Codomain: AdditiveGroup {}

public extension AdditiveGroupHomType {
    static var zero: Self {
        return Self { x in .zero }
    }
    static func + (f: Self, g: Self) -> Self {
        return Self { x in f.applied(to: x) + g.applied(to: x) }
    }
    
    prefix static func - (f: Self) -> Self {
        return Self { x in -f.applied(to: x) }
    }
    
    static func sum(_ elements: [Self]) -> Self {
        return Self { x in
            elements.map{ f in f.applied(to: x) }.sumAll()
        }
    }
}

public struct AdditiveGroupHom<X: AdditiveGroup, Y: AdditiveGroup>: AdditiveGroupHomType {
    public typealias Domain = X
    public typealias Codomain = Y
    
    private let f: (X) -> Y
    public init(_ f: @escaping (X) -> Y) {
        self.f = f
    }
    
    public func applied(to x: X) -> Y {
        return f(x)
    }
    
    public func composed<W>(with g: AdditiveGroupHom<W, X>) -> AdditiveGroupHom<W, Y> {
        return AdditiveGroupHom<W, Y>{ x in self.applied( to: g.applied(to: x) ) }
    }
    
    public static func ∘<W>(g: AdditiveGroupHom<X, Y>, f: AdditiveGroupHom<W, X>) -> AdditiveGroupHom<W, Y> {
        return g.composed(with: f)
    }
}

public protocol AdditiveGroupEndType: AdditiveGroupHomType, EndType {}

extension AdditiveGroupHom: EndType, AdditiveGroupEndType where X == Y {}
public typealias AdditiveGroupEnd<X: AdditiveGroup> = AdditiveGroupHom<X, X>

public extension Sequence where Element: AdditiveGroup {
    func sumAll() -> Element {
        return sum{ $0 }
    }
}

public extension Sequence {
    func sum<G: AdditiveGroup>(mapping f: (Element) -> G) -> G {
        return G.sum( self.map(f) )
    }
}
