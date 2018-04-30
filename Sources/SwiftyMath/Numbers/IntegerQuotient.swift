//
//  IntegerQuotient.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/04/01.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public typealias 𝐙₂ = IntegerQuotientRing<_2>

// MEMO waiting for parametrized extension.
// see: https://github.com/apple/swift/blob/master/docs/GenericsManifesto.md#parameterized-extensions

public protocol _IntegerIdeal: EuclideanIdeal {
    associatedtype n: _Int
}

public struct IntegerIdeal<n: _Int>: _IntegerIdeal {
    public typealias Super = 𝐙
    public static var mod: 𝐙 {
        return n.intValue
    }
}

extension IntegerIdeal: MaximalIdeal where n: _Prime {}

public typealias IntegerQuotientRing<n: _Int> = QuotientRing<𝐙, IntegerIdeal<n>>

extension IntegerQuotientRing: FiniteSetType where Base == 𝐙, Sub: _IntegerIdeal {
    public static var allElements: [QuotientRing<Base, Sub>] {
        return (0 ..< Sub.mod).map{ QuotientRing($0) }
    }
    
    public static var countElements: Int {
        return Sub.mod
    }
}
