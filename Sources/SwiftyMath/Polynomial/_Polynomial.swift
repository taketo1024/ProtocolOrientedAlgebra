//
//  Polynomial.swift
//  
//
//  Created by Taketo Sano on 2021/05/18.
//

public protocol _PolynomialType: Ring {
    associatedtype BaseRing: Ring
    associatedtype Indeterminate
    associatedtype Exponent: AdditiveGroup & Hashable & Comparable // Int or MultiIndex<n>

    init(coeffs: [Exponent : BaseRing])
    var coeffs: [Exponent : BaseRing] { get }
    var leadExponent: Exponent { get }
}

extension _PolynomialType {
    public init(from a: 𝐙) {
        self.init(BaseRing(from: a))
    }
    
    public init(_ a: BaseRing) {
        self.init(coeffs: [.zero: a])
    }
    
    public func coeff(_ exponent: Exponent) -> BaseRing {
        coeffs[exponent] ?? .zero
    }
    
    public func term(_ d: Exponent) -> Self {
        return Self(coeffs: [d: coeff(d)])
    }
    
    public static var zero: Self {
        .init(coeffs: [:])
    }
    
    public static var identity: Self {
        .init(coeffs: [.zero : .identity])
    }
    
    public var isZero: Bool {
        coeffs.count == 0
    }
    
    public var isIdentity: Bool {
        isMonomial && constCoeff == .identity
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
}

public protocol _UnivariatePolynomialType: _PolynomialType where Exponent == Int, Indeterminate: PolynomialIndeterminate {}

extension _UnivariatePolynomialType {
    public static var indeterminate: Self {
        Self(coeffs: [1: .identity])
    }
    
    public var degree: Int {
        Indeterminate.degree * leadExponent
    }
    
    public var leadExponent: Int {
        coeffs.keys.max() ?? 0
    }
    
    public var derivative: Self {
        .init(coeffs: coeffs
            .filter{ (n, _) in n != 0 }
            .mapPairs{ (n, a) in (n - 1, BaseRing(from: n) * a ) }
        )
    }
    
    public var asLinearCombination: LinearCombination<UnivariatePolynomialGenerator<Indeterminate>, BaseRing> {
        .init(elements: coeffs.mapKeys{ d in .init(d) })
    }
    
    public var description: String {
        Format.linearCombination(
            coeffs
                .sorted{ $0.key > $1.key }
                .map { (n, a) in
                    (Format.power(Indeterminate.symbol, n), a)
                }
        )
    }
}

public struct _Polynomial<R: Ring, x: PolynomialIndeterminate>: _UnivariatePolynomialType {
    public typealias BaseRing = R
    public typealias Indeterminate = x
    public typealias Exponent = Int

    public let coeffs: [Int: R]
    public init(coeffs: [Int : R]) {
        assert(coeffs.keys.allSatisfy{ $0 >= 0} )
        self.coeffs = coeffs.exclude{ $0.value.isZero }
    }
    
    public init(coeffs: R...) {
        let coeffs = Dictionary(pairs: coeffs.enumerated().map{ (i, a) in (i, a)})
        self.init(coeffs: coeffs)
    }

    public var inverse: Self? {
        (isConst && constCoeff.isInvertible)
            ? .init(constCoeff.inverse!)
            : nil
    }
    
    public func evaluate(by x: R) -> R {
        coeffs.sum { (n, a) in a * x.pow(n) }
    }
}

extension _Polynomial: EuclideanRing where R: Field {
    public var euclideanDegree: Int {
        isZero ? 0 : 1 + leadExponent
    }
    
    public static func /%(f: Self, g: Self) -> (q: Self, r: Self) {
        assert(!g.isZero)
        
        let x = indeterminate
        
        func eucDivMonomial(_ f: Self, _ g: Self) -> (q: Self, r: Self) {
            if f.euclideanDegree < g.euclideanDegree {
                return (.zero, f)
            } else {
                let a = f.leadCoeff / g.leadCoeff
                let n = f.leadExponent - g.leadExponent
                let q = a * x.pow(n)
                let r = f - q * g
                return (q, r)
            }
        }
        
        return (0 ... max(0, f.leadExponent - g.leadExponent))
            .reversed()
            .reduce( (.zero, f) ) { (result: (Self, Self), degree: Int) in
                let (q, r) = result
                let m = eucDivMonomial(r, g)
                return (q + m.q, m.r)
        }
    }
}

