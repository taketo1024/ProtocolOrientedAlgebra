import Foundation

public protocol FreeModuleBase: SetType {
    var degree: Int { get }
}

public extension FreeModuleBase {
    public var degree: Int { return 1 }
}

public struct FreeModule<A: FreeModuleBase, R: Ring>: Module, Sequence {
    public typealias CoeffRing = R
    public typealias Basis = [A]
    
    internal let elements: [A: R]
    
    // root initializer
    public init(_ elements: [A : R]) {
        self.elements = elements.filter{ $0.value != 0 }
    }
    
    public init<S: Sequence>(_ elements: S) where S.Element == (A, R) {
        let dict = Dictionary(pairs: elements)
        self.init(dict)
    }
    
    public init(basis: Basis, components: [R]) {
        assert(basis.count == components.count)
        self.init(Dictionary(pairs: zip(basis, components)))
    }
    
    public init<n>(basis: Basis, vector: ColVector<n, R>) {
        assert(basis.count == vector.rows)
        self.init(Dictionary(pairs: zip(basis, vector.grid)))
    }
    
    // generates a basis element
    public init(_ a: A) {
        self.init([(a, 1)])
    }
    
    public subscript(a: A) -> R {
        return elements[a] ?? .zero
    }
    
    public var basis: Basis {
        return elements.keys.toArray()
    }
    
    public func factorize(by list: Basis) -> [R] {
        return list.map{ self[$0] }
    }
    
    public static var zero: FreeModule<A, R> {
        return FreeModule([])
    }
    
    public func mapValues<R2: Ring>(_ f: (R) -> R2) -> FreeModule<A, R2> {
        return FreeModule<A, R2>(elements.mapValues(f))
    }
    
    public func makeIterator() -> AnyIterator<(A, R)> {
        return AnyIterator(elements.lazy.map{ (a, r) in (a, r) }.makeIterator())
    }
    
    public static func == (a: FreeModule<A, R>, b: FreeModule<A, R>) -> Bool {
        return a.elements == b.elements
    }
    
    public static func + (a: FreeModule<A, R>, b: FreeModule<A, R>) -> FreeModule<A, R> {
        var d: [A : R] = a.elements
        for (a, r) in b {
            d[a] = d[a, default: .zero] + r
        }
        return FreeModule<A, R>(d)
    }
    
    public static prefix func - (a: FreeModule<A, R>) -> FreeModule<A, R> {
        return FreeModule<A, R>(a.elements.mapValues{ -$0 })
    }
    
    public static func * (r: R, a: FreeModule<A, R>) -> FreeModule<A, R> {
        return FreeModule<A, R>(a.elements.mapValues{ r * $0 })
    }
    
    public static func * (a: FreeModule<A, R>, r: R) -> FreeModule<A, R> {
        return FreeModule<A, R>(a.elements.mapValues{ $0 * r })
    }
    
    public var description: String {
        let sum: String = self.filter{ (_, r) in r != .zero }
            .map { (a, r) in (r == R.identity) ? "\(a)" : "\(r)\(a)" }
            .joined(separator: " + ")
        
        return sum.isEmpty ? "0" : sum
    }
    
    public static var symbol: String {
        return "FreeMod(\(R.symbol))"
    }
    
    public var hashValue: Int {
        return (self == FreeModule.zero) ? 0 : 1
    }
}

public struct FreeZeroModule<A: FreeModuleBase, R: Ring>: Submodule {
    public typealias Super = FreeModule<A, R>
    public typealias CoeffRing = R
    
    public init(_ m: Super) {}
    
    public var asSuper: Super {
        return Super.zero
    }
    
    public static func contains(_ g: FreeModule<A, R>) -> Bool {
        return g == Super.zero
    }
    
    public static var symbol: String {
        return "{0}"
    }
}

public struct Dual<A: FreeModuleBase>: FreeModuleBase {
    public let base: A
    public init(_ a: A) {
        base = a
    }
    
    public var degree: Int {
        return base.degree
    }
    
    public var hashValue: Int {
        return base.hashValue
    }
    
    public func pair(_ s: A) -> Int {
        return (base == s) ? 1 : 0
    }
    
    public static func ==(a: Dual<A>, b: Dual<A>) -> Bool {
        return a.base == b.base
    }
    
    public var description: String {
        return "\(base)*"
    }
}

public extension FreeModule {
    public func evaluate(_ f: FreeModule<Dual<A>, R>) -> R {
        return self.reduce(.zero) { (res, next) -> R in
            let (a, r) = next
            return res + r * f[Dual(a)]
        }
    }
    
    public func evaluate<B>(_ b: FreeModule<B, R>) -> R where A == Dual<B> {
        return b.reduce(.zero) { (res, next) -> R in
            let (a, r) = next
            return res + r * self[Dual(a)]
        }
    }
}

public struct Tensor<A: FreeModuleBase, B: FreeModuleBase>: FreeModuleBase {
    public let _1: A
    public let _2: B
    public init(_ a: A, _ b: B) {
        _1 = a
        _2 = b
    }
    
    public var degree: Int {
        return _1.degree + _2.degree
    }
    
    public var hashValue: Int {
        return _1.hashValue &* 31 &+ _2.hashValue % 31
    }
    
    public static func ==(t1: Tensor<A, B>, t2: Tensor<A, B>) -> Bool {
        return t1._1 == t2._1 && t1._2 == t2._2
    }
    
    public var description: String {
        return "\(_1)⊗\(_2)"
    }
}

public func ⊗<A, B>(a: A, b: B) -> Tensor<A, B> {
    return Tensor(a, b)
}

public func ⊗<A, B, R>(x: FreeModule<A, R>, y: FreeModule<B, R>) -> FreeModule<Tensor<A, B>, R> {
    let elements = x.basis.allCombinations(with: y.basis).map{ (a, b) -> (Tensor<A, B>, R) in
        return (a ⊗ b, x[a] * y[b])
    }
    return FreeModule(elements)
}
