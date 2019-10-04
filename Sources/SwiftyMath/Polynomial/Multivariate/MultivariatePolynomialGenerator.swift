//
//  MultivariatePolynomialGenerator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/02.
//

public protocol MultivariatePolynomialGeneratorType: PolynomialGeneratorType where Exponent == [Int] {
    associatedtype Indeterminates: MultivariatePolynomialIndeterminates
}

extension MultivariatePolynomialGeneratorType {
    public var degree: Int {
        Indeterminates.totalDegree(exponents: exponent)
    }
    
    public static var identity: Self {
        .init([])
    }
    
    public static func *(_ f: Self, _ g: Self) -> Self {
        let exponents = f.exponent.merging(g.exponent, filledWith: 0, mergedBy: +)
        return .init(exponents)
    }
    
    public static func < (f: Self, g: Self) -> Bool {
        f.exponent < g.exponent
    }
    
    public func evaluate<R: Ring>(by values: [R]) -> R {
        assert(Indeterminates.isFinite && Indeterminates.numberOfIndeterminates == values.count)
        return (0 ..< Indeterminates.numberOfIndeterminates).multiply { i in
            let (a, n) = (values[i], exponent.indices.contains(i) ? exponent[i] : 0)
            return a.pow(n)
        }
    }
    
    public var description: String {
        exponent.enumerated().compactMap { (i, n) -> String? in
            if n != 0 {
                let x = Indeterminates.symbol(i)
                return (n == 1) ? x : "\(x)\(Format.sup(n))"
            } else {
                return nil
            }
        }.joined()
    }
}

public struct MultivariatePolynomialGenerator<xn: MultivariatePolynomialIndeterminates>: MultivariatePolynomialGeneratorType {
    public typealias Indeterminates = xn
    public let exponent: [Int]
    
    public init(_ exponents: [Int]) {
        assert(exponents.allSatisfy{ $0 >= 0 })
        self.exponent = exponents.dropLast{ $0 == 0 }
    }
    
    public var inverse: Self? {
        (exponent.isEmpty) ? self : nil
    }
}

