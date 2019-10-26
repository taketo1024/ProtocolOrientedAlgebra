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
    public init(_ exponent: [Int: Int]) {
        if let n = exponent.keys.max() {
            let list = (0 ... n).map { i in exponent[i] ?? 0 }
            self.init(list)
        } else {
            self.init([])
        }
    }
    
    public static var identity: Self {
        .init([])
    }
    
    public var degree: Int {
        Indeterminates.totalDegree(exponents: exponent)
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
    
    public static func monomials(ofTotalExponent total: Int) -> [Self] {
        assert(Indeterminates.isFinite)
        return monomials(ofTotalExponent: total, usingIndeterminates: (0 ..< Indeterminates.numberOfIndeterminates).toArray())
    }

    public static func monomials(ofTotalExponent total: Int, usingIndeterminates indices: [Int]) -> [Self] {
        typealias xn = Indeterminates
        guard !indices.isEmpty else {
            return (total == 0) ? [.identity] : []
        }
        
        func generate(_ total: Int, _ i: Int) -> [[Int : Int]] {
            if i == 0 {
                return [[indices[i] : total]]
            } else {
                return (0 ... total).flatMap { e_i -> [[Int : Int]] in
                    generate(total - e_i, i - 1).map { exponents in
                        exponents.merging([indices[i] : e_i])
                    }
                }
            }
        }
        
        return generate(total, indices.count - 1).map { .init($0) }
    }

    
    public var description: String {
        exponent.isEmpty
            ? "1"
            : exponent.enumerated().compactMap { (i, n) -> String? in
                (n > 0) ? Format.power(Indeterminates.symbol(i), n) : nil
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

