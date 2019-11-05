public protocol Module: AdditiveGroup {
    associatedtype BaseRing: Ring
    static func * (r: BaseRing, m: Self) -> Self
    static func * (m: Self, r: BaseRing) -> Self
}

extension Module {
    public static func combine<n>(basis: [Self], vector: ColVector<n, BaseRing>) -> Self {
        combine(basis: basis, matrix: vector)[0]
    }

    public static func combine<n, m>(basis: [Self], matrix A: Matrix<n, m, BaseRing>) -> [Self] {
        assert(basis.count == A.size.rows)
        let cols = A.nonZeroComponents.group{ $0.col }
        
        return Array(0 ..< A.size.cols).parallelMap { j in
            guard let col = cols[j] else {
                return .zero
            }
            return col.sum { (i, _, a) in a * basis[i] }
        }
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

public protocol BilinearMapType: MapType, Module
    where Domain: ProductSetType,
    Domain.Left: Module,
    Domain.Right: Module,
    Codomain: Module,
    BaseRing == Domain.Left.BaseRing,
    BaseRing == Domain.Right.BaseRing,
    BaseRing == Codomain.BaseRing {
    
    init(_ f: @escaping (Domain.Left, Domain.Right) -> Codomain)
    func applied(to: (Domain.Left, Domain.Right)) -> Codomain
}

public extension BilinearMapType {
    init(_ f: @escaping (Domain.Left, Domain.Right) -> Codomain) {
        self.init { (v: Domain) in f(v.left, v.right) }
    }
    
    func applied(to v: (Domain.Left, Domain.Right)) -> Codomain {
        return applied(to: Domain(v.0, v.1))
    }
    
    static var zero: Self {
        return Self{ v in .zero }
    }
    
    static func +(f: Self, g: Self) -> Self {
        return Self { v in f.applied(to: v) + g.applied(to: v) }
    }
    
    static prefix func -(f: Self) -> Self {
        return Self { v in -f.applied(to: v) }
    }
    
    static func *(r: BaseRing, f: Self) -> Self {
        return Self { v in r * f.applied(to: v) }
    }
    
    static func *(f: Self, r: BaseRing) -> Self {
        return Self { v in f.applied(to: v) * r }
    }
}

public struct BilinearMap<V1: Module, V2: Module, W: Module>: BilinearMapType where V1.BaseRing == V2.BaseRing, V1.BaseRing == W.BaseRing {
    public typealias BaseRing = V1.BaseRing
    public typealias Domain = ProductModule<V1, V2>
    public typealias Codomain = W
    
    public let function: (ProductModule<V1, V2>) -> W
    public init(_ fnc: @escaping (ProductModule<V1, V2>) -> W) {
        self.function = fnc
    }
    
    public func applied(to v: ProductModule<V1, V2>) -> W {
        return function(v)
    }
}

public protocol BilinearFormType: MapType, Module
    where Domain: ProductSetType,
    Domain.Left: Module,
    Domain.Right: Module,
    Codomain == BaseRing,
    BaseRing == Domain.Left.BaseRing,
    BaseRing == Domain.Right.BaseRing
{
    
    init(_ f: @escaping (Domain.Left, Domain.Right) -> Codomain)
    func applied(to: (Domain.Left, Domain.Right)) -> Codomain
}

public extension BilinearFormType {
    init(_ f: @escaping (Domain.Left, Domain.Right) -> Codomain) {
        self.init { (v: Domain) in f(v.left, v.right) }
    }
    
    func applied(to v: (Domain.Left, Domain.Right)) -> Codomain {
        return applied(to: Domain(v.0, v.1))
    }
    
    static var zero: Self {
        return Self{ v in .zero }
    }
    
    static func +(f: Self, g: Self) -> Self {
        return Self { v in f.applied(to: v) + g.applied(to: v) }
    }
    
    static prefix func -(f: Self) -> Self {
        return Self { v in -f.applied(to: v) }
    }
    
    static func *(r: BaseRing, f: Self) -> Self {
        return Self { v in r * f.applied(to: v) }
    }
    
    static func *(f: Self, r: BaseRing) -> Self {
        return Self { v in f.applied(to: v) * r }
    }
}

public extension BilinearFormType where Domain.Left: FiniteDimVectorSpace, Domain.Right: FiniteDimVectorSpace {
    var asMatrix: DMatrix<BaseRing> {
        typealias V = Domain.Left
        typealias W = Domain.Right
        
        let (n, m) = (V.dim, W.dim)
        let (Vbasis, Wbasis) = (V.standardBasis, W.standardBasis)
        
        return DMatrix(size: (n, m), concurrentIterations: n) { (i, setEntry) in
            let v = Vbasis[i]
            for j in 0 ..< m {
                let w = Wbasis[j]
                let a = self.applied(to: (v, w))
                setEntry(i, j, a)
            }
        }
    }
}

public struct BilinearForm<V1: Module, V2: Module>: BilinearFormType where V1.BaseRing == V2.BaseRing {
    public typealias BaseRing = V1.BaseRing
    public typealias Domain = ProductModule<V1, V2>
    public typealias Codomain = BaseRing
    
    public let function: (Domain) -> Codomain
    public init(_ fnc: @escaping (Domain) -> Codomain) {
        self.function = fnc
    }
    
    public func applied(to v: ProductModule<V1, V2>) -> Codomain {
        return function(v)
    }
}

