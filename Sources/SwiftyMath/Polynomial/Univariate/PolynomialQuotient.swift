//
//  AlgebraicExtension.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/04/09.
//

// memo: Supports only Field-coeffs.
public protocol PolynomialTP {
    associatedtype Indeterminate: PolynomialIndeterminate
    associatedtype CoeffRing: Field
    typealias PolynomialType = Polynomial<Indeterminate, CoeffRing>
    static var value: PolynomialType { get }
}

public protocol IrrPolynomialTP: PolynomialTP {}

public struct PolynomialIdeal<p: PolynomialTP>: EuclideanIdeal {
    public typealias CoeffRing = p.CoeffRing
    public typealias Super = Polynomial<p.Indeterminate, CoeffRing>
    
    public static var mod: Polynomial<p.Indeterminate, CoeffRing> {
        p.value
    }
}

extension PolynomialIdeal: MaximalIdeal where p: IrrPolynomialTP {}

public struct PolynomialQuotientRing<p: PolynomialTP>: QuotientRingType {
    public typealias Base = p.PolynomialType
    public typealias Sub = PolynomialIdeal<p>
    
    private let f: Base
    
    public init(from n: 𝐙) {
        self.init(Base(from: n))
    }
    
    public init(_ x: Base.CoeffRing) {
        self.init(Base(x))
    }
    
    public init(_ f: Base) {
        self.f = Sub.normalizedInQuotient(f)
    }
    
    public var representative: Base {
        f
    }
}

extension PolynomialQuotientRing: EuclideanRing, Field where p: IrrPolynomialTP { }

extension PolynomialQuotientRing: ExpressibleByIntegerLiteral where Base.CoeffRing: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Base.CoeffRing.IntegerLiteralType
    public init(integerLiteral value: IntegerLiteralType) {
        let a = Base.CoeffRing(integerLiteral: value)
        self.init(Base(a))
    }
}
