import Foundation

public protocol Ring: AdditiveGroup, Monoid, ExpressibleByIntegerLiteral {
    associatedtype IntegerLiteralType = Int
    init(from: 𝐙)
    var inverse: Self? { get }
    var isInvertible: Bool { get }
    var normalizeUnit: Self { get }
    static var isField: Bool { get }
}

public extension Ring {
    // required init from `ExpressibleByIntegerLiteral`
    public init(integerLiteral n: Int) {
        self.init(from: n)
    }

    public var isInvertible: Bool {
        return (inverse != nil)
    }

    public var normalizeUnit: Self {
        return .identity
    }

    public static var zero: Self {
        return Self(from: 0)
    }

    public static var identity: Self {
        return Self(from: 1)
    }

    public static func **(a: Self, n: Int) -> Self {
        return (0 ..< n).reduce(.identity){ (res, _) in res * a }
    }

    public static var isField: Bool {
        return false
    }
}

public protocol Subring: Ring, AdditiveSubgroup, Submonoid where Super: Ring {}

public extension Subring {
    public init(from n: 𝐙) {
        self.init( Super.init(from: n) )
    }

    public var inverse: Self? {
        return asSuper.inverse.flatMap{ Self.init($0) }
    }

    public static var zero: Self {
        return Self.init(from: 0)
    }

    public static var identity: Self {
        return Self.init(from: 1)
    }
}

public protocol Ideal: AdditiveSubgroup where Super: Ring {
    static func * (r: Super, a: Self) -> Self
    static func * (m: Self, r: Super) -> Self

    static func reduced(_ a: Super) -> Super
    static func inverseInQuotient(_ r: Super) -> Super?
}

public extension Ideal {
    public static func * (a: Self, b: Self) -> Self {
        return Self(a.asSuper * b.asSuper)
    }

    public static func * (r: Super, a: Self) -> Self {
        return Self(r * a.asSuper)
    }

    public static func * (a: Self, r: Super) -> Self {
        return Self(a.asSuper * r)
    }
}

public protocol _ProductRing: Ring, AdditiveProductGroup where Left: Ring, Right: Ring {}

public extension _ProductRing {
    public init(from a: 𝐙) {
        self.init(Left(from: a), Right(from: a))
    }

    public var inverse: Self? {
        return _1.inverse.flatMap{ r1 in _2.inverse.flatMap{ r2 in Self(r1, r2) }  }
    }

    public static var zero: Self {
        return Self(Left.zero, Right.zero)
    }
    public static var identity: Self {
        return Self(Left.identity, Right.identity)
    }

    public static func * (a: Self, b: Self) -> Self {
        return Self(a._1 * b._1, a._2 * b._2)
    }
}

public struct ProductRing<R1: Ring, R2: Ring>: _ProductRing {
    public typealias Left = R1
    public typealias Right = R2

    public let _1: R1
    public let _2: R2

    public init(_ r1: R1, _ r2: R2) {
        self._1 = r1
        self._2 = r2
    }
}

public protocol _QuotientRing: Ring, AdditiveQuotientGroup where Sub: Ideal {}

public extension _QuotientRing where Base == Sub.Super {
    public init(from n: 𝐙) {
        self.init(Base(from: n))
    }

    public var inverse: Self? {
        return Sub.inverseInQuotient(representative).map{ Self($0) }
    }

    public static var zero: Self {
        return Self(.zero)
    }

    public static var identity: Self {
        return Self(.identity)
    }

    public static func * (a: Self, b: Self) -> Self {
        return Self(a.representative * b.representative)
    }

    public var hashValue: Int {
        return representative.hashValue // must assure `representative` is unique.
    }
}

public struct QuotientRing<R, I>: _QuotientRing where I: Ideal, R == I.Super {
    public typealias Sub = I

    internal let r: R

    public init(_ r: R) {
        self.r = I.reduced(r)
    }

    public var representative: R {
        return r
    }
}

// TODO merge with QuotientRing after conditional conformance is supported.
public struct QuotientField<R, I>: Field, _QuotientRing where I: Ideal, R == I.Super {
    public typealias Sub = I

    internal let r: R

    public init(_ r: R) {
        self.r = I.reduced(r)
    }

    public var representative: R {
        return r
    }
}
