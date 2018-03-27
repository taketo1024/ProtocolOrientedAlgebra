//
//  Permutation.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/03/12.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public struct Permutation: Map {
    public typealias Domain = Int
    public typealias Codomain = Int

    internal var elements: [Int : Int]

    public init(_ elements: [Int: Int]) {
        assert(Set(elements.keys) == Set(elements.values))
        self.elements = elements.filter{ (k, v) in k != v }
    }

    public init(cyclic: Int...) {
        self.init(cyclic: cyclic)
    }

    internal init(cyclic c: [Int]) {
        var d = [Int : Int]()
        for (i, a) in c.enumerated() {
            d[a] = c[(i + 1) % c.count]
        }
        self.init(d)
    }

    public init(length: Int, generator g: ((Int) -> Int)) {
        let elements = (0 ..< length).map{ i in (i, g(i)) }
        self.init(Dictionary(pairs: elements))
    }

    public static var identity: Permutation {
        return Permutation([:])
    }

    public var inverse: Permutation {
        let inv = elements.map{ (i, j) in (j, i)}
        return Permutation(Dictionary(pairs: inv))
    }

    public subscript(i: Int) -> Int {
        return elements[i] ?? i
    }

    public func appliedTo(_ i: Int) -> Int {
        return self[i]
    }

    public func appliedTo(_ I: [Int]) -> [Int] {
        return I.map{ appliedTo($0) }
    }

    public var signature: Int {
        let decomp = cyclicDecomposition
        return decomp.reduce(1){ (sgn, p) in
            sgn * ( p.elements.count % 2 == 0 ? 1 : -1 )
        }
    }

    public var cyclicDecomposition: [Permutation] {
        var dict = elements
        var result: [Permutation] = []

        while !dict.isEmpty {
            let i = dict.keys.anyElement!
            var c: [Int] = []
            var x = i

            while !c.contains(x) {
                c.append(x)
                x = dict.removeValue(forKey: x)!
            }

            if c.count > 1 {
                let p = Permutation(cyclic: c)
                result.append(p)
            }
        }

        return result
    }

    public static func == (a: Permutation, b: Permutation) -> Bool {
        return a.elements == b.elements
    }

    public static func *(a: Permutation, b: Permutation) -> Permutation {
        var d = a.elements
        for i in b.elements.keys {
            d[i] = a[b[i]]
        }
        return Permutation(d)
    }

    public static func allPermutations(ofLength n: Int) -> [Permutation] {
        assert(n >= 0)
        if n > 1 {
            let prev = Permutation.allPermutations(ofLength: n - 1)
            return (0 ..< n).flatMap { (i: Int) -> [Permutation] in
                prev.map { (p: Permutation) -> Permutation in
                    let d = [(n - 1, i)] + (0 ..< n - 1).map { j in
                        (j, p[j] < i ? p[j] : p[j] + 1)
                    }
                    return Permutation(Dictionary(pairs: d))
                }
            }
        } else {
            return [Permutation.identity]
        }
    }

    public var description: String {
        return elements.isEmpty ? "id"
            : "p[\(elements.keys.sorted().map{ i in "\(i): \(self[i])"}.joined(separator: ", "))]"
    }

    public static var symbol: String {
        return "Permutation"
    }

    public var hashValue: Int {
        let p = 31
        return elements.sum{ (i, j) in i &* p &+ j }
    }
}

public extension Array where Element: Hashable {
    public func permuted(by p: Permutation) -> [Element] {
        return (0 ..< count).map{ i in self[p[i]] }
    }
}
