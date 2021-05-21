public protocol AdditiveGroup: MathSet {
    static var zero: Self { get }
    var isZero: Bool { get }
    
    static func + (a: Self, b: Self) -> Self
    prefix static func - (x: Self) -> Self
    static func -(a: Self, b: Self) -> Self
    static func sum(_ elements: [Self]) -> Self
}

public extension AdditiveGroup {
    var isZero: Bool {
        self == .zero
    }
    
    static func -(a: Self, b: Self) -> Self {
        a + (-b)
    }
    
    static func sum(_ elements: [Self]) -> Self {
        (elements.count == 1)
            ? elements.first!
            : elements.reduce(.zero){ (res, e) in res + e }
    }
}

public protocol AdditiveSubgroup: AdditiveGroup, Subset where Super: AdditiveGroup {
    static func quotientRepresentative(of a: Super) -> Super
}

public extension AdditiveSubgroup {
    static var zero: Self {
        Self(Super.zero)
    }
    
    static func + (a: Self, b: Self) -> Self {
        Self(a.asSuper + b.asSuper)
    }
    
    prefix static func - (a: Self) -> Self {
        Self(-a.asSuper)
    }
    
    static func quotientRepresentative(of a: Super) -> Super {
        a
    }
}

public protocol AdditiveProductGroupType: ProductSet, AdditiveGroup where Left: AdditiveGroup, Right: AdditiveGroup {}

public extension AdditiveProductGroupType {
    static var zero: Self {
        Self(.zero, .zero)
    }
    
    static func + (a: Self, b: Self) -> Self {
        Self(a.left + b.left, a.right + b.right)
    }
    
    static prefix func - (a: Self) -> Self {
        Self(-a.left, -a.right)
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

public protocol AdditiveQuotientGroupType: QuotientSet, AdditiveGroup where Base == Sub.Super {
    associatedtype Sub: AdditiveSubgroup
}

public extension AdditiveQuotientGroupType {
    static var zero: Self {
        Self(Base.zero)
    }
    
    static func + (a: Self, b: Self) -> Self {
        Self(a.representative + b.representative)
    }
    
    static prefix func - (a: Self) -> Self {
        Self(-a.representative)
    }
    
    static func isEquivalent(_ a: Base, _ b: Base) -> Bool {
        Sub.contains( a - b )
    }
    
    static var symbol: String {
        "\(Base.symbol)/\(Sub.symbol)"
    }
}

public struct AdditiveQuotientGroup<Base, Sub: AdditiveSubgroup>: AdditiveQuotientGroupType where Base == Sub.Super {
    private let x: Base
    public init(_ x: Base) {
        self.x = Sub.quotientRepresentative(of: x)
    }
    
    public var representative: Base {
        return x
    }
}

public protocol AdditiveGroupHomType: MapType, AdditiveGroup where Domain: AdditiveGroup, Codomain: AdditiveGroup {}

public extension AdditiveGroupHomType {
    static var zero: Self {
        Self { x in .zero }
    }
    static func + (f: Self, g: Self) -> Self {
        Self { x in f(x) + g(x) }
    }
    
    prefix static func - (f: Self) -> Self {
        Self { x in -f(x) }
    }
    
    static func sum(_ elements: [Self]) -> Self {
        Self { x in
            elements.map{ f in f(x) }.sumAll()
        }
    }
}

public struct AdditiveGroupHom<X: AdditiveGroup, Y: AdditiveGroup>: AdditiveGroupHomType {
    public let function: (X) -> Y
    public init(_ f: @escaping (X) -> Y) {
        self.function = f
    }
}

public protocol AdditiveGroupEndType: AdditiveGroupHomType, EndType {}

extension AdditiveGroupHom: EndType, AdditiveGroupEndType where X == Y {}
public typealias AdditiveGroupEnd<X: AdditiveGroup> = AdditiveGroupHom<X, X>

public extension Sequence where Element: AdditiveGroup {
    func sumAll() -> Element {
        sum{ $0 }
    }
}

public extension Sequence {
    func sum<G: AdditiveGroup>(mapping f: (Element) -> G) -> G {
        G.sum( self.map(f) )
    }
}

public struct AsGroup<G: AdditiveGroup>: Group {
    public let entity: G
    
    public init(_ g: G) {
        self.entity = g
    }

    public var inverse: Self? {
        .init(-entity)
    }

    public static func * (a: Self, b: Self) -> Self {
        .init(a.entity + b.entity)
    }

    public static var identity: Self {
        .init(G.zero)
    }

    public var description: String {
        entity.description
    }

    public static var symbol: String {
        G.symbol
    }
}
