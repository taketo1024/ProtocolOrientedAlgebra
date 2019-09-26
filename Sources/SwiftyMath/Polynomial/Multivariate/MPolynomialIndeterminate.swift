//
//  Indeterminate.swift
//  Sample
//
//  Created by Taketo Sano on 2018/05/11.
//

public struct _xy: MPolynomialIndeterminate {
    public static let numberOfIndeterminates = 2
    public static func symbol(_ i: Int) -> String {
        switch i {
        case 0: return "x"
        case 1: return "y"
        default: fatalError()
        }
    }
}

public struct _xyz: MPolynomialIndeterminate {
    public static let numberOfIndeterminates = 3
    public static func symbol(_ i: Int) -> String {
        switch i {
        case 0: return "x"
        case 1: return "y"
        case 2: return "z"
        default: fatalError()
        }
    }
}

public struct _xn: MPolynomialIndeterminate {
    public static let numberOfIndeterminates = Int.max
    public static func symbol(_ i: Int) -> String {
        "x\(Format.sub(i))"
    }
}

public protocol MPolynomialIndeterminate {
    static var isFinite: Bool { get }
    static var numberOfIndeterminates: Int { get }
    static func symbol(_ i: Int) -> String
    static func degree(_ i: Int) -> Int
}

public extension MPolynomialIndeterminate {
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
