//
//  AlgebraicExtension.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/04/09.
//

public protocol PolynomialTP {
    associatedtype BaseRing: Ring
    associatedtype Indeterminate: PolynomialIndeterminate
    typealias BasePolynomial = Polynomial<BaseRing, Indeterminate>
    static var value: BasePolynomial { get }
}

public protocol IrrPolynomialTP: PolynomialTP {}

public struct PolynomialIdeal<p: PolynomialTP>: EuclideanIdeal where p.BaseRing: Field {
    public typealias Super = p.BasePolynomial
    public static var mod: Super {
        p.value
    }
}

extension PolynomialIdeal: MaximalIdeal where p: IrrPolynomialTP {}

public typealias PolynomialQuotientRing<p: PolynomialTP> = QuotientRing<p.BasePolynomial, PolynomialIdeal<p>> where p.BaseRing: Field

extension PolynomialQuotientRing where Base: PolynomialType {
    public init(_ a: Base.BaseRing) {
        self.init(Base(a))
    }
}

public typealias AlgebraicExtension<F: Field, p: IrrPolynomialTP> = PolynomialQuotientRing<p> where p.BaseRing == F
