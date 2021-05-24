//
//  IntegerQuotient.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/04/01.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public typealias 𝐙₂ = IntegerQuotientRing<_2>
// add more if necessary

public struct IntegerIdeal<n: FixedSizeType>: EuclideanIdeal {
    public typealias Super = 𝐙
    public static var generator: 𝐙 {
        n.intValue
    }
}

extension IntegerIdeal: MaximalIdeal where n: PrimeSizeType {}

public struct IntegerQuotientRing<n: FixedSizeType>: EuclideanQuotientRing, FiniteSet, Hashable, ExpressibleByIntegerLiteral {
    public typealias Base = 𝐙
    public typealias Mod = IntegerIdeal<n>

    public let representative: 𝐙
    public init(_ a: 𝐙) {
        self.representative = Self.reduce(a)
    }
    
    public static func reduce(_ a: Int) -> Int {
        (a >= 0) ? a % mod : (a % mod + mod)
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

extension IntegerQuotientRing: EuclideanRing, Field where n: PrimeSizeType {}
