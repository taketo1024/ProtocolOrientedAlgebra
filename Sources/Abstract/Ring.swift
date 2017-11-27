import Foundation

public protocol Ring: AdditiveGroup, Monoid, ExpressibleByIntegerLiteral {
    associatedtype IntegerLiteralType = IntegerNumber
    init(intValue: IntegerNumber)
    var inverse: Self? { get }
    var isInvertible: Bool { get }
    var normalizeUnit: Self { get }
    static var isField: Bool { get }
}

public extension Ring {
    // required init from `ExpressibleByIntegerLiteral`
    public init(integerLiteral value: IntegerNumber) {
        self.init(intValue: value)
    }

    public var isInvertible: Bool {
        return (inverse != nil)
    }

    public var normalizeUnit: Self {
        return Self.identity
    }

    public static var zero: Self {
        return Self(intValue: 0)
    }

    public static var identity: Self {
        return Self(intValue: 1)
    }

    public static func **(a: Self, n: Int) -> Self {
        return (0 ..< n).reduce(Self.identity){ (res, _) in res * a }
    }

    public static var isField: Bool {
        return false
    }
}

public protocol Subring: Ring, AdditiveSubgroup, Submonoid where Super: Ring {}

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
    public init(intValue a: Int) {
        self.init(Left(intValue: a), Right(intValue: a))
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
    public init(intValue n: Int) {
        self.init(Base(intValue: n))
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
