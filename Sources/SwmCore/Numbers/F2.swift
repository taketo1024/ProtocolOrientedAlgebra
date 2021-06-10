//
//  F2.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/30.
//

public struct 𝐅₂: Field, FiniteSet, Hashable, ExpressibleByIntegerLiteral {
    public let representative: UInt8
    
    @inlinable
    public init(_ a: UInt8) {
        assert(a == 0 || a == 1)
        representative = a
    }
    
    @inlinable
    public init(_ a: 𝐙) {
        self.init(a.isEven ? UInt8(0) : UInt8(1))
    }
    
    @inlinable
    public init(from a: 𝐙) {
        self.init(a)
    }
    
    @inlinable
    public init(integerLiteral value: UInt8) {
        self.init((value % 2 == 0) ? 0 : 1)
    }
    
    @inlinable
    public var inverse: Self? {
        isZero ? nil : self
    }
    
    @inlinable
    public static func +(a: Self, b: Self) -> Self {
        .init(a.representative ^ b.representative)
    }
    
    @inlinable
    public prefix static func -(a: Self) -> Self {
        a
    }
    
    @inlinable
    public static func -(a: Self, b: Self) -> Self {
        a + b
    }
    
    @inlinable
    public static func *(a: Self, b: Self) -> Self {
        .init(a.representative & b.representative)
    }
    
    @inlinable
    public static func sum<S: Sequence>(_ elements: S) -> Self where S.Element == Self {
        elements.count { $0.representative == 1 }.isEven ? .zero : .identity
    }
    
    public static var allElements: [𝐅₂] {
        [.zero, .identity]
    }
    
    public static var countElements: Int {
        2
    }
    
    public var description: String {
        representative.description
    }
    
    public static var symbol: String {
        "𝐅₂"
    }
}

extension 𝐅₂: Randomable {
    public static func random() -> 𝐅₂ {
        .init(Bool.random() ? 0 : 1)
    }
}
