//
//  Z_2.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/06/10.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public struct Z_2: Field {
    public let value: UInt8

    public init(_ value: UInt8) {
        self.value = value & 1
    }

    public init(intValue value: Int) {
        self.init(UInt8(truncatingIfNeeded: value))
    }

    public var inverse: Z_2? {
        return (value == 1) ? self : nil
    }

    public static var zero: Z_2 {
        return Z_2(0)
    }

    public static func ==(a: Z_2, b: Z_2) -> Bool {
        return a.value == b.value
    }

    public static func +(a: Z_2, b: Z_2) -> Z_2 {
        return Z_2(a.value ^ b.value)
    }

    public static prefix func -(a: Z_2) -> Z_2 {
        return a
    }

    public static func *(a: Z_2, b: Z_2) -> Z_2 {
        return Z_2(a.value * b.value)
    }

    public var hashValue: Int {
        return Int(value)
    }

    public var description: String {
        return "\(value)"
    }

    public static var symbol: String {
        return "Z/2"
    }

}
