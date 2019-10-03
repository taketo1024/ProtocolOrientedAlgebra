public protocol Multiplicative {
    static func * (a: Self, b: Self) -> Self
}

public protocol Monoid: SetType, Multiplicative {
    static var identity: Self { get }
    var isIdentity: Bool { get }
    var inverse: Self? { get }
    var isInvertible: Bool { get }    
}

public extension Monoid {
    var isIdentity: Bool {
        return self == .identity
    }
    
    var isInvertible: Bool {
        inverse != nil
    }
    
    func pow(_ n: Int) -> Self {
        if n >= 0 {
            return (0 ..< n).reduce(.identity){ (res, _) in self * res }
        } else {
            guard let inv = inverse else {
                fatalError()
            }
            return (0 ..< -n).reduce(.identity){ (res, _) in inv * res }
        }
    }
}

public protocol Submonoid: Monoid, SubsetType where Super: Monoid {}

public extension Submonoid {
    static var identity: Self {
        Self(Super.identity)
    }
    
    static func * (a: Self, b: Self) -> Self {
        Self(a.asSuper * b.asSuper)
    }
    
    var inverse: Self? {
        asSuper.inverse.map{ Self($0) }
    }
}

public protocol ProductMonoidType: ProductSetType, Monoid where Left: Monoid, Right: Monoid {}

public extension ProductMonoidType {
    static func * (a: Self, b: Self) -> Self {
        Self(a.left * b.left, a.right * b.right)
    }
    
    static var identity: Self {
        Self(.identity, .identity)
    }
    
    var inverse: Self? {
        if let lInv = left.inverse, let rInv = right.inverse {
            return Self(lInv, rInv)
        } else {
            return nil
        }
    }
}

public struct ProductMonoid<X: Monoid, Y: Monoid>: ProductMonoidType {
    public let left: X
    public let right: Y
    public init(_ x: X, _ y: Y) {
        self.left = x
        self.right = y
    }
}

public protocol MonoidHomType: MapType where Domain: Monoid, Codomain: Monoid {}

public struct MonoidHom<X: Monoid, Y: Monoid>: MonoidHomType {
    public let function: (X) -> Y
    public init(_ f: @escaping (X) -> Y) {
        self.function = f
    }
}

public protocol MonoidEndType: MonoidHomType, EndType {}

extension MonoidHom: EndType, MonoidEndType where X == Y {}

public typealias MonoidEnd<X: Monoid> = MonoidHom<X, X>


public extension Sequence where Element: Monoid {
    func multiplyAll() -> Element {
        multiply{ $0 }
    }
}

public extension Sequence {
    func multiply<G: Monoid>(mapping f: (Element) -> G) -> G {
        self.reduce(.identity){ $0 * f($1) }
    }
}
