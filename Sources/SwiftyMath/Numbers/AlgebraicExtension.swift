//
//  AlgebraicExtension.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/04/09.
//

public struct AlgebraicExtension<K: Field, p: IrrPolynomialTP>: QuotientRingType, Field where K == p.CoeffRing {
    public typealias Base = Polynomial<K>
    public typealias Sub = PolynomialIdeal<p>

    private let p: Base

    public init(from n: 𝐙) {
        self.init(Polynomial(K(from: n)))
    }

    public init(from q: 𝐐) {
        self.init(Polynomial(K(from: q)))
    }

    public init(_ x: K) {
        self.init(Polynomial(x))
    }

    public init(_ x: Polynomial<K>) {
        self.p = Sub.normalizedInQuotient(x)
    }

    public var representative: Polynomial<K> {
        return p
    }
}

extension AlgebraicExtension: ExpressibleByIntegerLiteral where K: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = K.IntegerLiteralType
    public init(integerLiteral value: IntegerLiteralType) {
        let a = K(integerLiteral: value)
        self.init(Polynomial(a))
    }
}
