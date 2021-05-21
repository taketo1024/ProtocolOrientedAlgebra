public protocol Ring: AdditiveGroup, Monoid {
    init(from: 𝐙)
    var isNormalized: Bool { get }
    var normalizingUnit: Self { get }
    var normalized: Self { get }
    var degree: Int { get }
    static var isField: Bool { get }
    var matrixEliminationWeight: Int { get } // used for matrix elimination
}

public extension Ring {
    static var zero: Self {
        Self(from: 0)
    }
    
    static var identity: Self {
        Self(from: 1)
    }
    
    var normalizingUnit: Self {
        .identity
    }
    
    var normalized: Self {
        normalizingUnit * self
    }
    
    var isNormalized: Bool {
        normalizingUnit.isIdentity
    }
    
    var degree: Int {
        0
    }
    
    var matrixEliminationWeight: Int {
        isZero ? 0 : 1
    }
    
    static var isField: Bool {
        false
    }
}

public protocol Subring: Ring, AdditiveSubgroup, Submonoid where Super: Ring {}

public extension Subring {
    init(from n: 𝐙) {
        self.init( Super.init(from: n) )
    }

    static var zero: Self {
        Self.init(from: 0)
    }
    
    static var identity: Self {
        Self.init(from: 1)
    }
}

public protocol Ideal: AdditiveSubgroup where Super: Ring {
    static func * (r: Super, a: Self) -> Self
    static func * (m: Self, r: Super) -> Self
}

public extension Ideal {
    // suppressed
    init(_ a: Super) { fatalError() }
    var asSuper: Super { .zero }

    static func * (a: Self, b: Self) -> Self {
        Self(a.asSuper * b.asSuper)
    }
    
    static func * (r: Super, a: Self) -> Self {
        Self(r * a.asSuper)
    }
    
    static func * (a: Self, r: Super) -> Self {
        Self(a.asSuper * r)
    }
}

public protocol MaximalIdeal: Ideal {}

public protocol ProductRing: ProductMonoid, AdditiveProductGroup, Ring where Left: Ring, Right: Ring {}

public extension ProductRing {
    init(from a: 𝐙) {
        self.init(Left(from: a), Right(from: a))
    }
    
    static var zero: Self {
        .init(from: 0)
    }
    
    static var identity: Self {
        .init(from: 1)
    }
}

extension Pair: Ring, ProductRing where Left: Ring, Right: Ring {}

public protocol QuotientRing: AdditiveQuotientGroup, Ring where Mod: Ideal {}

public extension QuotientRing {
    init(from n: 𝐙) {
        self.init(Base(from: n))
    }
    
    static var zero: Self {
        Self(Base.zero)
    }
    
    static func +(a: Self, b: Self) -> Self {
        Self(a.representative + b.representative)
    }
    
    static prefix func -(a: Self) -> Self {
        Self(-a.representative)
    }
    
    static func *(a: Self, b: Self) -> Self {
        Self(a.representative * b.representative)
    }
}

public protocol RingHomType: AdditiveGroupHomType where Domain: Ring, Codomain: Ring {}

extension Map: RingHomType where Domain: Ring, Codomain: Ring {}
public typealias RingHom<X: Ring, Y: Ring> = Map<X, Y>
public typealias RingEnd<X: Ring> = RingHom<X, X>

// a Ring considered as a Module over itself.
public struct AsModule<R: Ring>: Module {
    public typealias BaseRing = R
    
    public let value: R
    public init(_ x: R) {
        self.value = x
    }
    
    public static func wrap(_ r: R) -> Self {
        .init(r)
    }
    
    public static var zero: Self {
        .init(.zero)
    }
    
    public static func +(a: Self, b: Self) -> Self {
        .init(a.value + b.value)
    }
    
    public static prefix func -(a: Self) -> Self {
        .init(-a.value)
    }
    
    public static func *(a: Self, r: R) -> Self {
        .init(a.value * r)
    }
    
    public static func *(r: R, a: Self) -> Self {
        .init(r * a.value)
    }
    
    public var description: String {
        value.description
    }
}
