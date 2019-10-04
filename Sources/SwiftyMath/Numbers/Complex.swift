//
//  Complex.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/16.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public typealias ComplexNumber = Complex<RealNumber>
public typealias 𝐂 = ComplexNumber

public struct Complex<Base: Ring>: Ring, Module {
    public typealias BaseRing = Base
    
    private let x: Base
    private let y: Base
    
    public init(from x: 𝐙) {
        self.init(Base(from: x))
    }
    
    public init(_ x: Base) {
        self.init(x, .zero)
    }
    
    public init(_ x: Base, _ y: Base) {
        self.x = x
        self.y = y
    }
    
    public static var imaginaryUnit: Self {
        .init(.zero, .identity)
    }
    
    public var realPart: Base {
        x
    }
    
    public var imaginaryPart: Base {
        y
    }
    
    public var conjugate: Self {
        .init(x, -y)
    }

    public var inverse: Self? {
        let r2 = x * x + y * y
        if let r2Inv = r2.inverse {
            return r2Inv * conjugate
        } else {
            return nil
        }
    }
    
    public static func +(a: Self, b: Self) -> Self {
        .init(a.x + b.x, a.y + b.y)
    }
    
    public static prefix func -(a: Self) -> Self {
        .init(-a.x, -a.y)
    }
    
    public static func *(a: Base, b: Self) -> Self {
        .init(a * b.x, a * b.y)
    }
    
    public static func *(a: Self, b: Base) -> Self {
        .init(a.x * b, a.y * b)
    }
    
    public static func *(a: Self, b: Self) -> Self {
        let x = a.x * b.x - a.y * b.y
        let y = a.x * b.y + a.y * b.x
        return .init(x, y)
    }
    
    public var description: String {
        switch (x, y) {
        case (_, .zero):
            return "\(x)"
        case (.zero,  .identity):
            return "i"
        case (.zero, -.identity):
            return "-i"
        case (.zero, _):
            return "\(y)i"
        default:
            return "\(x) + \(y)i"
        }
    }

    public static var symbol: String {
        (Base.self == 𝐑.self) ? "𝐂" : "\(Base.symbol)[i]"
    }
}

extension Complex: EuclideanRing, Field where Base: Field {}

extension Complex where Base == 𝐑 {
    public init(integerLiteral n: Base.IntegerLiteralType) {
        self.init(Base(integerLiteral: n))
    }
    
    public init(floatLiteral x: Base.FloatLiteralType) {
        self.init(Base(floatLiteral: x))
    }

    public init(r: Base, θ: Base) {
        self.init(r * cos(θ), r * sin(θ))
    }
    
    public var abs: 𝐑 {
        √(x * x + y * y)
    }
    
    public var arg: 𝐑 {
        let r = self.abs
        if(r == 0) {
            return 0
        }
        
        let t = acos(x / r)
        return (y >= 0) ? t : 2 * π - t
    }
    
    public static func random(radius r: 𝐑) -> Self {
        .init(r: .random(in: 0 ... r), θ: .random(in: 0 ... 2 * π))
    }
    
    public func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self {
        .init(x.rounded(rule), y.rounded(rule))
    }
    
    public func isApproximatelyEqualTo(_ z: Self, error e: 𝐑? = nil) -> Bool {
        realPart.isApproximatelyEqualTo(z.realPart, error: e) &&
               imaginaryPart.isApproximatelyEqualTo(z.imaginaryPart, error: e)
    }
}

extension Complex where Base: Randomable & Comparable {
    public static func random(in real: Range<Base>, _ imaginary: Range<Base>) -> Self {
        .init(.random(in: real), .random(in: imaginary))
    }
    
    public static func random(in real: ClosedRange<Base>, _ imaginary: ClosedRange<Base>) -> Self {
        .init(.random(in: real), .random(in: imaginary))
    }
}

extension Complex: Hashable where Base: Hashable {}

public protocol ComplexSubset {
    var asComplex: 𝐂 { get }
}

extension 𝐙: ComplexSubset {
    public var asComplex: 𝐂 {
        self.asReal.asComplex
    }
}

extension 𝐐: ComplexSubset {
    public var asComplex: 𝐂 {
        self.asReal.asComplex
    }
}

extension 𝐑: ComplexSubset {
    public var asComplex: 𝐂 {
        .init(self)
    }
}
