
public protocol Monoid: SetType {
    static func * (a: Self, b: Self) -> Self
    static var identity: Self { get }
    func pow(_ n: 𝐙) -> Self
}

public extension Monoid {
    public func pow(_ n: 𝐙) -> Self {
        assert(n >= 0)
        return (0 ..< n).reduce(.identity){ (res, _) in self * res }
    }
}

public protocol Submonoid: Monoid, SubsetType where Super: Monoid {}

public extension Submonoid {
    static var identity: Self {
        return Self(Super.identity)
    }
    
    public static func * (a: Self, b: Self) -> Self {
        return Self(a.asSuper * b.asSuper)
    }
}

public typealias ProductMonoid<X: Monoid, Y: Monoid> = ProductSet<X, Y>

extension ProductMonoid: Monoid where Left: Monoid, Right: Monoid {
    public static var identity: ProductMonoid<Left, Right> {
        return ProductMonoid(.identity, .identity)
    }
    
    public static func * (a: ProductMonoid<Left, Right>, b: ProductMonoid<Left, Right>) -> ProductMonoid<Left, Right> {
        return ProductMonoid(a.left * b.left, a.right * b.right)
    }
}

// MEMO: Mathematically, we must also require that `MonoidHomType` presereves the Monoid structure.

public protocol MonoidHomType: MapType where Domain: Monoid, Codomain: Monoid {}

public typealias MonoidHom<X: Monoid, Y: Monoid> = Map<X, Y>
extension MonoidHom: MonoidHomType where Domain: Monoid, Codomain: Monoid {}
