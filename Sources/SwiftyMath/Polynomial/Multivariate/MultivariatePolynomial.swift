//
//  MultivariatePolynomialType.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/02.
//

public protocol MultivariatePolynomialType: PolynomialType where Generator: MultivariatePolynomialGeneratorType, Indeterminates == Generator.Indeterminates {
    associatedtype Indeterminates
}

extension MultivariatePolynomialType {
    public static func indeterminate(_ i: Int) -> Self {
        let I = [0] * i + [1]
        return .init(coeffs: [I : .identity] )
    }
    
    public static func monomial(withExponents I: [Int]) -> Self {
        .init(coeffs: [I: .identity])
    }
    
    public static func monomials(ofTotalExponent e: Int) -> [Self] {
        monomials(ofTotalExponent: e, usingIndeterminates: (0 ..< Indeterminates.numberOfIndeterminates).toArray())
    }
    
    public static func monomials(ofTotalExponent e: Int, usingIndeterminates indices: [Int]) -> [Self] {
        Generator.monomials(ofTotalExponent: e, usingIndeterminates: indices).map { .init(elements: [$0: .identity] )}
    }
    
    public var highestExponent: [Int] {
        _highestExponent ?? []
    }
    
    public var lowestExponent: [Int] {
        _lowestExponent ?? []
    }
    
    public func evaluate(by values: [BaseRing]) -> BaseRing {
        assert(Indeterminates.isFinite && values.count == Indeterminates.numberOfIndeterminates)
        return elements.sum { (xn, a) in
            a * xn.evaluate(by: values)
        }
    }
    
    public func evaluate(by values: BaseRing...) -> BaseRing {
        evaluate(by: values)
    }
    
    public static var symbol: String {
        typealias xn = Indeterminates
        if xn.isFinite {
            let n = xn.numberOfIndeterminates
            return "\(BaseRing.symbol)[\( (0 ..< n).map{ i in xn.symbol(i) }.joined(separator: ", "))]"
        } else {
            return "\(BaseRing.symbol)[\( (0 ..< 3).map{ i in xn.symbol(i) }.appended("…").joined(separator: ", "))]"
        }
    }
}

public struct MultivariatePolynomial<xn: MultivariatePolynomialIndeterminates, R: Ring>: MultivariatePolynomialType {
    public typealias Indeterminates = xn
    public typealias Generator = MultivariatePolynomialGenerator<xn>
    public typealias BaseRing = R

    public var elements: [Generator : R]
    public init(elements: [Generator : R]) {
        self.elements = elements.exclude{ $0.value.isZero }
    }
    
    public static var zero: Self {
        .init(elements: [:])
    }
    
    public static func elementarySymmetric(_ i: Int) -> Self {
        assert(xn.isFinite)
        assert(i >= 0)
        
        let n = xn.numberOfIndeterminates
        if i > n {
            return .zero
        }
        
        let exponents = (0 ..< n).choose(i).map { combi -> [Int] in
            // e.g.  [0, 1, 3] -> (1, 1, 0, 1)
            let l = combi.last ?? 0
            return (0 ... l).map { combi.contains($0) ? 1 : 0 }
        }
        
        let coeffs = Dictionary(pairs: exponents.map{ ($0, R.identity) } )
        return .init(coeffs: coeffs)
    }
}

public typealias BivariatePolynomial<_x: PolynomialIndeterminate, _y: PolynomialIndeterminate, R: Ring> =
    MultivariatePolynomial<BivariatePolynomialIndeterminates<_x, _y>, R>

public typealias TrivariatePolynomial<_x: PolynomialIndeterminate, _y: PolynomialIndeterminate, _z: PolynomialIndeterminate, R: Ring> =
    MultivariatePolynomial<TrivariatePolynomialIndeterminates<_x, _y, _z>, R>

public typealias FiniteVariatePolynomial<_x: PolynomialIndeterminate, n: StaticSizeType, R: Ring> =
    MultivariatePolynomial<FiniteVariatePolynomialIndeterminates<_x, n>, R>

public typealias InifiniteVariatePolynomial<_x: PolynomialIndeterminate, R: Ring> =
    MultivariatePolynomial<InfiniteVariatePolynomialIndeterminates<_x>, R>
