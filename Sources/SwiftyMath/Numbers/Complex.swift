//
//  Complex.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/16.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public typealias 𝐂 = ComplexNumber

public struct ComplexNumber: Field, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    public typealias IntegerLiteralType = Int
    public typealias FloatLiteralType = Double
    
    private let x: 𝐑
    private let y: 𝐑
    
    public init(integerLiteral n: Int) {
        self.init(n)
    }
    
    public init(floatLiteral x: Double) {
        self.init(𝐑(x))
    }
    
    public init(from x: 𝐙) {
        self.init(x)
    }
    
    public init(from r: 𝐐) {
        self.init(r)
    }
    
    public init(_ x: 𝐙) {
        self.init(𝐑(x), 0)
    }
    
    public init(_ x: 𝐐) {
        self.init(𝐑(x), 0)
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
    
    public var realPart: 𝐑 {
        return x
    }
    
    public var imaginaryPart: 𝐑 {
        return y
    }
    
    public var abs: 𝐑 {
        return √(x * x + y * y)
    }
    
    public var arg: 𝐑 {
        let r = self.abs
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
    
    public static func +(a: 𝐂, b: 𝐂) -> 𝐂 {
        return 𝐂(a.x + b.x, a.y + b.y)
    }
    
    public static prefix func -(a: 𝐂) -> 𝐂 {
        return 𝐂(-a.x, -a.y)
    }
    
    public static func *(a: 𝐂, b: 𝐂) -> 𝐂 {
        return 𝐂(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x)
    }
    
    public static func random(in real: Range<𝐑>, _ imaginary: Range<𝐑>) -> 𝐂 {
        return .init(.random(in: real), .random(in: imaginary))
    }
    
    public static func random(in real: ClosedRange<𝐑>, _ imaginary: ClosedRange<𝐑>) -> 𝐂 {
        return .init(.random(in: real), .random(in: imaginary))
    }
    
    public static func random(radius r: 𝐑) -> 𝐂 {
        return .init(r: .random(in: 0 ... r), θ: .random(in: 0 ... 2 * π))
    }
    
    public func isApproximatelyEqualTo(_ z: 𝐂, error e: 𝐑? = nil) -> Bool {
        return self.realPart.isApproximatelyEqualTo(z.realPart, error: e) &&
               self.imaginaryPart.isApproximatelyEqualTo(z.imaginaryPart, error: e)
    }
    
    public var description: String {
        return (x != 0 && y != 0) ? "\(x) + \(y)i" :
                         (y == 1) ? "i" :
                         (y != 0) ? "\(y)i"
                                  : "\(x)"
    }
    
    public static var symbol: String {
        return "𝐂"
    }
}

public protocol ComplexSubset {
    var asComplex: 𝐂 { get }
}

extension 𝐙: ComplexSubset {
    public var asComplex: 𝐂 {
        return 𝐂(self)
    }
}

extension 𝐐: ComplexSubset {
    public var asComplex: 𝐂 {
        return 𝐂(self)
    }
}

extension 𝐑: ComplexSubset {
    public var asComplex: 𝐂 {
        return 𝐂(self)
    }
}
