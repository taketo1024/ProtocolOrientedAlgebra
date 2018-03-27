//
//  Complex.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/03/16.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public typealias 𝐂 = ComplexNumber

public struct ComplexNumber: Field, NormedSpace, ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double

    private let x: 𝐑
    private let y: 𝐑

    public init(from x: 𝐙) {
        self.init(𝐑(x), 0)
    }

    public init(floatLiteral x: Double) {
        self.init(𝐑(x))
    }

    public init(from r: 𝐐) {
        self.init(𝐑(r), 0)
    }

    public init(_ x: 𝐑) {
        self.init(x, 0)
    }

    public init(_ x: 𝐑, _ y: 𝐑) {
        self.x = x
        self.y = y
    }

    public init(r: 𝐑, θ: 𝐑) {
        self.init(r * cos(θ), r * sin(θ))
    }

    public static var imaginaryUnit: 𝐂 {
        return 𝐂(0, 1)
    }

    public var real: 𝐑 {
        return x
    }

    public var imaginary: 𝐑 {
        return y
    }

    public var norm: 𝐑 {
        return sqrt(x * x + y * y)
    }

    public var arg: 𝐑 {
        let r = self.norm
        if(r == 0) {
            return 0
        }

        let t = acos(x / r)
        return (y >= 0) ? t : 2 * π - t
    }

    public var conjugate: 𝐂 {
        return 𝐂(x, -y)
    }

    public var inverse: 𝐂? {
        let r2 = x * x + y * y
        return r2 == 0 ? nil : 𝐂(x / r2, -y / r2)
    }

    public static func ==(lhs: 𝐂, rhs: 𝐂) -> Bool {
        return (lhs.x == rhs.x) && (lhs.y == rhs.y)
    }

    public static func +(a: 𝐂, b: 𝐂) -> 𝐂 {
        return 𝐂(a.x + b.x, a.y + b.y)
    }

    public static prefix func -(a: 𝐂) -> 𝐂 {
        return 𝐂(-a.x, -a.y)
    }

    public static func *(a: 𝐂, b: 𝐂) -> 𝐂 {
        return 𝐂(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x)
    }

    public var hashValue: Int {
        let p = 104743
        return (x.hashValue % p) &+ (y.hashValue % p) * p
    }

    public var description: String {
        return (x != 0 && y != 0) ? "\(x) + \(y)i" :
                         (y != 0) ? "\(y)i"
                                  : "\(x)"
    }

    public static var symbol: String {
        return "𝐂"
    }
}
