//
//  PowerSeries.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/12.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public struct PowerSeries<x: PolynomialIndeterminate, R: Ring>: Ring, Module {
    public typealias BaseRing = R
    public let coeffs: (Int) -> R
    
    public init(from n: 𝐙) {
        self.init() { i in
            (i == 0) ? R(from: n) : .zero
        }
    }
    
    public init(_ coeffs: R ...) {
        self.init(coeffs)
    }
    
    public init(_ coeffs: [R]) {
        self.init() { i in
            (i < coeffs.count) ? coeffs[i] : .zero
        }
    }
    
    public init(_ coeffs: @escaping ((Int) -> R)) {
        self.coeffs = coeffs
    }
    
    public var inverse: Self? {
        guard let b0 = constantTerm.inverse else {
            return nil
        }
        
        var list = [b0]
        func invCoeff(_ i: Int) -> R {
            if i < list.count { return list[i] }
            let b_i = -b0 * (1 ... i).sum{ j in coeff(j) * invCoeff(i - j) }
            list.append(b_i)
            return b_i
        }
        return .init { i in invCoeff(i) }
    }
    
    public func coeff(_ i: Int) -> R {
        assert(i >= 0)
        return coeffs(i)
    }
    
    public var constantTerm: R {
        self.coeff(0)
    }
    
    public func map(_ f: @escaping (R) -> R ) -> Self {
        .init { i in
            f( self.coeffs(i) )
        }
    }
    
    public func polynomial(upTo degree: Int) -> Polynomial<x, R> {
        Polynomial(coeffs: (0 ... degree).map{ i in coeff(i) } )
    }
    
    public func evaluate(at a: R, upTo degree: Int) -> R {
        polynomial(upTo: degree).evaluate(by: a)
    }
    
    public static func == (f: Self, g: Self) -> Bool {
        fatalError("== not available for PowerSeries.")
    }
    
    public static func + (f: Self, g: Self) -> Self {
        .init { i in
            f.coeff(i) + g.coeff(i)
        }
    }
    
    public static prefix func - (f: Self) -> Self {
        f.map { -$0 }
    }
    
    public static func * (f: Self, g: Self) -> Self {
        .init { i in
            (0 ... i).sum { j in
                f.coeff(j) * g.coeff(i - j)
            }
        }
    }
    
    public static func * (r: R, f: Self) -> Self {
        f.map { r * $0 }
    }
    
    public static func * (f: Self, r: R) -> Self {
        f.map { $0 * r }
    }
    
    public var description: String {
        Format.terms("+", (0 ..< 5).map{ n in (coeff(n), "x", n) }) + " ..."
    }
    
    public static var symbol: String {
        "\(R.symbol)[[x]]"
    }
}

public extension PowerSeries {
    static var exponential: Self {
        .init { n in
            R(from: n.factorial).inverse!
        }
    }
    
    static func geometricSeries(_ r: R) -> Self {
        .init { n in r.pow(n) }
    }
}
