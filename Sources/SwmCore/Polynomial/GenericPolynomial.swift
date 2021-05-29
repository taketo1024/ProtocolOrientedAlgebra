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
    public init<S>(elements: S) where S: Sequence, S.Element == (Exponent, BaseRing) {
        self.init(elements: Dictionary(elements, uniquingKeysWith: +))
    }
    
    public init(dictionaryLiteral elements: (Exponent, BaseRing)...) {
        self.init(elements: elements)
    }
    
    public init(from a: 𝐙) {
        self.init(BaseRing(from: a))
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
    
    public static var identity: Self {
        .init(elements: [.zero : .identity])
    }
    
    public var reduced: Self {
        .init(elements: elements.exclude{ $0.value.isZero })
    }
    
    public var normalizingUnit: Self {
        .init(leadCoeff.normalizingUnit)
    }
    
    public var degree: Int {
        degree(of: leadExponent)
    }
    
    public func degree(of e: Exponent) -> Int {
        let a = coeff(e)
        return !a.isZero
            ? a.degree + Indeterminate.degreeOfMonomial(withExponent: e)
            : 0
    }
    
    public func coeff(_ exponent: Exponent) -> BaseRing {
        elements[exponent] ?? .zero
    }
    
    public func term(_ d: Exponent) -> Self {
        Self(elements: [d: coeff(d)])
    }
    
    public var terms: [Self] {
        elements.keys.sorted().compactMap {
            let t = term($0)
            return !t.isZero ? t : nil
        }
    }
    
    public var leadExponent: Exponent {
        elements.compactMap{ (e, a) in !a.isZero ? e : nil }
            .max{ (e1, e2) in degree(of: e1) < degree(of: e2) } ?? .zero
    }
    
    public var leadCoeff: BaseRing {
        coeff(leadExponent)
    }
    
    public var leadTerm: Self {
        term(leadExponent)
    }
    
    public var tailExponent: Exponent {
        elements.compactMap{ (e, a) in !a.isZero ? e : nil }
            .min{ (e1, e2) in degree(of: e1) < degree(of: e2) } ?? .zero
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
        self == constTerm
    }
    
    public var isMonic: Bool {
        leadCoeff.isIdentity
    }
    
    // MEMO: must be reduced to work properly.
    public var isMonomial: Bool {
        elements.count <= 1
    }
    
    public var isHomogeneous: Bool {
        elements.compactMap{ (e, a) in
            !a.isZero ? degree(of: e) : nil
        }.isUnique
    }
    
    public var asLinearCombination: LinearCombination<BaseRing, MonomialAsGenerator<Indeterminate>> {
        .init(elements: elements.mapPairs{ (e, a) in (.init(exponent: e), a) })
    }
    
    public static func == (a: Self, b: Self) -> Bool {
        a.elements.exclude{ $0.value.isZero } == b.elements.exclude{ $0.value.isZero }
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
        .init(elements: (a.elements * b.elements).map { (ca, cb) -> (Exponent, BaseRing) in
            let (x, r) = ca
            let (y, s) = cb
            return (x + y, r * s)
        })
    }
    
    @inlinable
    public static func sum<S: Sequence>(_ summands: S) -> Self where S.Element == Self {
        .init(elements: summands.flatMap{ $0.elements })
    }
    
    public var description: String {
        Format.linearCombination(
            elements.sorted{ (e, _) in degree(of: e) }
                .reversed()
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
