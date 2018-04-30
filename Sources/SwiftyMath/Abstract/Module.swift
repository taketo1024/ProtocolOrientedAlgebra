
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

public typealias ProductModule<X: Module, Y: Module> = AdditiveProductGroup<X, Y>

extension ProductModule: Module where Left: Module, Right: Module, Left.CoeffRing == Right.CoeffRing {
    public typealias CoeffRing = Left.CoeffRing
    
    public static func * (r: CoeffRing, a: ProductModule<Left, Right>) -> ProductModule<Left, Right> {
        return ProductModule(r * a.left, r * a.right)
    }
    
    public static func * (a: ProductModule<Left, Right>, r: CoeffRing) -> ProductModule<Left, Right> {
        return ProductModule(a.left * r, a.right * r)
    }
    
    public static var symbol: String {
        return "\(Left.symbol)⊕\(Right.symbol)"
    }
}

public typealias QuotientModule<M, N: Submodule> = AdditiveQuotientGroup<M, N> where M == N.Super

extension QuotientModule: Module where Sub: Submodule {
    public typealias CoeffRing = Base.CoeffRing
    
    public static func * (r: CoeffRing, a: QuotientModule<Base, Sub>) -> QuotientModule<Base, Sub> {
        return QuotientModule(r * a.representative)
    }
    
    public static func * (a: QuotientModule<Base, Sub>, r: CoeffRing) -> QuotientModule<Base, Sub> {
        return QuotientModule(a.representative * r)
    }
}

public protocol ModuleHomType: AdditiveGroupHomType, Module where Domain: Module, Codomain: Module, Self.CoeffRing == Domain.CoeffRing, Domain.CoeffRing == Codomain.CoeffRing {}

public extension ModuleHomType {
    public static func *(r: CoeffRing, f: Self) -> Self {
        return Self { x in r * f.applied(to: x) }
    }
    
    public static func *(f: Self, r: CoeffRing) -> Self {
        return Self { x in f.applied(to: x) * r }
    }
}

public typealias ModuleHom<X: Module, Y: Module> = AdditiveGroupHom<X, Y> where X.CoeffRing == Y.CoeffRing
extension ModuleHom: Module, ModuleHomType where Domain: Module, Codomain: Module, Domain.CoeffRing == Codomain.CoeffRing {
    public typealias CoeffRing = Domain.CoeffRing
}

// a Ring considered as a Module over itself.
public struct AsModule<R: Ring>: Module {
    public typealias CoeffRing = R
    
    public let value: R
    public init(_ x: R) {
        self.value = x
    }
    
    public static var zero: AsModule<R> {
        return AsModule(.zero)
    }
    
    public static func ==(lhs: AsModule<R>, rhs: AsModule<R>) -> Bool {
        return lhs.value == rhs.value
    }
    
    public static func +(a: AsModule<R>, b: AsModule<R>) -> AsModule<R> {
        return AsModule(a.value + b.value)
    }
    
    public static prefix func -(x: AsModule<R>) -> AsModule<R> {
        return AsModule(-x.value)
    }
    
    public static func *(m: AsModule<R>, r: R) -> AsModule<R> {
        return AsModule(m.value * r)
    }
    
    public static func *(r: R, m: AsModule<R>) -> AsModule<R> {
        return AsModule(r * m.value)
    }
    
    public var hashValue: Int {
        return value.hashValue
    }
    
    public var description: String {
        return value.description
    }
}
