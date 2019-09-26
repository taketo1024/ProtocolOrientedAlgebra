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

public struct IntegerIdeal<n: StaticSizeType>: EuclideanIdeal {
    public typealias Super = 𝐙
    public static var mod: 𝐙 {
        n.intValue
    }
}

extension IntegerIdeal: MaximalIdeal where n: PrimeSizeType {}

public struct IntegerQuotientRing<n: StaticSizeType>: QuotientRingType, FiniteSetType, Hashable, ExpressibleByIntegerLiteral, Codable {
    public typealias Base = 𝐙
    public typealias Sub = IntegerIdeal<n>
    
    public let value: 𝐙
    public init(_ value: 𝐙) {
        let mod = n.intValue
        self.value = (value >= 0) ? value % mod : (value % mod + mod)
    }
    
    public init(integerLiteral value: 𝐙) {
        self.init(value)
    }
    
    public var representative: 𝐙 {
        value
    }
    
    public static var mod: 𝐙 {
        n.intValue
    }
    
    public static var allElements: [IntegerQuotientRing<n>] {
        (0 ..< mod).map{ IntegerQuotientRing($0) }
    }
    
    public static var countElements: Int {
        mod
    }
    
    public static var symbol: String {
        "𝐙\(Format.sub(mod))"
    }
}

extension IntegerQuotientRing: EuclideanRing, Field where n: PrimeSizeType {}
