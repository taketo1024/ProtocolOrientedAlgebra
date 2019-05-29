import Foundation

public protocol Group: Monoid {
    var inverse: Self { get }
}

public extension Group {
    func pow(_ n: 𝐙) -> Self {
        if n >= 0 {
            return (0 ..< n).reduce(.identity){ (res, _) in self * res }
        } else {
            return (0 ..< -n).reduce(.identity){ (res, _) in inverse * res }
        }
    }
}

public protocol Subgroup: Submonoid where Super: Group {}

public extension Subgroup {
    var inverse: Self {
        return Self(self.asSuper.inverse)
    }
}

public protocol NormalSubgroup: Subgroup{}

public protocol ProductGroupType: ProductMonoidType, Group where Left: Group, Right: Group {}
public extension ProductGroupType {
    var inverse: Self {
        return Self(left.inverse, right.inverse)
    }
}

public struct ProductGroup<X: Group, Y: Group>: ProductGroupType {
    public let left: X
    public let right: Y
    public init(_ x: X, _ y: Y) {
        self.left = x
        self.right = y
    }
}

public protocol QuotientGroupType: QuotientSetType, Group where Base == Sub.Super {
    associatedtype Sub: NormalSubgroup
}

public extension QuotientGroupType {
    static func isEquivalent(_ x: Base, _ y: Base) -> Bool {
        return Sub.contains(x * y.inverse)
    }
    
    static var identity: Self {
        return Self(Base.identity)
    }
    
    var inverse: Self {
        return Self(representative.inverse)
    }
    
    static func * (a: Self, b: Self) -> Self {
        return Self(a.representative * b.representative)
    }
    
    static var symbol: String {
        return "\(Base.symbol)/\(Sub.symbol)"
    }
}

public struct QuotientGroup<G, H: NormalSubgroup>: QuotientGroupType where G == H.Super {
    public typealias Sub = H
    
    private let g: G
    public init(_ g: G) {
        self.g = g
    }
    
    public var representative: G {
        return g
    }
}

public protocol GroupHomType: MonoidHomType where Domain: Group, Codomain: Group {}

public struct GroupHom<X: Group, Y: Group>: GroupHomType {
    public typealias Domain = X
    public typealias Codomain = Y
    
    private let f: (X) -> Y
    
    public init(_ f: @escaping (X) -> Y) {
        self.f = f
    }
    
    public func applied(to x: X) -> Y {
        return f(x)
    }
    
    public func composed<W>(with g: GroupHom<W, X>) -> GroupHom<W, Y> {
        return GroupHom<W, Y>{ x in self.applied( to: g.applied(to: x) ) }
    }
    
    public static func ∘<W>(g: GroupHom<X, Y>, f: GroupHom<W, X>) -> GroupHom<W, Y> {
        return g.composed(with: f)
    }
}

public protocol GroupEndType: GroupHomType, EndType {}

extension GroupHom: EndType, GroupEndType where X == Y {
    public static func * (g: GroupHom<X, Y>, f: GroupHom<X, Y>) -> GroupHom<X, Y> {
        return g.composed(with: f)
    }
    
    public static var identity: GroupHom<X, Y> {
        return GroupHom{ $0 }
    }
}

public typealias GroupEnd<X: Group> = GroupHom<X, X>
