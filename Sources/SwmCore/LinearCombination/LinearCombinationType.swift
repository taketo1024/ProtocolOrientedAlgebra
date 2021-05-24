//
//  LinearCombinationType.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/02.
//

public protocol LinearCombinationGenerator: Hashable, Comparable, CustomStringConvertible {
    var degree: Int { get }
}

public extension LinearCombinationGenerator {
    var degree: Int { 1 }
}

public protocol LinearCombinationType: Module, ExpressibleByDictionaryLiteral where Key == Generator {
    associatedtype Generator: LinearCombinationGenerator
    init(elements: [Generator : BaseRing])
    var elements: [Generator : BaseRing] { get }
}

extension LinearCombinationType {
    public init<S: Sequence>(elements: S, generatorsAreUnique: Bool = true) where S.Element == (Generator, BaseRing) {
        if generatorsAreUnique {
            self.init(elements: Dictionary(elements))
        } else {
            let dict = elements
                .group(by: { $0.0 })
                .mapValues{ BaseRing.sum($0.map{ $0.1 }) }
            self.init(elements: dict)
        }
    }
    
    public init<S1: Sequence, S2: Sequence>(generators: S1, coefficients: S2, generatorsAreUnique: Bool = true) where S1.Element == Generator, S2.Element == BaseRing {
        assert(generators.count >= coefficients.count)
        self.init(elements: zip(generators, coefficients))
    }
    
    public init(dictionaryLiteral elements: (Generator, BaseRing)...) {
        self.init(elements: elements)
    }
    
    public init(_ a: Generator) {
        self.init(elements: [a : .identity])
    }
    
    public init(_ z: LinearCombination<BaseRing, Generator>) {
        self.init(elements: z.elements)
    }

    public static var zero: Self {
        .init(elements: [:])
    }
    
    public var isSingleTerm: Bool {
        (elements.count == 1)
    }
    
    public var isGenerator: Bool {
        isSingleTerm && elements.first!.value.isIdentity
    }
    
    public var asGenerator: Generator? {
        isGenerator ? elements.first.flatMap{ $0.key } : nil
    }
    
    public var generators: AnySequence<Generator> {
        AnySequence(elements.keys)
    }
    
    public var degree: Int {
        generators.map{ a in degree(ofTerm: a) }.max() ?? 0
    }
    
    public func degree(ofTerm a: Generator) -> Int {
        coeff(a).degree + a.degree
    }
    
    public var isHomogeneous: Bool {
        generators.map{ a in degree(ofTerm: a) }.isUnique
    }
    
    public func coeff(_ a: Generator) -> BaseRing {
        elements[a] ?? .zero
    }
    
    public func term(_ a: Generator) -> Self {
        .init(elements: [a: coeff(a)])
    }
    
    public var terms: [Self] {
        generators.map{ term($0) }
    }
    
    public static func + (a: Self, b: Self) -> Self {
        .init(elements: a.elements.merging(b.elements, uniquingKeysWith: +))
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
    
    public static func sum<S: Sequence>(_ summands: S) -> Self where S.Element == Self {
        var sum = Dictionary(
            summands.reduce(into: Set()) { (res, summand) in
                res.formUnion(summand.elements.keys)
            }.map { a in
                (a, BaseRing.zero)
            }
        )
        for z in summands {
            for (a, r) in z.elements {
                sum[a] = sum[a]! + r
            }
        }
        return .init(elements: sum)
    }
    
    public func filter(_ f: (Generator) -> Bool) -> Self {
        .init(elements: elements.filter{ (a, _) in f(a) })
    }
    
    public func mapGenerators<A>(_ f: (Generator) -> A) -> LinearCombination<BaseRing, A> {
        mapElements{ (a, r) in (f(a), r) }
    }
    
    public func mapCoefficients<R>(_ f: (BaseRing) -> R) -> LinearCombination<R, Generator> {
        mapElements{ (a, r) in (a, f(r)) }
    }
    
    public func mapElements<A, R>(_ f: (Generator, BaseRing) -> (A, R)) -> LinearCombination<R, A> {
        LinearCombination<R, A>(elements: elements.map{ (a, r) in f(a, r) }, generatorsAreUnique: false)
    }
    
    public var asLinearCombination: LinearCombination<BaseRing, Generator> {
        LinearCombination(elements: elements)
    }
    
    public var description: String {
        Format.linearCombination(elements.sorted{ $0.key < $1.key })
    }
}

extension LinearCombinationType where Generator: Multiplicative {
    public static func * (a: Self, b: Self) -> Self {
        let elements = (a.elements * b.elements).map { (ca, cb) -> (Generator, BaseRing) in
            let (x, r) = ca
            let (y, s) = cb
            return (x * y, r * s)
        }
        return .init(elements: elements, generatorsAreUnique: false)
    }
}

extension ModuleHom where Domain: LinearCombinationType, Codomain: LinearCombinationType, Domain.BaseRing == Codomain.BaseRing {
    public static func linearlyExtend(_ f: @escaping (Domain.Generator) -> Codomain) -> Self {
        ModuleHom { (m: Domain) in
            m.isGenerator ? f(m.asGenerator!) : m.elements.sum { (a, r) in r * f(a) }
        }
    }
    
    public func callAsFunction(_ x: Domain.Generator) -> Codomain {
        callAsFunction(.init(x))
    }
}
