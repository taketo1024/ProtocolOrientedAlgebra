//
//  MIndex.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/10.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public struct IntList: Hashable, Comparable, CustomStringConvertible {
    internal let elements: [Int]
    public init(_ elements: Int ...) {
        self.init(elements)
    }

    public init(_ elements: [Int]) {
        // TODO trim last 0s.
        self.elements = elements
    }

    public init(_ elements: [Int : Int]) {
        let n = (elements.keys.max() ?? -1) + 1
        self.elements = (0 ..< n).map{ elements[$0] ?? 0 }
    }

    public subscript(i: Int) -> Int {
        return (i < elements.count) ? elements[i] : 0
    }

    public static var empty: IntList {
        return IntList([])
    }

    public var total: Int {
        return elements.sumAll()
    }

    public var length: Int {
        return elements.count
    }

    public func permuted(by p: Permutation) -> IntList {
        let indices = self.elements.enumerated().map{ (i, j) in (p[i], j)}
        return IntList(Dictionary(pairs: indices))
    }

    public static func *(I: IntList, J: IntList) -> IntList {
        let l = max(I.length, J.length)
        return IntList( (0 ..< l).map{ i in I[i] + J[i] } )
    }

    public static func ==(I: IntList, J: IntList) -> Bool {
        return I.elements == J.elements
    }

    // e.g. (2, 1, 3) -> 2 + (1 * p) + (3 * p^2)
    public var hashValue: Int {
        let p = 31
        return elements.reversed().reduce(0) { (sum, next) -> Int in
            p &* sum &+ next
        }
    }

    // lex order
    public static func <(I: IntList, J: IntList) -> Bool {
        return I.elements.lexicographicallyPrecedes(J.elements)
    }

    public var description: String {
        return "(\( elements.map{ String($0) }.joined(separator: ", ")))"
    }
}
