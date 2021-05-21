public protocol AdditiveGroup: MathSet {
    static var zero: Self { get }
    var isZero: Bool { get }
    
    static func + (a: Self, b: Self) -> Self
    prefix static func -(a: Self) -> Self
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
        switch elements.count {
        case 0: return .zero
        case 1: return elements.first!
        case 2: return elements[0] + elements[1]
        default: return elements.reduce(.zero){ (res, e) in res + e }
        }
    }
}

public protocol AdditiveSubgroup: AdditiveGroup, Subset where Super: AdditiveGroup {
    @available(*, deprecated)
    static func quotientRepresentative(of a: Super) -> Super
}

public extension AdditiveSubgroup {
    static var zero: Self {
        Self(Super.zero)
    }
    
    static func +(a: Self, b: Self) -> Self {
        Self(a.asSuper + b.asSuper)
    }
    
    prefix static func -(a: Self) -> Self {
        Self(-a.asSuper)
    }
    
    static func quotientRepresentative(of a: Super) -> Super {
        a
    }
}

public protocol AdditiveProductGroup: ProductSet, AdditiveGroup where Left: AdditiveGroup, Right: AdditiveGroup {}

public extension AdditiveProductGroup {
    static var zero: Self {
        Self(.zero, .zero)
    }
    
    static func +(a: Self, b: Self) -> Self {
        Self(a.left + b.left, a.right + b.right)
    }
    
    static prefix func -(a: Self) -> Self {
        Self(-a.left, -a.right)
    }
}

extension Pair: AdditiveGroup, AdditiveProductGroup where Left: AdditiveGroup, Right: AdditiveGroup {}

public protocol AdditiveQuotientGroup: QuotientSet, AdditiveGroup where Base == Mod.Super {
    associatedtype Mod: AdditiveSubgroup
}

public extension AdditiveQuotientGroup {
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
        Mod.contains( a - b )
    }
    
    static var symbol: String {
        "\(Base.symbol)/\(Mod.symbol)"
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

extension Map: AdditiveGroup, AdditiveGroupHomType where Domain: AdditiveGroup, Codomain: AdditiveGroup {}
public typealias AdditiveGroupHom<X: AdditiveGroup, Y: AdditiveGroup> = Map<X, Y>
public typealias AdditiveGroupEnd<X: AdditiveGroup> = End<X>

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
