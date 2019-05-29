//
//  AlgebraicExtension.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/04/09.
//

import Foundation

public struct AlgebraicExtension<K: Field, p: IrrPolynomialTP>: QuotientRingType, Field where K == p.CoeffRing {
    public typealias Base = p.PolynomialType
    public typealias Sub = PolynomialIdeal<p>
    
    private let f: Base
    
    public init(from n: 𝐙) {
        self.init(Polynomial(K(from: n)))
    }
    
    public init(_ x: K) {
        self.init(Polynomial(x))
    }
    
    public init(_ f: Base) {
        self.f = Sub.normalizedInQuotient(f)
    }
    
    public var representative: Base {
        return f
    }
}

extension AlgebraicExtension: ExpressibleByIntegerLiteral where K: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = K.IntegerLiteralType
    public init(integerLiteral value: IntegerLiteralType) {
        let a = K(integerLiteral: value)
        self.init(Polynomial(a))
    }
}
