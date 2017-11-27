import Foundation

public protocol Monoid: SetType {
    static func * (a: Self, b: Self) -> Self
    static var identity: Self { get }
}

public extension Monoid {
    public static func ** (a: Self, b: Int) -> Self {
        return b == 0 ? .identity : a * (a ** (b - 1))
    }
}

public protocol Submonoid: Monoid, SubsetType where Super: Monoid {}

public extension Submonoid {
    static var identity: Self {
        return Self(Super.identity)
    }
    
    public static func * (a: Self, b: Self) -> Self {
        return Self(a.asSuper * b.asSuper)
    }
}

public protocol _ProductMonoid: Monoid, ProductSetType where Left: Monoid, Right: Monoid {}

public extension _ProductMonoid {
    public static var identity: Self {
        return Self(Left.identity, Right.identity)
    }
    
    public static func * (a: Self, b: Self) -> Self {
        return Self(a._1 * b._1, a._2 * b._2)
    }
}

public struct ProductMonoid<M1: Monoid, M2: Monoid>: _ProductMonoid {
    public typealias Left = M1
    public typealias Right = M2
    
    public let _1: M1
    public let _2: M2
    
    public init(_ m1: M1, _ m2: M2) {
        self._1 = m1
        self._2 = m2
    }
}
