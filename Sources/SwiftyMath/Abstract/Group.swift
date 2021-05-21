public protocol Group: Monoid {}
public protocol Subgroup: Submonoid where Super: Group {}
public protocol NormalSubgroup: Subgroup{}

public protocol ProductGroup: ProductMonoid, Group where Left: Group, Right: Group {}
extension Pair: Group, ProductGroup where Left: Group, Right: Group {}

public protocol QuotientGroup: QuotientSet, Group where Base == Sub.Super {
    associatedtype Sub: NormalSubgroup
}

public extension QuotientGroup {
    static func isEquivalent(_ x: Base, _ y: Base) -> Bool {
        Sub.contains(x * y.inverse!)
    }
    
    static var identity: Self {
        Self(Base.identity)
    }
    
    var inverse: Self? {
        Self(representative.inverse!)
    }
    
    static func * (a: Self, b: Self) -> Self {
        Self(a.representative * b.representative)
    }
    
    static var symbol: String {
        "\(Base.symbol)/\(Sub.symbol)"
    }
}

public protocol GroupHomType: MonoidHomType where Domain: Group, Codomain: Group {}
extension Map: GroupHomType where Domain: Group, Codomain: Group {}

public typealias GroupHom<X: Group, Y: Group> = Map<X, Y>
public typealias GroupEnd<X: Group> = GroupHom<X, X>
