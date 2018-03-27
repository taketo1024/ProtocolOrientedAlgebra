//
//  Z_2.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/06/10.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public typealias 𝐙₂ = FiniteField_2

public struct FiniteField_2: Field {
    public let value: UInt8

    public init(_ value: UInt8) {
        self.value = value & 1
    }

    public init(from value: 𝐙) {
        self.init(UInt8(truncatingIfNeeded: value))
    }

    public init(from r: 𝐐) {
        self.init( r.p == 0 ? 0 : 1 )
    }

    public var inverse: 𝐙₂? {
        return (value == 1) ? self : nil
    }

    public static var zero: 𝐙₂ {
        return 𝐙₂(0)
    }

    public static func ==(a: 𝐙₂, b: 𝐙₂) -> Bool {
        return a.value == b.value
    }

    public static func +(a: 𝐙₂, b: 𝐙₂) -> 𝐙₂ {
        return 𝐙₂(a.value ^ b.value)
    }

    public static prefix func -(a: 𝐙₂) -> 𝐙₂ {
        return a
    }

    public static func *(a: 𝐙₂, b: 𝐙₂) -> 𝐙₂ {
        return 𝐙₂(a.value * b.value)
    }

    public var hashValue: Int {
        return Int(value)
    }

    public var description: String {
        return "\(value)"
    }

    public static var symbol: String {
        return "𝐙₂"
    }

}
