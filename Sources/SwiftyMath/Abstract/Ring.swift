public protocol Ring: AdditiveGroup, Monoid {
    init(from: 𝐙)
    var normalizingUnit: Self { get }
    var normalized: Self { get }
    var isNormalized: Bool { get }
    var degree: Int { get }
    var matrixEliminationWeight: Int { get }
    static var isField: Bool { get }
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
    
    @available(*, deprecated)
    static func quotientInverse(of r: Super) -> Super?
}

// MEMO: Usually Ideals are only used as a TypeParameter for a QuotientRing.
public extension Ideal {
    init(_ x: Super) {
        fatalError()
    }
    
    var asSuper: Super {
        fatalError()
    }
    
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

public protocol ProductRingType: ProductMonoid, AdditiveProductGroup, Ring where Left: Ring, Right: Ring {}

public extension ProductRingType {
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

public struct ProductRing<X: Ring, Y: Ring>: ProductRingType {
    public let left: X
    public let right: Y
    public init(_ x: X, _ y: Y) {
        self.left = x
        self.right = y
    }
}

public protocol QuotientRingType: AdditiveQuotientGroup, Ring where Sub: Ideal {}

public extension QuotientRingType {
    init(from n: 𝐙) {
        self.init(Base(from: n))
    }
    
    var inverse: Self? {
        if let inv = Sub.quotientInverse(of: representative) {
            return Self(inv)
        } else {
            return nil
        }
    }
    
    static var zero: Self {
        Self(Base.zero)
    }
    
    static func + (a: Self, b: Self) -> Self {
        Self(a.representative + b.representative)
    }
    
    static prefix func - (a: Self) -> Self {
        Self(-a.representative)
    }
    
    static func * (a: Self, b: Self) -> Self {
        Self(a.representative * b.representative)
    }
}

public struct QuotientRing<R, I: Ideal>: QuotientRingType where R == I.Super {
    public typealias Sub = I
    
    private let x: R
    public init(_ x: R) {
        self.x = I.quotientRepresentative(of: x)
    }
    
    public var representative: R {
        x
    }
}

extension QuotientRing: EuclideanRing, Field where Sub: MaximalIdeal {}

public protocol RingHomType: AdditiveGroupHomType where Domain: Ring, Codomain: Ring {}

public struct RingHom<X: Ring, Y: Ring>: RingHomType {
    public let function: (X) -> Y
    public init(_ f: @escaping (X) -> Y) {
        self.function = f
    }
}

public protocol RingEndType: RingHomType, EndType {}

extension RingHom: EndType, RingEndType where X == Y {}
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
    
    public static prefix func -(x: Self) -> Self {
        .init(-x.value)
    }
    
    public static func *(m: Self, r: R) -> Self {
        .init(m.value * r)
    }
    
    public static func *(r: R, m: Self) -> Self {
        .init(r * m.value)
    }
    
    public var description: String {
        value.description
    }
}
