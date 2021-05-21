//
//  PolynomialType.swift
//  
//
//  Created by Taketo Sano on 2021/05/20.
//

public protocol GenericPolynomialIndeterminate {
    associatedtype Exponent: AdditiveGroup & Hashable & Comparable // Int or MultiIndex<n>
    static func degreeOfMonomial(withExponent e: Exponent) -> Int
    static func descriptionOfMonomial(withExponent e: Exponent) -> String
}

public protocol GenericPolynomialType: Ring, ExpressibleByDictionaryLiteral {
    associatedtype BaseRing: Ring
    associatedtype Indeterminate: GenericPolynomialIndeterminate
    typealias Exponent = Indeterminate.Exponent

    init(elements: [Exponent : BaseRing])
    var elements: [Exponent : BaseRing] { get }
}

extension GenericPolynomialType {
    public init(from a: 𝐙) {
        self.init(BaseRing(from: a))
    }
    
    public init(dictionaryLiteral elements: (Exponent, BaseRing)...) {
        self.init(elements: Dictionary(pairs: elements))
    }
    
    public init(_ a: BaseRing) {
        self.init(elements: [.zero: a])
    }
    
    public init(_ p: LinearCombination<BaseRing, MonomialAsGenerator<Indeterminate>>) {
        self.init(elements: p.elements.mapPairs{ (x, a) in
            (x.exponent, a)
        })
    }
    
    public static var zero: Self {
        .init(elements: [:])
    }
    
    public var isZero: Bool {
        elements.count == 0
    }
    
    public static var identity: Self {
        .init(elements: [.zero : .identity])
    }
    
    public var isIdentity: Bool {
        isMonomial && constCoeff == .identity
    }
    
    public var normalizingUnit: Self {
        .init(leadCoeff.normalizingUnit)
    }
    
    public var degree: Int {
        degree(of: leadExponent)
    }
    
    public func degree(of e: Exponent) -> Int {
        coeff(e).degree + Indeterminate.degreeOfMonomial(withExponent: e)
    }
    
    public func coeff(_ exponent: Exponent) -> BaseRing {
        elements[exponent] ?? .zero
    }
    
    public func term(_ d: Exponent) -> Self {
        Self(elements: [d: coeff(d)])
    }
    
    public var terms: [Self] {
        elements.keys.sorted().map( term(_:) )
    }
    
    public var leadExponent: Exponent {
        elements.keys.max{ (e1, e2) in degree(of: e1) < degree(of: e2) } ?? .zero
    }
    
    public var leadCoeff: BaseRing {
        coeff(leadExponent)
    }
    
    public var leadTerm: Self {
        term(leadExponent)
    }
    
    public var tailExponent: Exponent {
        elements.keys.min{ (e1, e2) in degree(of: e1) < degree(of: e2) } ?? .zero
    }
    
    public var tailCoeff: BaseRing {
        coeff(tailExponent)
    }
    
    public var tailTerm: Self {
        term(tailExponent)
    }
    
    public var constCoeff: BaseRing {
        coeff(.zero)
    }
    
    public var constTerm: Self {
        term(.zero)
    }
    
    public var isConst: Bool {
        self == .zero || (isMonomial && !constTerm.isZero)
    }
    
    public var isMonic: Bool {
        leadCoeff.isIdentity
    }
    
    public var isMonomial: Bool {
        elements.count <= 1
    }
    
    public var isHomogeneous: Bool {
        elements.keys.map { e in degree(of: e) }.isUnique
    }
    
    public var asLinearCombination: LinearCombination<BaseRing, MonomialAsGenerator<Indeterminate>> {
        .init(elements: elements.mapPairs{ (e, a) in (.init(exponent: e), a) })
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
    
    public static func * (a: Self, b: Self) -> Self {
        var elements: [Exponent: BaseRing] = [:]
        (a.elements * b.elements).forEach { (ca, cb) in
            let (x, r) = ca
            let (y, s) = cb
            elements[x + y] = elements[x + y, default: .zero] + r * s
        }
        return .init(elements: elements)
    }
    
    public var description: String {
        Format.linearCombination(
            elements.sorted{ $0.key }
                .map { (I, a) -> (String, BaseRing) in
                    (Indeterminate.descriptionOfMonomial(withExponent: I), a)
                }
        )
    }
}

extension GenericPolynomialType where BaseRing: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: BaseRing.IntegerLiteralType) {
        self.init(BaseRing(integerLiteral: value))
    }
}


public struct MonomialAsGenerator<X: GenericPolynomialIndeterminate>: LinearCombinationGenerator {
    public let exponent: X.Exponent
    
    public init(exponent e: X.Exponent) {
        self.exponent = e
    }
    
    public static var unit: Self {
        .init(exponent: .zero)
    }
    
    public var degree: Int {
        X.degreeOfMonomial(withExponent: exponent)
    }
    
    public static func * (a: Self, b: Self) -> Self {
        .init(exponent: a.exponent + b.exponent)
    }

    public static func < (a: Self, b: Self) -> Bool {
        a.exponent < b.exponent
    }

    public var description: String {
        X.descriptionOfMonomial(withExponent: exponent)
    }
}

extension MonomialAsGenerator where X: MultivariatePolynomialIndeterminates {
    public init(exponent e: [Int]) {
        self.exponent = X.Exponent(e)
    }
}

// R[X]<A> -> R<A, XA, X^2A, ... >
extension LinearCombination where R: GenericPolynomialType {
    public func flatten() -> LinearCombination<R.BaseRing, TensorGenerator<MonomialAsGenerator<R.Indeterminate>, A>> {
        typealias T = TensorGenerator<MonomialAsGenerator<R.Indeterminate>, A>
        let inflated = elements.flatMap { (a, p) in
            p.elements.map { (e, r) -> (T, R.BaseRing) in
                (.init(exponent: e) ⊗ a, r)
            }
        }
        return LinearCombination<R.BaseRing, T>(elements: inflated)
    }
}
