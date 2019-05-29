//
//  VectorSpace.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/18.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public protocol VectorSpace: Module where CoeffRing: Field { }

public protocol FiniteDimVectorSpace: VectorSpace {
    static var dim: Int { get }
    static var standardBasis: [Self] { get }
    var standardCoordinates: [CoeffRing] { get }
}

public typealias ProductVectorSpace<X: VectorSpace, Y: VectorSpace> = ProductModule<X, Y>
extension ProductVectorSpace: VectorSpace where Left: VectorSpace, Right: VectorSpace, Left.CoeffRing == Right.CoeffRing {}

public typealias AsVectorSpace<R: Field> = AsModule<R>

extension AsVectorSpace: VectorSpace, FiniteDimVectorSpace where R: Field {
    public static var dim: Int {
        return 1
    }
    
    public static var standardBasis: [AsVectorSpace<R>] {
        return [AsVectorSpace(.identity)]
    }
    
    public var standardCoordinates: [R] {
        return [value]
    }
}
