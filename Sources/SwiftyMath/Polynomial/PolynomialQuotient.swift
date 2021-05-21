//
//  AlgebraicExtension.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/04/09.
//

public protocol PolynomialTP {
    associatedtype BasePolynomial: PolynomialType
    typealias BaseRing = BasePolynomial.BaseRing
    static var value: BasePolynomial { get }
}

public protocol IrrPolynomialTP: PolynomialTP {}

public struct PolynomialIdeal<p: PolynomialTP>: EuclideanIdeal where p.BasePolynomial: EuclideanRing {
    public typealias Super = p.BasePolynomial
    public typealias BaseRing = p.BasePolynomial.BaseRing
    
    public static var generator: Super {
        p.value
    }
}

extension PolynomialIdeal: MaximalIdeal where p: IrrPolynomialTP {}

public struct PolynomialQuotientRing<P, p: PolynomialTP>: EuclideanQuotientRing where P == p.BasePolynomial, P: EuclideanRing {
    public typealias Base = P
    public typealias Mod = PolynomialIdeal<p>

    public let representative: P
    public init(_ a: P) {
        self.representative = Self.reduce(a)
    }
    
    public init(_ a: P.BaseRing) {
        self.init(P(a))
    }
}

extension PolynomialQuotientRing: ExpressibleByIntegerLiteral where Base: ExpressibleByIntegerLiteral {}
extension PolynomialQuotientRing: EuclideanRing, Field where p: IrrPolynomialTP {}
