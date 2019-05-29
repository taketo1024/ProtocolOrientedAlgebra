//
//  Quaternion
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/16.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//
//  see: https://en.wikipedia.org/wiki/𝐇

import Foundation

// memo: a skew field, i.e. product is non-commutative.

public typealias 𝐇 = Quaternion

public struct Quaternion: Ring, NormedSpace, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    public typealias IntegerLiteralType = 𝐙
    public typealias FloatLiteralType = Double
    
    private let x: 𝐑
    private let y: 𝐑
    private let z: 𝐑
    private let w: 𝐑

    public init(integerLiteral n: Int) {
        self.init(n)
    }
    
    public init(floatLiteral x: Double) {
        self.init(𝐑(x))
    }
    
    public init(from x: 𝐙) {
        self.init(x)
    }
    
    public init(_ x: 𝐙) {
        self.init(𝐑(x), 0, 0, 0)
    }
    
    public init(_ x: 𝐐) {
        self.init(𝐑(x), 0, 0, 0)
    }
    
    public init(_ x: 𝐑) {
        self.init(x, 0, 0, 0)
    }
    
    public init(_ z: 𝐂) {
        self.init(z.realPart, z.imaginaryPart, 0, 0)
    }
    
    public init(_ z: 𝐂, _ w: 𝐂) {
        self.init(z.realPart, z.imaginaryPart, w.realPart, w.imaginaryPart)
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
        return √(x * x + y * y + z * z + w * w)
    }
    
    public var norm: 𝐑 {
        return abs
    }
    
    public var conjugate: 𝐇 {
        return 𝐇(x, -y, -z, -w)
    }

    public var inverse: 𝐇? {
        let r2 = x * x + y * y + z * z + w * w
        return r2 == 0 ? nil : 𝐇(x / r2, -y / r2, -z / r2, -w / r2)
    }
    
    public static func +(a: 𝐇, b: 𝐇) -> 𝐇 {
        return 𝐇(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)
    }
    
    public static prefix func -(a: 𝐇) -> 𝐇 {
        return 𝐇(-a.x, -a.y, -a.z, -a.w)
    }
    
    public static func *(a: 𝐇, b: 𝐇) -> 𝐇 {
        let x = a.x * b.x - (a.y * b.y + a.z * b.z + a.w * b.w)
        let y = a.x * b.y +  a.y * b.x + a.z * b.w - a.w * b.z
        let z = a.x * b.z + -a.y * b.w + a.z * b.x + a.w * b.y
        let w = a.x * b.w +  a.y * b.z - a.z * b.y + a.w * b.x
        return 𝐇(x, y, z, w)
    }
    
    public func isApproximatelyEqualTo(_ b: 𝐇, error e: 𝐑? = nil) -> Bool {
        return
            self.x.isApproximatelyEqualTo(b.x, error: e) &&
            self.y.isApproximatelyEqualTo(b.y, error: e) &&
            self.z.isApproximatelyEqualTo(b.z, error: e) &&
            self.w.isApproximatelyEqualTo(b.w, error: e)
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
