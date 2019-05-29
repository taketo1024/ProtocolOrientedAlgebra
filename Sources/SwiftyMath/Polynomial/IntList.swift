//
//  MIndex.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/10.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public struct IntList: Hashable, Comparable, CustomStringConvertible, Codable {
    public let components: [Int]
    public init(_ components: Int ...) {
        self.init(components)
    }
    
    public init(_ components: [Int]) {
        // TODO trim last 0s.
        self.components = components
    }
    
    public init(_ components: [Int : Int]) {
        let n = (components.keys.max() ?? -1) + 1
        self.components = (0 ..< n).map{ components[$0] ?? 0 }
    }
    
    public subscript(i: Int) -> Int {
        return (i < components.count) ? components[i] : 0
    }
    
    public static var empty: IntList {
        return IntList([])
    }
    
    public var total: Int {
        return components.sumAll()
    }
    
    public var length: Int {
        return components.count
    }
    
    public func permuted(by p: Permutation) -> IntList {
        let indices = self.components.enumerated().map{ (i, j) in (p[i], j)}
        return IntList(Dictionary(pairs: indices))
    }
    
    public func drop(_ i: Int) -> IntList {
        assert(0 <= i && i < length)
        return IntList(components.removed(at: i))
    }
    
    public func dropLast() -> IntList {
        return drop(length - 1)
    }
    
    public func append(_ n: Int) -> IntList {
        return IntList(components + [n])
    }
    
    public static func +(I: IntList, J: IntList) -> IntList {
        let l = max(I.length, J.length)
        return IntList( (0 ..< l).map{ i in I[i] + J[i] } )
    }
    
    public static prefix func -(I: IntList) -> IntList {
        return IntList( I.components.map{ -$0 } )
    }
    
    public static func -(I: IntList, J: IntList) -> IntList {
        return I + (-J)
    }
    
    public static func binaryCombinations(length n: Int) -> [IntList] {
        assert(n <= 64)
        return (0 ..< 2.pow(n)).map { (b: Int) -> IntList in
            IntList( (0 ..< n).map{ i in (b >> i) & 1 } )
        }
    }
    
    // lex order
    public static func <(I: IntList, J: IntList) -> Bool {
        return I.components.lexicographicallyPrecedes(J.components)
    }
    
    public var description: String {
        return "(\( components.map{ String($0) }.joined(separator: ", ")))"
    }
}
