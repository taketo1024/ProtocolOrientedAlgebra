//
//  AlgebraicExtension.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/04/09.
//

// memo: Supports only Field-coeffs.
public protocol PolynomialTP {
    associatedtype Indeterminate: PolynomialIndeterminate
    associatedtype BaseRing: Field
    typealias BasePolynomial = Polynomial<Indeterminate, BaseRing>
    static var value: BasePolynomial { get }
}

public struct PolynomialIdeal<p: PolynomialTP>: EuclideanIdeal {
    public typealias p = p
    public typealias Super = Polynomial<p.Indeterminate, p.BaseRing>
    public static var mod: Polynomial<p.Indeterminate, p.BaseRing> {
        p.value
    }
}

public protocol IrrPolynomialTP: PolynomialTP {}
extension PolynomialIdeal: MaximalIdeal where p: IrrPolynomialTP {}

// MEMO: This causes seg-fault in Swift 5.1
//
//public typealias PolynomialQuotientRing<p: PolynomialTP> = QuotientRing<p.BasePolynomial, PolynomialIdeal<p>>
//
//extension PolynomialQuotientRing where Sub: PolynomialIdealType {
//    public init(_ r: R.BaseRing) {
//        self.init( R(r) )
//    }
//}


public struct PolynomialQuotientRing<p: PolynomialTP>: QuotientRingType {
    public typealias Base = p.BasePolynomial
    public typealias Sub = PolynomialIdeal<p>
    
    private let f: Base
    
    public init(from n: 𝐙) {
        self.init(Base(from: n))
    }
    
    public init(_ x: Base.BaseRing) {
        self.init(Base(x))
    }
    
    public init(_ f: Base) {
        self.f = Sub.quotientRepresentative(of: f)
    }
    
    public var representative: Base {
        f
    }
}

extension PolynomialQuotientRing: EuclideanRing, Field where p: IrrPolynomialTP { }

extension PolynomialQuotientRing: ExpressibleByIntegerLiteral where Base.BaseRing: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Base.BaseRing.IntegerLiteralType
    public init(integerLiteral value: IntegerLiteralType) {
        let a = Base.BaseRing(integerLiteral: value)
        self.init(Base(a))
    }
}

public typealias AlgebraicExtension<F, p: IrrPolynomialTP> = PolynomialQuotientRing<p> where p.BaseRing == F
