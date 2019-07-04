import Foundation

public protocol FreeModuleGenerator: Hashable, Comparable, CustomStringConvertible {
    var degree: Int { get }
}

public extension FreeModuleGenerator {
    var degree: Int { return 1 }
}

public protocol FreeModuleType: Module {
    associatedtype Generator: FreeModuleGenerator
    var elements: [Generator : CoeffRing] { get }
    static func wrap(_ a: Generator) -> Self
    static func combine<n>(basis: [Generator], vector: ColVector<n, CoeffRing>) -> Self
    func factorize(by: [Generator]) -> DVector<CoeffRing>
}

public struct FreeModule<A: FreeModuleGenerator, R: Ring>: FreeModuleType {
    public typealias CoeffRing = R
    public typealias Generator = A
    
    public let elements: [A: R]
    
    // root initializer
    public init(_ elements: [A : R]) {
        self.elements = elements.filter{ $0.value != .zero }
    }
    
    public init<S: Sequence>(_ elements: S) where S.Element == (A, R) {
        let dict = Dictionary(pairs: elements)
        self.init(dict)
    }
    
    @_transparent
    public static func wrap(_ a: A) -> FreeModule<A, R> {
        return FreeModule([a : .identity])
    }

    @_transparent
    public func unwrap() -> A {
        assert(isSingle)
        return elements.anyElement!.key
    }
    
    public static func combine<n>(basis: [A], vector: ColVector<n, R>) -> FreeModule<A, R> {
        assert(basis.count == vector.size.rows)
        return (basis.map{ .wrap($0) } * vector)[0]
    }
    
    public subscript(a: A) -> R {
        return elements[a] ?? .zero
    }
    
    public var degree: Int {
        guard let a = elements.anyElement?.0 else {
            return 0
        }
        return self[a].degree + a.degree
    }
    
    public var generators: [A] {
        return elements.keys.sorted().toArray()
    }
    
    public func factorize(by basis: [A]) -> DVector<R> {
        let indexer = basis.indexer()
        let comps = elements.compactMap { (a, r) -> MatrixComponent<R>? in
            indexer(a).map{ i in (i, 0, r) }
        }
        return DVector<R>(size: (basis.count, 1), components: comps, zerosExcluded: true)
    }
    
    public var isSingle: Bool {
        return elements.count == 1 && elements.anyElement!.value == .identity
    }
    
    public static var zero: FreeModule<A, R> {
        return FreeModule([])
    }
    
    public static func + (a: FreeModule<A, R>, b: FreeModule<A, R>) -> FreeModule<A, R> {
        var d = a.elements
        for (a, r) in b.elements {
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
    
    public static func sum(_ elements: [FreeModule<A, R>]) -> FreeModule<A, R> {
        var sum = [A : R]()
        elements.forEach{ x in
            sum.merge(x.elements) { (r1, r2) in r1 + r2 }
        }
        return FreeModule(sum)
    }
    
    public func mapGenerators<A2>(_ f: (A) -> A2) -> FreeModule<A2, R> {
        return FreeModule<A2, R>(elements.mapKeys(f))
    }
    
    public func mapComponents<R2>(_ f: (R) -> R2) -> FreeModule<A, R2> {
        return FreeModule<A, R2>(elements.mapValues(f))
    }
    
    public var description: String {
        return Format.terms("+", generators.map { a in (self[a], a.description, 1) })
    }
    
    public static var symbol: String {
        return "FreeMod(\(R.symbol))"
    }
}

extension FreeModule where R: RealSubset {
    public var asReal: FreeModule<A, 𝐑> {
        return mapComponents{ $0.asReal }
    }
}

extension FreeModule where R: ComplexSubset {
    public var asComplex: FreeModule<A, 𝐂> {
        return mapComponents{ $0.asComplex }
    }
}

extension ModuleHom where X: FreeModuleType, Y: FreeModuleType {
    public static func linearlyExtend(_ f: @escaping (X.Generator) -> Codomain) -> ModuleHom<X, Y> {
        return ModuleHom { (m: Domain) in
            m.elements.map{ (a, r) in r * f(a) }.sumAll()
        }
    }
    
    public static func linearlyExtend(from: [X.Generator], to: [Y.Generator], matrix: DMatrix<CoeffRing>) -> ModuleHom<X, Y> {
        let indexer = from.indexer()
        return ModuleHom.linearlyExtend { e in
            guard let j = indexer(e) else { return .zero }
            return Y.combine(basis: to, vector: matrix.colVector(j))
        }
    }
    
    public func asMatrix(from: [X.Generator], to: [Y.Generator]) -> DMatrix<CoeffRing> {
        let comps = from.enumerated().flatMap { (j, a) -> [MatrixComponent<CoeffRing>] in
            let w = self.applied(to: .wrap(a))
            return w.factorize(by: to).map{ (i, _, a) in (i, j, a) }
        }
        return DMatrix(size: (to.count, from.count), components: comps, zerosExcluded: true)
    }
}

extension FreeModule: Codable where A: Codable, R: Codable {}
