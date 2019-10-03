//
//  MultivariatePolynomialIndeterminates.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/02.
//

public protocol MultivariatePolynomialIndeterminates {
    static var isFinite: Bool { get }
    static var numberOfIndeterminates: Int { get }
    static func symbol(_ i: Int) -> String
    static func degree(_ i: Int) -> Int
}

public extension MultivariatePolynomialIndeterminates {
    static var isFinite: Bool {
        numberOfIndeterminates < Int.max
    }
    
    static func degree(_ i: Int) -> Int {
        1
    }
    
    static func totalDegree(exponents: [Int]) -> Int {
        assert(!isFinite || exponents.count <= numberOfIndeterminates)
        return exponents.enumerated().sum { (i, k) in
            k * degree(i)
        }
    }
}

public struct BivariatePolynomialIndeterminates<x: PolynomialIndeterminate, y: PolynomialIndeterminate>: MultivariatePolynomialIndeterminates {
    public static var numberOfIndeterminates: Int { 2 }
    
    public static func symbol(_ i: Int) -> String {
        switch i {
        case 0: return x.symbol
        case 1: return y.symbol
        default: fatalError()
        }
    }
    
    public static func degree(_ i: Int) -> Int {
        switch i {
        case 0: return x.degree
        case 1: return y.degree
        default: fatalError()
        }
    }
}

public struct TrivariatePolynomialIndeterminates<x: PolynomialIndeterminate, y: PolynomialIndeterminate, z: PolynomialIndeterminate>: MultivariatePolynomialIndeterminates {
    public static var numberOfIndeterminates: Int { 3 }
    
    public static func symbol(_ i: Int) -> String {
        switch i {
        case 0: return x.symbol
        case 1: return y.symbol
        case 2: return z.symbol
        default: fatalError()
        }
    }
    
    public static func degree(_ i: Int) -> Int {
        switch i {
        case 0: return x.degree
        case 1: return y.degree
        case 2: return z.degree
        default: fatalError()
        }
    }
}

public struct FiniteVariatePolynomialIndeterminates<x: PolynomialIndeterminate, n: StaticSizeType>: MultivariatePolynomialIndeterminates {
    public static var numberOfIndeterminates: Int { n.intValue }
    
    public static func symbol(_ i: Int) -> String {
        "\(x.symbol)\(Format.sub(i))"
    }
    
    public static func degree(_ i: Int) -> Int {
        x.degree
    }
}

public struct InfiniteVariatePolynomialIndeterminates<x: PolynomialIndeterminate>: MultivariatePolynomialIndeterminates {
    public static var numberOfIndeterminates: Int { Int.max }
    
    public static func symbol(_ i: Int) -> String {
        "\(x.symbol)\(Format.sub(i))"
    }
    
    public static func degree(_ i: Int) -> Int {
        x.degree
    }
}

