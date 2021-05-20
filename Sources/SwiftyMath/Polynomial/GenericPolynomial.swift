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

public protocol GenericPolynomialType: Ring {
    associatedtype BaseRing: Ring
    associatedtype Indeterminate: GenericPolynomialIndeterminate
    typealias Exponent = Indeterminate.Exponent

    init(coeffs: [Exponent : BaseRing])
    var coeffs: [Exponent : BaseRing] { get }
}

extension GenericPolynomialType {
    public init(from a: 𝐙) {
        self.init(BaseRing(from: a))
    }
    
    public init(_ a: BaseRing) {
        self.init(coeffs: [.zero: a])
    }
    
    public init(_ p: LinearCombination<MonomialAsGenerator<Indeterminate>, BaseRing>) {
        self.init(coeffs: p.elements.mapPairs{ (x, a) in
            (x.exponent, a)
        })
    }
    
    public static var zero: Self {
        .init(coeffs: [:])
    }
    
    public var isZero: Bool {
        coeffs.count == 0
    }
    
    public static var identity: Self {
        .init(coeffs: [.zero : .identity])
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
        coeffs[exponent] ?? .zero
    }
    
    public func term(_ d: Exponent) -> Self {
        Self(coeffs: [d: coeff(d)])
    }
    
    public var terms: [Self] {
        coeffs.keys.sorted().map( term(_:) )
    }
    
    public var leadExponent: Exponent {
        coeffs.keys.max{ (e1, e2) in degree(of: e1) < degree(of: e2) } ?? .zero
    }
    
    public var leadCoeff: BaseRing {
        coeff(leadExponent)
    }
    
    public var leadTerm: Self {
        term(leadExponent)
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
        coeffs.count <= 1
    }
    
    public var isHomogeneous: Bool {
        coeffs.keys.map { e in degree(of: e) }.isUnique
    }
    
    public var asLinearCombination: LinearCombination<MonomialAsGenerator<Indeterminate>, BaseRing> {
        .init(elements: coeffs.mapPairs{ (e, a) in (.init(exponent: e), a) })
    }
    
    public static func + (a: Self, b: Self) -> Self {
        .init(coeffs: a.coeffs.merging(b.coeffs, uniquingKeysWith: +))
    }
    
    public static prefix func - (a: Self) -> Self {
        .init(coeffs: a.coeffs.mapValues{ -$0 })
    }
    
    public static func * (r: BaseRing, a: Self) -> Self {
        .init(coeffs: a.coeffs.mapValues{ r * $0 } )
    }
    
    public static func * (a: Self, r: BaseRing) -> Self {
        .init(coeffs: a.coeffs.mapValues{ $0 * r } )
    }
    
    public static func * (a: Self, b: Self) -> Self {
        var coeffs: [Exponent: BaseRing] = [:]
        (a.coeffs * b.coeffs).forEach { (ca, cb) in
            let (x, r) = ca
            let (y, s) = cb
            coeffs[x + y] = coeffs[x + y, default: .zero] + r * s
        }
        return .init(coeffs: coeffs)
    }
    
    public var description: String {
        Format.linearCombination(
            coeffs.sorted{ $0.key }
                .map { (I, a) -> (String, BaseRing) in
                    (Indeterminate.descriptionOfMonomial(withExponent: I), a)
                }
        )
    }
}

public struct MonomialAsGenerator<X: GenericPolynomialIndeterminate>: FreeModuleGenerator {
    public let exponent: X.Exponent
    
    public static func wrap(_ e: X.Exponent) -> Self {
        .init(exponent: e)
    }
    
    public var degree: Int {
        X.degreeOfMonomial(withExponent: exponent)
    }
    
    public static func < (a: Self, b: Self) -> Bool {
        a.exponent < b.exponent
    }

    public var description: String {
        X.descriptionOfMonomial(withExponent: exponent)
    }
}

// R[X]<A> -> R<A, XA, X^2A, ... >
extension LinearCombination where R: GenericPolynomialType {
    public func flatten() -> LinearCombination<TensorGenerator<MonomialAsGenerator<R.Indeterminate>, A>, R.BaseRing> {
        typealias T = TensorGenerator<MonomialAsGenerator<R.Indeterminate>, A>
        let inflated = elements.flatMap { (a, p) in
            p.coeffs.map { (m, r) -> (T, R.BaseRing) in
                (.wrap(m) ⊗ a, r)
            }
        }
        return LinearCombination<T, R.BaseRing>(elements: inflated)
    }
}
