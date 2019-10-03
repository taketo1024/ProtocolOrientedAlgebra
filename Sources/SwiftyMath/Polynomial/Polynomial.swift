//
//  Polynomial.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/02.
//

public protocol PolynomialType: FreeModuleType, Ring where Generator: PolynomialGeneratorType {}

extension PolynomialType {
    public init(coeffs: [Generator.Exponent : BaseRing]) {
        self.init(elements: coeffs.mapKeys{ n in Generator(n) } )
    }
    
    public var degree: Int {
        degree_FreeModuleType
    }

    public var normalizingUnit: Self {
        if let a = leadCoeff.inverse {
            return a * .identity
        } else {
            return .identity
        }
    }
    
    func coeff(_ exponent: Generator.Exponent) -> BaseRing {
        self[Generator(exponent)]
    }
    
    public var coeffsTable: [Generator.Exponent : BaseRing] {
        elements.mapKeys { t in t.exponent }
    }
 
    public var maxExponent: Generator.Exponent? {
        generators.max().map{ $0.exponent }
    }
    
    public var minExponent: Generator.Exponent? {
        generators.min().map{ $0.exponent }
    }
    
    public var leadCoeff: BaseRing {
        maxExponent.map{ self.coeff($0) } ?? .zero
    }
    
    public var leadTerm: Self {
        maxExponent.map{ n in .init(elements: [Generator(n) : coeff(n)] ) } ?? .zero
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
    
    public var elements: [Generator : Polynomial<x, R>.BaseRing]
    
    public init(elements: [Generator : BaseRing]) {
        self.elements = elements.exclude{ $0.value.isZero }
    }

    public static var zero: Self {
        .init(elements: [:])
    }
    
    public func mapCoefficients<R2: Ring>(_ f: (R) -> R2) -> Polynomial<x, R2> {
        .init(elements: elements.mapValues{ f($0) })
    }
}

extension Polynomial: EuclideanRing where R: Field {
    public var euclideanDegree: Int {
        maxExponent ?? 0
    }
    
    public static func /%(f: Polynomial, g: Polynomial) -> (q: Polynomial, r: Polynomial) {
        assert(!g.isZero)
        
        let x = Polynomial.indeterminate
        
        func eucDivMonomial(_ f: Polynomial, _ g: Polynomial) -> (q: Polynomial, r: Polynomial) {
            if f.euclideanDegree < g.euclideanDegree {
                return (.zero, f)
            } else {
                let a = f.leadCoeff / g.leadCoeff
                let n = f.euclideanDegree - g.euclideanDegree
                let q = a * x.pow(n)
                let r = f - q * g
                return (q, r)
            }
        }
        
        return (0 ... max(0, f.euclideanDegree - g.euclideanDegree))
            .reversed()
            .reduce( (.zero, f) ) { (result: (Polynomial, Polynomial), degree: Int) in
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
    
    public func mapCoefficients<R2: Ring>(_ f: (R) -> R2) -> LaurentPolynomial<x, R2> {
        .init(elements: elements.mapValues{ f($0) })
    }
}

