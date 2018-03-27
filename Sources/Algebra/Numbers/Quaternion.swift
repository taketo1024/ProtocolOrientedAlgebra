//
//  Quaternion
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/03/16.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//
//  see: https://en.wikipedia.org/wiki/𝐇

import Foundation

// memo: a skew field, i.e. product is non-commutative.

public typealias 𝐇 = Quaternion

public struct Quaternion: Ring, ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double

    private let x: 𝐑
    private let y: 𝐑
    private let z: 𝐑
    private let w: 𝐑

    public init(from x: 𝐙) {
        self.init(𝐑(x))
    }

    public init(floatLiteral x: Double) {
        self.init(𝐑(x))
    }

    public init(_ x: 𝐑) {
        self.init(x, 0, 0, 0)
    }

    public init(_ z: 𝐂) {
        self.init(z.real, z.imaginary, 0, 0)
    }

    public init(_ z: 𝐂, _ w: 𝐂) {
        self.init(z.real, z.imaginary, w.real, w.imaginary)
    }

    public init(_ x: 𝐑, _ y: 𝐑, _ z: 𝐑, _ w: 𝐑) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }

    public static var i: 𝐇 {
        return 𝐇(0, 1, 0, 0)
    }

    public static var j: 𝐇 {
        return 𝐇(0, 0, 1, 0)
    }

    public static var k: 𝐇 {
        return 𝐇(0, 0, 0, 1)
    }

    public var realPart: 𝐑 {
        return x
    }

    public var imaginaryPart: 𝐇 {
        return 𝐇(0, y, z, w)
    }

    public var abs: 𝐑 {
        return sqrt(x * x + y * y + z * z + w * w)
    }

    public var conjugate: 𝐇 {
        return 𝐇(x, -y, -z, -w)
    }

    public var inverse: 𝐇? {
        let r2 = x * x + y * y + z * z + w * w
        return r2 == 0 ? nil : 𝐇(x / r2, -y / r2, -z / r2, -w / r2)
    }

    public static func ==(lhs: 𝐇, rhs: 𝐇) -> Bool {
        return (lhs.x == rhs.x) && (lhs.y == rhs.y)
    }

    public static func +(a: 𝐇, b: 𝐇) -> 𝐇 {
        return 𝐇(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)
    }

    public static prefix func -(a: 𝐇) -> 𝐇 {
        return 𝐇(-a.x, -a.y, -a.z, -a.w)
    }

    public static func *(a: 𝐇, b: 𝐇) -> 𝐇 {
        // memo: writing `a.x * b.x - a.y * b.y - ...`
        //       would prevent the compile from passing...
        return 𝐇(
            a.x * b.x + -a.y * b.y - a.z * b.z - a.w * b.w,
            a.x * b.y + a.y * b.x + a.z * b.w - a.w * b.z,
            a.x * b.z - a.y * b.w + a.z * b.x + a.w * b.y,
            a.x * b.w + a.y * b.z - a.z * b.y - a.w * b.x
        )
    }

    public var hashValue: Int {
        let p = 31
        return [x, y, z, w].reduce(0) { (res, r) in
            res &* p &+ (r.hashValue % p)
        }
    }

    public var description: String {
        if self == .zero {
            return "0"
        } else {
            return [(x, ""), (y, "i"), (z, "j"), (w, "k")]
                .filter{ $0.0 != .zero }
                .map{ "\($0.0)\($0.1)" }
                .joined(separator: " + ")
        }
    }

    public static var symbol: String {
        return "𝐇"
    }
}
