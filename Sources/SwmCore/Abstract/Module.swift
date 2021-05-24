public protocol Module: AdditiveGroup {
    associatedtype BaseRing: Ring
    static func * (r: BaseRing, a: Self) -> Self
    static func * (a: Self, r: BaseRing) -> Self
}

public protocol Submodule: Module, AdditiveSubgroup where Super: Module {}

public extension Submodule where BaseRing == Super.BaseRing {
    static func * (r: BaseRing, a: Self) -> Self {
        Self(r * a.asSuper)
    }
    
    static func * (a: Self, r: BaseRing) -> Self {
        Self(a.asSuper * r)
    }
}

public protocol ProductModule: AdditiveProductGroup, Module where Left: Module, Right: Module, BaseRing == Left.BaseRing, BaseRing == Right.BaseRing {}

public extension ProductModule {
    static func * (r: BaseRing, a: Self) -> Self {
        Self(r * a.left, r * a.right)
    }
    
    static func * (a: Self, r: BaseRing) -> Self {
        Self(a.left * r, a.right * r)
    }
}

extension Pair: Module, ProductModule where Left: Module, Right: Module, Left.BaseRing == Right.BaseRing {
    public typealias BaseRing = Left.BaseRing
}

public protocol QuotientModule: AdditiveQuotientGroup, Module where BaseRing == Base.BaseRing, Mod:Submodule {}

public extension QuotientModule {
    static func * (r: BaseRing, a: Self) -> Self {
        Self(r * a.representative)
    }
    
    static func * (a: Self, r: BaseRing) -> Self {
        Self(a.representative * r)
    }
}

public protocol ModuleHomType: AdditiveGroupHomType, Module where Domain: Module, Codomain: Module, BaseRing == Domain.BaseRing, BaseRing == Codomain.BaseRing {}

public extension ModuleHomType {
    static func *(r: BaseRing, f: Self) -> Self {
        Self { x in r * f(x) }
    }
    
    static func *(f: Self, r: BaseRing) -> Self {
        Self { x in f(x) * r }
    }
}

extension Map: Module, ModuleHomType where Domain: Module, Codomain: Module, Domain.BaseRing == Codomain.BaseRing {
    public typealias BaseRing = Domain.BaseRing
}

public typealias ModuleHom<X: Module, Y: Module> = Map<X, Y>
public typealias ModuleEnd<X: Module> = ModuleHom<X, X>

public typealias DualModule<M: Module> = ModuleHom<M, AsModule<M.BaseRing>>

public func pair<M: Module>(a: M, f: DualModule<M>) -> M.BaseRing {
    f(a).value
}

public func pair<M: Module>(f: DualModule<M>, a: M) -> M.BaseRing {
    f(a).value
}
