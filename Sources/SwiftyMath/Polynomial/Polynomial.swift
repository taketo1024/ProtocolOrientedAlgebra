//
//  Polynomial.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/02.
//

public protocol PolynomialType: FreeModule, Ring where Generator: PolynomialGeneratorType {}

extension PolynomialType {
    public init(coeffs: [Generator.Exponent : BaseRing]) {
        self.init(elements: coeffs.mapKeys{ n in Generator(n) } )
    }
    
    public var normalizingUnit: Self {
        if let a = leadCoeff.inverse {
            return a * .identity
        } else {
            return .identity
        }
    }
    
    public func coeff(_ exponent: Generator.Exponent) -> BaseRing {
        self[Generator(exponent)]
    }
    
    public var coeffsTable: [Generator.Exponent : BaseRing] {
        elements.mapKeys { t in t.exponent }
    }
    
    public var degree: Int {
        if let e = _highestExponent {
            return Generator(e).degree + coeff(e).degree
        } else {
            return 0
        }
    }
 
    internal var _highestExponent: Generator.Exponent? {
        generators.max().map{ $0.exponent }
    }
    
    internal var _lowestExponent: Generator.Exponent? {
        generators.min().map{ $0.exponent }
    }
    
    public var leadCoeff: BaseRing {
        _highestExponent.map{ self.coeff($0) } ?? .zero
    }
    
    public var leadTerm: Self {
        _highestExponent.map{ n in .init(elements: [Generator(n) : coeff(n)] ) } ?? .zero
    }
    
    public var isMonic: Bool {
        leadCoeff.isIdentity
    }
    
    public var isConst: Bool {
        self == .zero || (isSingleTerm && !constTerm.isZero)
    }
    
    public var constTerm: BaseRing {
        self[.identity]
    }
    
    public var description: String {
        Format.linearCombination(elements.sorted{ $0.key > $1.key })
    }
}

extension PolynomialType where BaseRing: Field {
    func toMonic() -> Self {
        leadCoeff.inverse! * self
    }
}

public protocol UnivariatePolynomialType: PolynomialType where Generator: UnivariatePolynomialGeneratorType, Indeterminate == Generator.Indeterminate {
    associatedtype Indeterminate
}

extension UnivariatePolynomialType {
    public init(coeffs: [BaseRing]) {
        self.init(elements: coeffs.enumerated().map{ (n, r) in (Generator(n), r) } )
    }
    
    public init(coeffs: BaseRing...) {
        self.init(coeffs: coeffs)
    }
    
    public static var indeterminate: Self {
        .init(coeffs: [.zero, .identity])
    }
    
    public var highestExponent: Int {
        _highestExponent ?? 0
    }
    
    public var lowestExponent: Int {
        _lowestExponent ?? 0
    }
    
    public var derivative: Self {
        .init(coeffs: coeffsTable
            .filter{ (n, _) in n != 0 }
            .mapPairs{ (n, a) in (n - 1, BaseRing(from: n) * a ) }
        )
    }
    
    public func evaluate(by x: BaseRing) -> BaseRing {
        elements.sum { (t, a) in a * t.evaluate(by: x) }
    }
}

public struct Polynomial<x: PolynomialIndeterminate, R: Ring>: UnivariatePolynomialType {
    public typealias Indeterminate = x
    public typealias Generator = UnivariatePolynomialGenerator<x>
    public typealias BaseRing = R
    
    public var elements: [Generator : BaseRing]
    
    public init(elements: [Generator : BaseRing]) {
        self.elements = elements.exclude{ $0.value.isZero }
    }

    public static var zero: Self {
        .init(elements: [:])
    }
}

extension Polynomial: EuclideanRing where R: Field {
    public var euclideanDegree: Int {
        isZero ? 0 : 1 + highestExponent
    }
    
    public static func /%(f: Self, g: Self) -> (q: Self, r: Self) {
        assert(!g.isZero)
        
        let x = indeterminate
        
        func eucDivMonomial(_ f: Self, _ g: Self) -> (q: Self, r: Self) {
            if f.euclideanDegree < g.euclideanDegree {
                return (.zero, f)
            } else {
                let a = f.leadCoeff / g.leadCoeff
                let n = f.highestExponent - g.highestExponent
                let q = a * x.pow(n)
                let r = f - q * g
                return (q, r)
            }
        }
        
        return (0 ... max(0, f.highestExponent - g.highestExponent))
            .reversed()
            .reduce( (.zero, f) ) { (result: (Self, Self), degree: Int) in
                let (q, r) = result
                let m = eucDivMonomial(r, g)
                return (q + m.q, m.r)
        }
    }
}

public protocol UnivariateLaurentPolynomialType: UnivariatePolynomialType where Generator: UnivariateLaurentPolynomialGeneratorType {}

extension UnivariateLaurentPolynomialType {
    public init(lowestExponent s: Int, coeffs: [BaseRing]) {
        self.init(elements: coeffs.enumerated().map{ (n, r) in (Generator(n + s), r) } )
    }
    
    public init(lowestExponent s: Int, coeffs: BaseRing...) {
        self.init(lowestExponent: s, coeffs: coeffs)
    }
}

public struct LaurentPolynomial<x: PolynomialIndeterminate, R: Ring>: UnivariateLaurentPolynomialType {
    public typealias Indeterminate = x
    public typealias Generator = UnivariateLaurentPolynomialGenerator<x>
    public typealias BaseRing = R
    
    public var elements: [Generator : Polynomial<x, R>.BaseRing]
    
    public init(elements: [Generator : BaseRing]) {
        self.elements = elements.exclude{ $0.value.isZero }
    }

    public static var zero: Self {
        .init(elements: [:])
    }
}

