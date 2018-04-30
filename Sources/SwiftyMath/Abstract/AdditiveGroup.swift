
public protocol AdditiveGroup: SetType {
    static var zero: Self { get }
    static func + (a: Self, b: Self) -> Self
    prefix static func - (x: Self) -> Self
    static func -(a: Self, b: Self) -> Self
}

public extension AdditiveGroup {
    public static func -(a: Self, b: Self) -> Self {
        return (a + (-b))
    }
}

public protocol AdditiveSubgroup: AdditiveGroup, SubsetType where Super: AdditiveGroup {
    static func normalizedInQuotient(_ a: Super) -> Super
}

public extension AdditiveSubgroup {
    public static var zero: Self {
        return Self(Super.zero)
    }

    public static func + (a: Self, b: Self) -> Self {
        return Self(a.asSuper + b.asSuper)
    }

    prefix static func - (a: Self) -> Self {
        return Self(-a.asSuper)
    }

    public static func normalizedInQuotient(_ a: Super) -> Super {
        return a
    }
}

public typealias AdditiveProductGroup<X: AdditiveGroup, Y: AdditiveGroup> = ProductSet<X, Y>

extension AdditiveProductGroup: AdditiveGroup where Left: AdditiveGroup, Right: AdditiveGroup {
    public static var zero: AdditiveProductGroup<Left, Right> {
        return AdditiveProductGroup(.zero, .zero)
    }

    public static func + (a: AdditiveProductGroup<Left, Right>, b: AdditiveProductGroup<Left, Right>) -> AdditiveProductGroup<Left, Right> {
        return AdditiveProductGroup(a.left + b.left, a.right + b.right)
    }

    public static prefix func - (a: AdditiveProductGroup<Left, Right>) -> AdditiveProductGroup<Left, Right> {
        return AdditiveProductGroup(-a.left, -a.right)
    }
}

public protocol AdditiveQuotientGroupType: QuotientSetType, AdditiveGroup where Base == Sub.Super {
    associatedtype Sub: AdditiveSubgroup
}

public extension AdditiveQuotientGroupType {
    public static var zero: Self {
        return Self(Base.zero)
    }

    public static func + (a: Self, b: Self) -> Self {
        return Self(a.representative + b.representative)
    }

    public static prefix func - (a: Self) -> Self {
        return Self(-a.representative)
    }

    public static func isEquivalent(_ a: Base, _ b: Base) -> Bool {
        return Sub.contains( a - b )
    }

    public static var symbol: String {
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

public struct AsMulGroup<G: AdditiveGroup>: Group {
    private let g: G
    public init(_ g: G) {
        self.g = g
    }

    public var inverse: AsMulGroup<G> {
        return AsMulGroup(-g)
    }

    public static func * (a: AsMulGroup<G>, b: AsMulGroup<G>) -> AsMulGroup<G> {
        return AsMulGroup(a.g + b.g)
    }

    public static var identity: AsMulGroup<G> {
        return AsMulGroup(G.zero)
    }

    public var description: String {
        return g.description
    }

    public static var symbol: String {
        return G.symbol
    }
}

extension AsMulGroup: ExpressibleByIntegerLiteral where G: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = G.IntegerLiteralType
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(G(integerLiteral: value))
    }
}

public protocol AdditiveGroupHomType: MapType, AdditiveGroup where Domain: AdditiveGroup, Codomain: AdditiveGroup {}

public extension AdditiveGroupHomType {
    public static var zero: Self {
        return Self { _ in .zero }
    }

    public static func + (f: Self, g: Self) -> Self {
        return Self { x in f.applied(to: x) + g.applied(to: x) }
    }

    public prefix static func - (f: Self) -> Self {
        return Self { x in -f.applied(to: x) }
    }
}

public typealias AdditiveGroupHom<X: AdditiveGroup, Y: AdditiveGroup> = Map<X, Y>
extension AdditiveGroupHom: AdditiveGroup, AdditiveGroupHomType where Domain: AdditiveGroup, Codomain: AdditiveGroup {}
