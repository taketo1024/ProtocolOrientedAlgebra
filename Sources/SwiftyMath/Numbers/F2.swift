//
//  F2.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/30.
//

public struct 𝐅₂: Field, FiniteSet, Hashable, ExpressibleByIntegerLiteral {
    public let representative: UInt8
    
    private init(_ a: UInt8) {
        assert(a == 0 || a == 1)
        representative = a
    }
    
    public init(_ a: 𝐙) {
        self.init(a.isEven ? UInt8(0) : UInt8(1))
    }
    
    public init(from a: 𝐙) {
        self.init(a)
    }
    
    public init(integerLiteral value: UInt8) {
        self.init((value % 2 == 0) ? 0 : 1)
    }
    
    public var inverse: Self? {
        isZero ? nil : self
    }
    
    public static func +(a: Self, b: Self) -> Self {
        .init(a.representative ^ b.representative)
    }
    
    public prefix static func -(a: Self) -> Self {
        a
    }
    
    public static func -(a: Self, b: Self) -> Self {
        a + b
    }
    
    public static func *(a: Self, b: Self) -> Self {
        .init(a.representative & b.representative)
    }
    
    public static func sum(_ elements: [Self]) -> Self {
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
}
