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

public protocol ProductModuleType: AdditiveProductGroupType, Module where Left: Module, Right: Module, CoeffRing == Left.CoeffRing, CoeffRing == Right.CoeffRing {}

public extension ProductModuleType {
    static func * (r: CoeffRing, a: Self) -> Self {
        return Self(r * a.left, r * a.right)
    }
    
    static func * (a: Self, r: CoeffRing) -> Self {
        return Self(a.left * r, a.right * r)
    }
}

public struct ProductModule<X: Module, Y: Module>: ProductModuleType where X.CoeffRing == Y.CoeffRing {
    public typealias CoeffRing = X.CoeffRing
    
    public let left: X
    public let right: Y
    public init(_ x: X, _ y: Y) {
        self.left = x
        self.right = y
    }
}

public protocol QuotientModuleType: AdditiveQuotientGroupType, Module where CoeffRing == Base.CoeffRing, Sub:Submodule {}

public extension QuotientModuleType {
    static func * (r: CoeffRing, a: Self) -> Self {
        return Self(r * a.representative)
    }
    
    static func * (a: Self, r: CoeffRing) -> Self {
        return Self(a.representative * r)
    }
}

public struct QuotientModule<Base, Sub: Submodule>: QuotientModuleType where Base == Sub.Super {
    public typealias CoeffRing = Base.CoeffRing
    
    private let x: Base
    public init(_ x: Base) {
        self.x = Sub.normalizedInQuotient(x)
    }
    
    public var representative: Base {
        return x
    }
}

public protocol ModuleHomType: AdditiveGroupHomType, Module where Domain: Module, Codomain: Module, CoeffRing == Domain.CoeffRing, CoeffRing == Codomain.CoeffRing {}

public extension ModuleHomType {
    static func *(r: CoeffRing, f: Self) -> Self {
        return Self { x in r * f.applied(to: x) }
    }
    
    static func *(f: Self, r: CoeffRing) -> Self {
        return Self { x in f.applied(to: x) * r }
    }
}

public struct ModuleHom<X: Module, Y: Module>: ModuleHomType where X.CoeffRing == Y.CoeffRing {
    public typealias CoeffRing = X.CoeffRing
    public typealias Domain = X
    public typealias Codomain = Y
    
    private let f: (X) -> Y
    public init(_ f: @escaping (X) -> Y) {
        self.f = f
    }
    
    public func applied(to x: X) -> Y {
        return f(x)
    }
    
    public func composed<W>(with g: ModuleHom<W, X>) -> ModuleHom<W, Y> {
        return ModuleHom<W, Y>{ x in self.applied( to: g.applied(to: x) ) }
    }
    
    public static func ∘<W>(g: ModuleHom<X, Y>, f: ModuleHom<W, X>) -> ModuleHom<W, Y> {
        return g.composed(with: f)
    }
}

public protocol ModuleEndType: ModuleHomType, EndType {}

extension ModuleHom: EndType, ModuleEndType where X == Y {}
public typealias ModuleEnd<X: Module> = ModuleHom<X, X>


public typealias Dual<M: Module> = ModuleHom<M, AsModule<M.CoeffRing>>

public func pair<M: Module>(x: M, f: Dual<M>) -> M.CoeffRing {
    return f.applied(to: x).value
}

public func pair<M: Module>(f: Dual<M>, x: M) -> M.CoeffRing {
    return f.applied(to: x).value
}

