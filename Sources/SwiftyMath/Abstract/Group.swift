public protocol Group: Monoid {}

public protocol Subgroup: Submonoid where Super: Group {}
public protocol NormalSubgroup: Subgroup{}

public protocol ProductGroupType: ProductMonoidType, Group where Left: Group, Right: Group {}

public struct ProductGroup<X: Group, Y: Group>: ProductGroupType {
    public let left: X
    public let right: Y
    public init(_ x: X, _ y: Y) {
        self.left = x
        self.right = y
    }
}

public protocol QuotientGroupType: QuotientSet, Group where Base == Sub.Super {
    associatedtype Sub: NormalSubgroup
}

public extension QuotientGroupType {
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

public struct QuotientGroup<G, H: NormalSubgroup>: QuotientGroupType where G == H.Super {
    public typealias Sub = H
    
    private let g: G
    public init(_ g: G) {
        self.g = g
    }
    
    public var representative: G {
        g
    }
}

public protocol GroupHomType: MonoidHomType where Domain: Group, Codomain: Group {}

public struct GroupHom<X: Group, Y: Group>: GroupHomType {
    public let function: (X) -> Y
    public init(_ f: @escaping (X) -> Y) {
        self.function = f
    }
}

public protocol GroupEndType: GroupHomType, EndType {}

extension GroupHom: EndType, GroupEndType where X == Y {}
public typealias GroupEnd<X: Group> = GroupHom<X, X>
