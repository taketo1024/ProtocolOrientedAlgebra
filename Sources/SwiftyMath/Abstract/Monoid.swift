import Foundation

public protocol Monoid: SetType {
    static func * (a: Self, b: Self) -> Self
    static var identity: Self { get }
    func pow(_ n: 𝐙) -> Self
}

public extension Monoid {
    func pow(_ n: 𝐙) -> Self {
        assert(n >= 0)
        return (0 ..< n).reduce(.identity){ (res, _) in self * res }
    }
}

public protocol Submonoid: Monoid, SubsetType where Super: Monoid {}

public extension Submonoid {
    static var identity: Self {
        return Self(Super.identity)
    }
    
    static func * (a: Self, b: Self) -> Self {
        return Self(a.asSuper * b.asSuper)
    }
}

public protocol ProductMonoidType: ProductSetType, Monoid where Left: Monoid, Right: Monoid {
}

public struct ProductMonoid<X: Monoid, Y: Monoid>: ProductMonoidType {
    public let left: X
    public let right: Y
    public init(_ x: X, _ y: Y) {
        self.left = x
        self.right = y
    }
    
    public static var identity: ProductMonoid<X, Y> {
        return ProductMonoid(.identity, .identity)
    }
    
    public static func * (a: ProductMonoid<X, Y>, b: ProductMonoid<X, Y>) -> ProductMonoid<X, Y> {
        return ProductMonoid(a.left * b.left, a.right * b.right)
    }
}

public protocol MonoidHomType: MapType where Domain: Monoid, Codomain: Monoid {}

public struct MonoidHom<X: Monoid, Y: Monoid>: MonoidHomType {
    public typealias Domain = X
    public typealias Codomain = Y
    
    private let f: (X) -> Y
    
    public init(_ f: @escaping (X) -> Y) {
        self.f = f
    }
    
    public func applied(to x: X) -> Y {
        return f(x)
    }
    
    public func composed<W>(with g: MonoidHom<W, X>) -> MonoidHom<W, Y> {
        return MonoidHom<W, Y>{ x in self.applied( to: g.applied(to: x) ) }
    }
    
    public static func ∘<W>(g: MonoidHom<X, Y>, f: MonoidHom<W, X>) -> MonoidHom<W, Y> {
        return g.composed(with: f)
    }
}

public protocol MonoidEndType: MonoidHomType, EndType {
}

extension MonoidHom: Monoid, EndType, MonoidEndType where X == Y {
    public static func * (g: MonoidHom<X, Y>, f: MonoidHom<X, Y>) -> MonoidHom<X, Y> {
        return g.composed(with: f)
    }
    
    public static var identity: MonoidHom<X, Y> {
        return MonoidHom{ $0 }
    }
}

public typealias MonoidEnd<X: Monoid> = MonoidHom<X, X>

public extension Sequence where Element: Monoid {
    func multiplyAll() -> Element {
        return multiply{ $0 }
    }
}

public extension Sequence {
    func multiply<G: Monoid>(mapping f: (Element) -> G) -> G {
        return self.reduce(.identity){ $0 * f($1) }
    }
}
