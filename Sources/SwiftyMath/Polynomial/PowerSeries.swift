//
//  PowerSeries.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/12.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public struct PowerSeries<K: Field>: Ring, Module {
    public typealias CoeffRing = K
    public let coeffs: (Int) -> K
    
    public init(from n: 𝐙) {
        self.init() { i in
            (i == 0) ? K(from: n) : .zero
        }
    }
    
    public init(_ coeffs: K ...) {
        self.init(coeffs)
    }
    
    public init(_ coeffs: [K]) {
        self.init() { i in
            (i < coeffs.count) ? coeffs[i] : .zero
        }
    }
    
    public init(_ coeffs: @escaping ((Int) -> K)) {
        self.coeffs = coeffs
    }
    
    public var inverse: PowerSeries<K>? {
        guard let b0 = constantTerm.inverse else {
            return nil
        }
        
        var list = [b0]
        func invCoeff(_ i: Int) -> K {
            if i < list.count { return list[i] }
            let b_i = -b0 * (1 ... i).sum{ j in coeff(j) * invCoeff(i - j) }
            list.append(b_i)
            return b_i
        }
        return PowerSeries<K> { i in invCoeff(i) }
    }
    
    public func coeff(_ i: Int) -> K {
        assert(i >= 0)
        return coeffs(i)
    }
    
    public var constantTerm: K {
        return self.coeff(0)
    }
    
    public func map(_ f: @escaping (K) -> K ) -> PowerSeries<K> {
        return PowerSeries<K>.init() { i in
            f( self.coeffs(i) )
        }
    }
    
    public func polynomial(upTo degree: Int) -> Polynomial<K> {
        return Polynomial(coeffs: (0 ... degree).map{ i in coeff(i) } )
    }
    
    public func evaluate(_ x: K, upTo degree: Int) -> K {
        return polynomial(upTo: degree).evaluate(x)
    }
    
    public func evaluate<n>(_ x: SquareMatrix<n, K>, upTo degree: Int) -> SquareMatrix<n, K> {
        return polynomial(upTo: degree).evaluate(x)
    }
    
    public static func == (f: PowerSeries<K>, g: PowerSeries<K>) -> Bool {
        fatalError("== not available for PowerSeries.")
    }
    
    public static func + (f: PowerSeries<K>, g: PowerSeries<K>) -> PowerSeries<K> {
        return PowerSeries<K>() { i in
            f.coeff(i) + g.coeff(i)
        }
    }
    
    public static prefix func - (f: PowerSeries<K>) -> PowerSeries<K> {
        return f.map { -$0 }
    }
    
    public static func * (f: PowerSeries<K>, g: PowerSeries<K>) -> PowerSeries<K> {
        return PowerSeries<K> { i in
            (0 ... i).sum { j in
                f.coeff(j) * g.coeff(i - j)
            }
        }
    }
    
    public static func * (r: K, f: PowerSeries<K>) -> PowerSeries<K> {
        return f.map { r * $0 }
    }
    
    public static func * (f: PowerSeries<K>, r: K) -> PowerSeries<K> {
        return f.map { $0 * r }
    }
    
    public var description: String {
        return Format.terms("+", (0 ..< 5).map{ n in (coeff(n), "x", n) }) + " ..."
    }
    
    public static var symbol: String {
        return "\(K.symbol)[[x]]"
    }
    
    public var hashValue: Int {
        let p = 31
        return (0 ..< 3).reduce(0){ (res, i) in res &* p &+ (coeff(i).hashValue % p) }
    }
}

public extension PowerSeries {
    public static var exponential: PowerSeries<K> {
        return PowerSeries { n in
            K(from: n.factorial).inverse!
        }
    }
    
    public static func geometricSeries(_ r: K) -> PowerSeries<K> {
        return PowerSeries { n in r.pow(n) }
    }
}
