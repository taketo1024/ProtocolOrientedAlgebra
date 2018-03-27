//
//  PolynomialIdeal.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/09/23.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public struct PolynomialIdeal<p: _Polynomial>: EuclideanIdeal {
    public typealias K = p.K
    public typealias Super = Polynomial<K>

    public static var generator: Polynomial<K> {
        return p.value
    }

    public let a: Polynomial<K>

    public init(_ a: Polynomial<K>) {
        self.a = a
    }

    public init(_ coeffs: K...) {
        self.init(Super.init(coeffs))
    }

    public var asSuper: Polynomial<K> {
        return a
    }
}
