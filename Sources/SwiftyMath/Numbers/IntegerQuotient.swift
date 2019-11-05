//
//  IntegerQuotient.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/04/01.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

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

public struct IntegerQuotientRing<n: StaticSizeType>: QuotientRingType, FiniteSetType, Hashable {
    public typealias Ideal = IntegerIdeal<n>
    public typealias Sub = Ideal

    public let representative: 𝐙
    
    public init(_ x: 𝐙) {
        self.representative = Ideal.quotientRepresentative(of: x)
    }
    
    public static var mod: 𝐙 {
        n.intValue
    }
    
    public static var allElements: [Self] {
        (0 ..< mod).map{ .init($0) }
    }
    
    public static var countElements: Int {
        mod
    }
    
    public static var symbol: String {
        "𝐙\(Format.sub(mod))"
    }
}

extension IntegerQuotientRing: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension IntegerQuotientRing: EuclideanRing, Field where n: PrimeSizeType {}
