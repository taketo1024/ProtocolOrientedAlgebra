//
//  FreeModule.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/02.
//

public protocol FreeModule: Module {
    associatedtype Generator: FreeModuleGenerator
    init(elements: [Generator : BaseRing])
    var elements: [Generator : BaseRing] { get }
}

extension FreeModule {
    public init<S: Sequence>(elements: S, keysAreUnique: Bool = true) where S.Element == (Generator, BaseRing) {
        if keysAreUnique {
            self.init(elements: Dictionary(pairs: elements))
        } else {
            let dict = elements
                .group(by: { $0.0 })
                .mapValues{ BaseRing.sum($0.map{ $0.1 }) }
            self.init(elements: dict)
        }
    }
    
    public init(elements: (Generator, BaseRing) ...) {
        self.init(elements: elements)
    }

    public init<S1: Sequence, S2: Sequence>(generators: S1, coefficients: S2) where S1.Element == Generator, S2.Element == BaseRing {
        assert(generators.count >= coefficients.count)
        self.init(elements: zip(generators, coefficients))
    }
    
    public init<S1: Sequence, n>(generators: S1, coefficients: ColVector<n, BaseRing>) where S1.Element == Generator {
        let array = Array(generators)
        assert(array.count >= coefficients.size.rows)
        
        let elements = coefficients.nonZeroComponents.map{ (i, _, r) in (array[i], r) }
        self.init(elements: elements)
    }
    
    public init(_ z: LinearCombination<Generator, BaseRing>) {
        self.init(elements: z.elements)
    }

    public subscript(a: Generator) -> BaseRing {
        elements[a] ?? .zero
    }
    
    @_transparent
    public static func wrap(_ a: Generator) -> Self {
        .init(elements: [a : .identity])
    }
    
    public func unwrap() -> Generator? {
        isGenerator ? elements.first!.0 : nil
    }
    
    public var isSingleTerm: Bool {
        (elements.count == 1)
    }
    
    public var isGenerator: Bool {
        isSingleTerm && elements.first!.1.isIdentity
    }
    
    public static var zero: Self {
        .init(elements: [:])
    }
    
    internal var degree_FreeModule: Int {
        isZero ? 0 : elements.map{ (a, r) in a.degree + r.degree }.max()!
    }
    
    public var degree: Int {
        degree_FreeModule
    }
    
    public var generators: Dictionary<Generator, BaseRing>.Keys {
        elements.keys
    }
    
    public func decomposed() -> [(Generator, BaseRing)] {
        elements.map{ (a, r) in (a, r) }
    }
    
    public static func + (a: Self, b: Self) -> Self {
        Self.sum([a, b])
    }
    
    public static prefix func - (a: Self) -> Self {
        .init(elements: a.elements.mapValues{ -$0 })
    }
    
    public static func * (r: BaseRing, a: Self) -> Self {
        .init(elements: a.elements.mapValues{ r * $0 } )
    }
    
    public static func * (a: Self, r: BaseRing) -> Self {
        .init(elements: a.elements.mapValues{ $0 * r } )
    }
    
    public static func sum(_ summands: [Self]) -> Self {
        switch summands.count {
        case 0: return .zero
        case 1: return summands.first!
        default:
            let N = summands.sum { z in z.elements.count }
            
            var sum: [Generator : BaseRing] = [:]
            sum.reserveCapacity(N)

            for z in summands {
                for (a, r) in z.elements {
                    sum[a] = sum[a, default: .zero] + r
                }
            }
            return .init(elements: sum)
        }
    }
    
    // MEMO: Swift does not support higher kinded types.
    public func mapGenerators<A>(_ f: (Generator) -> A) -> LinearCombination<A, BaseRing> {
        mapPairs{ (a, r) in (f(a), r) }
    }
    
    public func mapCoefficients<R>(_ f: (BaseRing) -> R) -> LinearCombination<Generator, R> {
        mapPairs{ (a, r) in (a, f(r)) }
    }
    
    public func mapPairs<A, R>(_ f: (Generator, BaseRing) -> (A, R)) -> LinearCombination<A, R> {
        LinearCombination<A, R>(elements: elements.map{ (a, r) in f(a, r) }, keysAreUnique: false)
    }
    
    public var asLinearCombination: LinearCombination<Generator, BaseRing> {
        LinearCombination(elements: elements)
    }
    
    public var description: String {
        Format.terms("+", elements.sorted(by: { $0.key }).map { (a, r) in (r, a.description, 1) })
    }
}

extension FreeModule where Generator: Multiplicative {
    public static func * (a: Self, b: Self) -> Self {
        let elements = (a.elements * b.elements).map { (ca, cb) -> (Generator, BaseRing) in
            let (x, r) = ca
            let (y, s) = cb
            return (x * y, r * s)
        }
        return .init(elements: elements, keysAreUnique: false)
    }
}

// concrete type to be conformed to Ring.
extension FreeModule where Generator: Monoid {
    public init(from n: 𝐙) {
        self.init(BaseRing(from: n))
    }

    public init(_ r: BaseRing) {
        self.init(elements: [.identity : r])
    }
    
    public var inverse: Self? {
        if isSingleTerm,
            let (a, r) = self.elements.anyElement,
            let aInv = a.inverse,
            let rInv = r.inverse
        {
            return .init(elements: [aInv : rInv])
        } else {
            return nil
        }
    }
}

extension ModuleHom where X: FreeModule, Y: FreeModule {
    public static func linearlyExtend(_ f: @escaping (X.Generator) -> Codomain) -> ModuleHom<X, Y> {
        ModuleHom { (m: Domain) in
            m.isGenerator ? f(m.unwrap()!) : m.elements.sum { (a, r) in r * f(a) }
        }
    }
    
    public func applied(to x: X.Generator) -> Y {
        applied(to: .wrap(x))
    }
}
