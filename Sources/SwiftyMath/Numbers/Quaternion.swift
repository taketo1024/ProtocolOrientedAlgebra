//
//  Quaternion
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/16.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//
//  see: https://en.wikipedia.org/wiki/quaternion

// memo: a skew field, i.e. product is non-commutative.

public typealias 𝐇 = Quaternion<𝐑>

public struct Quaternion<Base: Ring>: Ring, Module {
    public typealias BaseRing = Base
    
    private let x: Base
    private let y: Base
    private let z: Base
    private let w: Base

    public init(from x: 𝐙) {
        self.init(Base(from: x))
    }
    
    public init(_ x: Base) {
        self.init(x, .zero, .zero, .zero)
    }
    
    public init(_ z: Complex<Base>, _ w: Complex<Base>) {
        self.init(z.realPart, z.imaginaryPart, w.realPart, w.imaginaryPart)
    }
    
    public init(_ x: Base, _ y: Base, _ z: Base, _ w: Base) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
    
    public static var i: Self {
        .init(.zero, .identity, .zero, .zero)
    }
    
    public static var j: Self {
        .init(.zero, .zero, .identity, .zero)
    }
    
    public static var k: Self {
        .init(.zero, .zero, .zero, .identity)
    }
    
    public var components: [Base] {
        [x, y, z, w]
    }
    
    public var realPart: Base {
        x
    }
    
    public var imaginaryPart: Self {
        .init(.zero, y, z, w)
    }
    
    public var conjugate: Self {
        .init(x, -y, -z, -w)
    }

    public var inverse: Self? {
        let r2 = components.map{ $0 * $0 }.sumAll()
        if let r2Inv = r2.inverse {
            return conjugate * r2Inv
        } else {
            return nil
        }
    }
    
    public static func +(a: Self, b: Self) -> Self {
        .init(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)
    }
    
    public static prefix func -(a: Self) -> Self {
        .init(-a.x, -a.y, -a.z, -a.w)
    }
    
    public static func *(a: Base, b: Self) -> Self {
        Self(a * b.x, a * b.y, a * b.z, a * b.w)
    }
    
    public static func *(a: Self, b: Base) -> Self {
        Self(a.x * b, a.y * b, a.z * b, a.w * b)
    }
    
    public static func *(a: Self, b: Self) -> Self {
        let v = a.asMatrix * b.asVector
        return .init(v[0], v[1], v[2], v[3])
    }
    
    public var asVector: Vector4<Base> {
        [x, y, z, w]
    }
    
    public var asMatrix: Matrix4<Base> {
        [x, -y, -z, -w,
         y,  x, -w,  z,
         z,  w,  x, -y,
         w, -z,  y,  x]
    }
    
    public var description: String {
        Format.linearCombination([("1", x), ("i", y), ("j", z), ("k", w)])
    }
    
    public static var symbol: String {
        (Base.self == 𝐑.self) ? "𝐇" : "\(Base.symbol)[i, j, k]"
    }
}

extension Quaternion where Base == 𝐑 {
    public var abs: 𝐑 {
        √(x * x + y * y + z * z + w * w)
    }
    
    public func isApproximatelyEqualTo(_ b: Self, error e: 𝐑? = nil) -> Bool {
        return
            self.x.isApproximatelyEqualTo(b.x, error: e) &&
            self.y.isApproximatelyEqualTo(b.y, error: e) &&
            self.z.isApproximatelyEqualTo(b.z, error: e) &&
            self.w.isApproximatelyEqualTo(b.w, error: e)
    }
}

extension Quaternion: Hashable where Base: Hashable {}
