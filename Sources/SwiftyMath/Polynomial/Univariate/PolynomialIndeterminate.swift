//
//  Indeterminate.swift
//  Sample
//
//  Created by Taketo Sano on 2018/05/11.
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

public struct _x: PolynomialIndeterminate {
    public static let symbol = "x"
}

public struct _y: PolynomialIndeterminate {
    public static let symbol = "y"
}

public struct _z: PolynomialIndeterminate {
    public static let symbol = "z"
}

public struct _t: PolynomialIndeterminate {
    public static let symbol = "t"
}
