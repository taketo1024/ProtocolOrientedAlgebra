//
//  PolynomialIdeal.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/09/23.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public protocol PolynomialTP {
    associatedtype CoeffRing: Ring
    static var value: Polynomial<CoeffRing> { get }
}

public protocol IrrPolynomialTP: PolynomialTP {}

// memo: Supports only Field-coeffs.
public struct PolynomialIdeal<p: PolynomialTP>: EuclideanIdeal where p.CoeffRing: Field {
    public typealias CoeffRing = p.CoeffRing
    public typealias Super = Polynomial<CoeffRing>
    public static var mod: Polynomial<CoeffRing> {
        return p.value
    }
}

extension PolynomialIdeal: MaximalIdeal where p: IrrPolynomialTP {}
