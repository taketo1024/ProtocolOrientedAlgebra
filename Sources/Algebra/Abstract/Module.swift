import Foundation

public protocol Module: AdditiveGroup {
    associatedtype CoeffRing: Ring
    static func * (r: CoeffRing, m: Self) -> Self
    static func * (m: Self, r: CoeffRing) -> Self
}

public protocol Submodule: Module, AdditiveSubgroup where Super: Module {}

public extension Submodule where CoeffRing == Super.CoeffRing {
    static func * (r: CoeffRing, a: Self) -> Self {
        return Self(r * a.asSuper)
    }

    static func * (a: Self, r: CoeffRing) -> Self {
        return Self(a.asSuper * r)
    }
}

public protocol _ProductModule: Module, AdditiveProductGroup where Left: Module, Right: Module {}

public extension _ProductModule where Left.CoeffRing == CoeffRing, Right.CoeffRing == CoeffRing {
    static func * (r: CoeffRing, a: Self) -> Self {
        return Self(r * a._1, r * a._2)
    }

    static func * (a: Self, r: CoeffRing) -> Self {
        return Self(a._1 * r, a._2 * r)
    }

    public static var symbol: String {
        return "\(Left.symbol)⊕\(Right.symbol)"
    }
}

public struct ProductModule<M1: Module, M2: Module>: _ProductModule where M1.CoeffRing == M2.CoeffRing {
    public typealias Left = M1
    public typealias Right = M2
    public typealias CoeffRing = M1.CoeffRing

    public let _1: M1
    public let _2: M2

    public init(_ m1: M1, _ m2: M2) {
        self._1 = m1
        self._2 = m2
    }
}

public protocol _QuotientModule: Module, AdditiveQuotientGroup where Sub: Submodule {}

public extension _QuotientModule where Base == Sub.Super, CoeffRing == Sub.CoeffRing, CoeffRing == Sub.Super.CoeffRing {
    public static func isEquivalent(_ a: Base, _ b: Base) -> Bool {
        return Sub.contains( a - b )
    }

    static func * (r: CoeffRing, a: Self) -> Self {
        return Self(r * a.representative)
    }

    static func * (a: Self, r: CoeffRing) -> Self {
        return Self(a.representative * r)
    }

    public var hashValue: Int {
        return representative.hashValue // must assure `representative` is unique.
    }
}

public struct QuotientModule<M, N>: _QuotientModule where N: Submodule, M == N.Super, M.CoeffRing == N.CoeffRing {
    public typealias CoeffRing = M.CoeffRing
    public typealias Sub = N

    internal let m: M

    public init(_ m: M) {
        self.m = m // TODO reduce
    }

    public var representative: M {
        return m
    }
}

public protocol ModuleHom: Map, Module where Domain: Module, Codomain : Module, CoeffRing == Domain.CoeffRing, CoeffRing == Codomain.CoeffRing {}

public extension ModuleHom {
    public static var symbol: String {
        return "Hom_\(CoeffRing.symbol)(\(Domain.symbol), \(Codomain.symbol))"
    }
}
