//
//  Polynomial.swift
//  
//
//  Created by Taketo Sano on 2021/05/18.
//

public protocol PolynomialIndeterminate {
    static var symbol: String { get }
    static var degree: Int { get }
}

public extension PolynomialIndeterminate {
    static var degree: Int {
        1
    }
}

public protocol UnivariatePolynomialType: PolynomialType where Exponent == Int, Indeterminate: PolynomialIndeterminate {}

extension UnivariatePolynomialType {
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
    
    public func evaluate(by x: BaseRing) -> BaseRing {
        coeffs.sum { (n, a) in a * x.pow(n) }
    }

    
//    public var asLinearCombination: LinearCombination<UnivariatePolynomialGenerator<Indeterminate>, BaseRing> {
//        .init(elements: coeffs.mapKeys{ d in .init(d) })
//    }
    
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

public struct Polynomial<R: Ring, X: PolynomialIndeterminate>: UnivariatePolynomialType {
    public typealias BaseRing = R
    public typealias Indeterminate = X
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
}

extension Polynomial: EuclideanRing where R: Field {
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

extension Polynomial: ExpressibleByIntegerLiteral where R: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: R.IntegerLiteralType) {
        self.init(BaseRing(integerLiteral: value))
    }
}

public struct LaurentPolynomial<R: Ring, X: PolynomialIndeterminate>: UnivariatePolynomialType {
    public typealias BaseRing = R
    public typealias Indeterminate = X
    public typealias Exponent = Int

    public let coeffs: [Int: R]
    public init(coeffs: [Int : R]) {
        self.coeffs = coeffs.exclude{ $0.value.isZero }
    }
    
    public var inverse: Self? {
        if isMonomial && leadCoeff.isInvertible {
            let d = degree
            let a = leadCoeff
            return .init(coeffs: [-d: a.inverse!])
        } else {
            return nil
        }
    }
}

extension LaurentPolynomial: ExpressibleByIntegerLiteral where R: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: R.IntegerLiteralType) {
        self.init(BaseRing(integerLiteral: value))
    }
}

