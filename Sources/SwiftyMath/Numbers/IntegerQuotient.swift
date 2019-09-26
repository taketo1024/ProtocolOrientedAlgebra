//
//  IntegerQuotient.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/04/01.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public protocol PrimeSizeType: SizeType {}
extension _2: PrimeSizeType {}
extension _3: PrimeSizeType {}
extension _5: PrimeSizeType {}
extension _7: PrimeSizeType {}
// add more if necessary

public typealias 𝐙₂ = IntegerQuotientRing<_2>
// add more if necessary

// MEMO: waiting for parameterized extension.
public protocol IntegerIdealType: EuclideanIdeal where Super == 𝐙 {}

extension IntegerIdealType {
    public static func quotientRepresentative(of a: 𝐙) -> 𝐙 {
        (a >= 0) ? a % mod : (a % mod + mod)
    }
}

public struct IntegerIdeal<n: StaticSizeType>: IntegerIdealType {
    public static var mod: 𝐙 {
        n.intValue
    }
}

extension IntegerIdeal: MaximalIdeal where n: PrimeSizeType {}

public typealias IntegerQuotientRing<n: StaticSizeType> = QuotientRing<Int, IntegerIdeal<n>>

extension QuotientRing: FiniteSetType where Sub: IntegerIdealType {
    public static var mod: 𝐙 {
        Sub.mod
    }
    
    public static var allElements: [QuotientRing] {
        (0 ..< mod).map{ QuotientRing($0) }
    }
    
    public static var countElements: Int {
        mod
    }
    
    public static var symbol: String {
        "𝐙\(Format.sub(mod))"
    }
}
