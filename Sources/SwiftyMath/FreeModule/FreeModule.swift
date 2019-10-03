//
//  FreeModule.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/02.
//

public protocol FreeModuleType: Module {
    associatedtype Generator: FreeModuleGenerator
    init(elements: [Generator : BaseRing])
    var elements: [Generator : BaseRing] { get }
}

extension FreeModuleType {
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
        self.init(elements: coefficients.components.map{ (i, _, r) in (array[i], r) } )
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
    
    public var degree: Int {
        if let (a, r) = elements.first {
            return a.degree + r.degree
        } else {
            return 0
        }
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
    
    public var asFreeModule: FreeModule<Generator, BaseRing> {
        FreeModule(elements: elements)
    }
    
    public var description: String {
        Format.terms("+", elements.sorted(by: { $0.key }).map { (a, r) in (r, a.description, 1) })
    }
}

extension FreeModuleType where Generator: Multiplicative {
    public static func * (a: Self, b: Self) -> Self {
        let elements = (a.elements * b.elements).map { (ca, cb) -> (Generator, BaseRing) in
            let (x, r) = ca
            let (y, s) = cb
            return (x * y, r * s)
        }
        return .init(elements: elements, keysAreUnique: false)
    }
}

public struct FreeModule<A: FreeModuleGenerator, R: Ring>: FreeModuleType {
    public typealias BaseRing = R
    public typealias Generator = A
    
    public let elements: [A : R]
    
    public init(elements: [A : R]) {
        self.elements = elements.exclude{ $0.value.isZero }
    }
    
    public func mapGenerators<A2>(_ f: (A) -> A2) -> FreeModule<A2, R> {
        map{ (a, r) in (f(a), r) }
    }
    
    public func mapComponents<R2>(_ f: (R) -> R2) -> FreeModule<A, R2> {
        map{ (a, r) in (a, f(r)) }
    }
    
    public func map<A2, R2>(_ f: (A, R) -> (A2, R2)) -> FreeModule<A2, R2> {
        FreeModule<A2, R2>(elements: elements.map{ (a, r) in f(a, r) }, keysAreUnique: false)
    }
    
    public static var symbol: String {
        "FreeMod(\(R.symbol))"
    }
}

extension FreeModule where R: RealSubset {
    public var asReal: FreeModule<A, 𝐑> {
        mapComponents{ $0.asReal }
    }
}

extension FreeModule where R: ComplexSubset {
    public var asComplex: FreeModule<A, 𝐂> {
        mapComponents{ $0.asComplex }
    }
}

extension ModuleHom where X: FreeModuleType, Y: FreeModuleType {
    public static func linearlyExtend(_ f: @escaping (X.Generator) -> Codomain) -> ModuleHom<X, Y> {
        ModuleHom { (m: Domain) in
            m.isGenerator ? f(m.unwrap()!) : m.elements.sum { (a, r) in r * f(a) }
        }
    }
}

extension FreeModule: Codable where A: Codable, R: Codable {}
