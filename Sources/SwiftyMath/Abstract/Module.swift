public protocol Module: AdditiveGroup {
    associatedtype BaseRing: Ring
    static func * (r: BaseRing, m: Self) -> Self
    static func * (m: Self, r: BaseRing) -> Self
}

public func *<M: Module, n, m>(v: [M], A: Matrix<n, m, M.BaseRing>) -> [M] {
    assert(v.count == A.size.rows)
    let cols = A.nonZeroComponents.group{ $0.col }
    
    return (0 ..< A.size.cols).map{ j in
        guard let col = cols[j] else {
            return .zero
        }
        return col.sum { (i, _, a) in a * v[i] }
    }
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

public protocol ProductModuleType: AdditiveProductGroupType, Module where Left: Module, Right: Module, BaseRing == Left.BaseRing, BaseRing == Right.BaseRing {}

public extension ProductModuleType {
    static func * (r: BaseRing, a: Self) -> Self {
        Self(r * a.left, r * a.right)
    }
    
    static func * (a: Self, r: BaseRing) -> Self {
        Self(a.left * r, a.right * r)
    }
}

public struct ProductModule<X: Module, Y: Module>: ProductModuleType where X.BaseRing == Y.BaseRing {
    public typealias BaseRing = X.BaseRing
    
    public let left: X
    public let right: Y
    public init(_ x: X, _ y: Y) {
        self.left = x
        self.right = y
    }
}

public protocol QuotientModuleType: AdditiveQuotientGroupType, Module where BaseRing == Base.BaseRing, Sub:Submodule {}

public extension QuotientModuleType {
    static func * (r: BaseRing, a: Self) -> Self {
        Self(r * a.representative)
    }
    
    static func * (a: Self, r: BaseRing) -> Self {
        Self(a.representative * r)
    }
}

public struct QuotientModule<Base, Sub: Submodule>: QuotientModuleType where Base == Sub.Super {
    public typealias BaseRing = Base.BaseRing
    
    private let x: Base
    public init(_ x: Base) {
        self.x = Sub.quotientRepresentative(of: x)
    }
    
    public var representative: Base {
        x
    }
}

public protocol ModuleHomType: AdditiveGroupHomType, Module where Domain: Module, Codomain: Module, BaseRing == Domain.BaseRing, BaseRing == Codomain.BaseRing {}

public extension ModuleHomType {
    static func *(r: BaseRing, f: Self) -> Self {
        Self { x in r * f.applied(to: x) }
    }
    
    static func *(f: Self, r: BaseRing) -> Self {
        Self { x in f.applied(to: x) * r }
    }
}

public struct ModuleHom<X: Module, Y: Module>: ModuleHomType where X.BaseRing == Y.BaseRing {
    public typealias BaseRing = X.BaseRing
    
    public let function: (X) -> Y
    public init(_ f: @escaping (X) -> Y) {
        self.function = f
    }
}

public protocol ModuleEndType: ModuleHomType, EndType {}

extension ModuleHom: EndType, ModuleEndType where X == Y {}
public typealias ModuleEnd<X: Module> = ModuleHom<X, X>


public typealias Dual<M: Module> = ModuleHom<M, AsModule<M.BaseRing>>

public func pair<M: Module>(x: M, f: Dual<M>) -> M.BaseRing {
    f.applied(to: x).value
}

public func pair<M: Module>(f: Dual<M>, x: M) -> M.BaseRing {
    f.applied(to: x).value
}

