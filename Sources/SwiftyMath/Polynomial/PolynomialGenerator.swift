//
//  PolynomialGenerator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/02.
//

public protocol PolynomialGeneratorType: FreeModuleGenerator, Monoid {
    associatedtype Exponent: Hashable & Comparable // Int for univariate, [Int] for multivariate
    
    init(_ exponent: Exponent)
    var exponent: Exponent { get }
    var degree: Int { get }
}

public protocol UnivariatePolynomialGeneratorType: PolynomialGeneratorType where Exponent == Int {
    associatedtype Indeterminate: PolynomialIndeterminate
}

extension UnivariatePolynomialGeneratorType {
    public var degree: Int {
        Indeterminate.degree * exponent
    }
    
    public static var identity: Self {
        .init(0)
    }
    
    public static func *(_ f: Self, _ g: Self) -> Self {
        .init(f.exponent + g.exponent)
    }
    
    public static func < (f: Self, g: Self) -> Bool {
        f.exponent < g.exponent
    }
    
    public func evaluate<R: Ring>(by a: R) -> R {
        a.pow(exponent)
    }
    
    public var description: String {
        Format.term(1, Indeterminate.symbol, exponent)
    }
}

public struct UnivariatePolynomialGenerator<x: PolynomialIndeterminate>: UnivariatePolynomialGeneratorType {
    public typealias Indeterminate = x
    public let exponent: Int
    
    public init(_ exponent: Int) {
        assert(exponent >= 0)
        self.exponent = exponent
    }
    
    public var inverse: UnivariatePolynomialGenerator? {
        (exponent == 0) ? self : nil
    }
}

public protocol UnivariateLaurentPolynomialGeneratorType: UnivariatePolynomialGeneratorType {}

public struct UnivariateLaurentPolynomialGenerator<x: PolynomialIndeterminate>: UnivariateLaurentPolynomialGeneratorType {
    public typealias Indeterminate = x
    public let exponent: Int
    
    public init(_ exponent: Int) {
        self.exponent = exponent
    }
    
    public var inverse: Self? {
        .init(-exponent)
    }
}
