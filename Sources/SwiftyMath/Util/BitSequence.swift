//
//  File.swift
//  
//
//  Created by Taketo Sano on 2021/05/07.
//

import Foundation

public enum Bit: Int8, Comparable, ExpressibleByIntegerLiteral, CustomStringConvertible, Codable {
    case O = 0
    case I = 1
    
    public init(integerLiteral value: Int8) {
        assert(value == 0 || value == 1)
        self = (value == 0) ? .O : .I
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    public var description: String {
        rawValue.description
    }
}

public struct BitSequence: Sequence, Hashable, Comparable, ExpressibleByArrayLiteral, CustomStringConvertible, Codable {
    public typealias Element = Bit
    public typealias ArrayLiteralElement = Bit
    
    public var intValue: Int
    public let length: Int
    
    public init(intValue: Int, length: Int) {
        assert(intValue < 2.pow(length))
        self.intValue = intValue
        self.length = length
    }
    
    public init(_ bits: [Bit]) {
        assert(bits.count <= 64)
        let val = bits.reduce(0) { (res, b) in
            (res << 1) | Int(b.rawValue)
        }
        self.init(intValue: val, length: bits.count)
    }
    
    public init(arrayLiteral bits: Bit...) {
        self.init(bits)
    }
    
    public subscript(i: Int) -> Bit {
        get {
            assert(0 <= i && i < length)
            let b = (intValue >> (length - i - 1)) & 1
            return Bit(rawValue: Int8(b))!
        } set {
            if newValue == 0 {
                intValue &= ~(1 << (length - i - 1))
            } else {
                intValue |=  (1 << (length - i - 1))
            }
        }
    }
    
    public func replaced(with b: Bit, at i: Int) -> Self {
        var copy = self
        copy[i] = b
        return copy
    }
    
    public var weight: Int {
        self.sum{ Int($0.rawValue) }
    }
    
    public var successors: [Self] {
        (0 ..< length).compactMap { i in
            (self[i] == 0) ? self.replaced(with: 1, at: i) : nil
        }
    }
    
    public func makeIterator() -> AnyIterator<Bit> {
        AnyIterator((0 ..< length).lazy.map { i in self[i] }.makeIterator())
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        assert(lhs.length == rhs.length)
        return lhs != rhs && (0 ..< lhs.length).allSatisfy { i in lhs[i] <= rhs[i] }
    }
    
    public static func -(lhs: Self, rhs: Self) -> Self {
        assert(lhs.length == rhs.length)
        return Self(intValue: lhs.intValue & ~rhs.intValue, length: lhs.length)
    }
    
    public var description: String {
        let b = String(intValue, radix: 2)
        return String(repeating: "0", count: length - b.count) + b
    }
    
    public static func zeros(length: Int) -> Self {
        Self(intValue: 0, length: length)
    }
    
    public static func ones(length: Int) -> Self {
        Self(intValue: 2.pow(length) - 1, length: length)
    }
    
    public static func allSequences(length: Int) -> [Self] {
        (0 ..< 2.pow(length)).map { Self(intValue: $0, length: length) }
    }
    
    public static func sequences(length: Int, weight: Int) -> [Self] {
        if length < 0 || weight < 0 || length < weight {
            return []
        }
        
        if length > 1 {
            let s0 = sequences(length: length - 1, weight: weight).map { b in
                Self(intValue: b.intValue << 1, length: length)
            }
            let s1 = sequences(length: length - 1, weight: weight - 1).map { b in
                Self(intValue: (b.intValue << 1) | 1, length: length)
            }
            return s0 + s1
        } else if length == 1 { // 0 <= weight <= 1
            return [Self(intValue: weight, length: 1)]
        } else {
            return [[]]
        }
    }

}
