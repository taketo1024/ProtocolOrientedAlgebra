//
//  Permutation.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/12.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public typealias DPermutation = Permutation<DynamicSize>

public struct Permutation<n: SizeType>: Group, MapType { // SymmetricGroup<n>
    public typealias Domain = Int
    public typealias Codomain = Int
    
    internal var elements: [Int : Int]
    
    public init(_ f: @escaping (Int) -> Int) {
        assert(!n.isDynamic)
        let elements = (0 ... n.intValue).map{ i in (i, f(i)) }
        self.init(Dictionary(pairs: elements))
    }
    
    public init<S: Sequence>(_ sequence: S) where S.Element == Int {
        let dict = Dictionary(pairs: sequence.enumerated().map{ ($0, $1) })
        self.init(dict)
    }
    
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
    
    public static var identity: Permutation<n> {
        return Permutation([:])
    }
    
    public var inverse: Permutation<n> {
        let inv = elements.map{ (i, j) in (j, i)}
        return Permutation(Dictionary(pairs: inv))
    }
    
    public subscript(i: Int) -> Int {
        return elements[i] ?? i
    }
    
    public func applied(to i: Int) -> Int {
        return self[i]
    }
    
    public func applied(to I: [Int]) -> [Int] {
        return I.map{ applied(to: $0) }
    }
    
    // memo: the number of transpositions in it's decomposition.
    public var signature: Int {
        // the sign of a cyclic-perm of length l (l >= 2) is (-1)^{l - 1}
        let decomp = cyclicDecomposition
        return decomp.multiply { p in (-1).pow( p.elements.count - 1) }
    }
    
    public var cyclicDecomposition: [Permutation<n>] {
        var dict = elements
        var result: [Permutation<n>] = []
        
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
    
    public static func *(a: Permutation<n>, b: Permutation<n>) -> Permutation<n> {
        var d = a.elements
        for i in b.elements.keys {
            d[i] = a[b[i]]
        }
        return Permutation(d)
    }
    
    public var description: String {
        return elements.isEmpty ? "id"
            : "p[\(elements.keys.sorted().map{ i in "\(i): \(self[i])"}.joined(separator: ", "))]"
    }
    
    public static var symbol: String {
        return "S_\(n.intValue)"
    }
}

extension Permutation: FiniteSetType where n: StaticSizeType {
    public static var allElements: [Permutation<n>] {
        return DPermutation.rawPermutations(length: n.intValue).map{ Permutation<n>($0) }
    }
    
    public static var countElements: Int {
        return n.intValue.factorial
    }
}

extension Permutation where n == DynamicSize {
    public static func rawPermutations(length l: Int) -> [[Int]] {
        typealias RawPermutation = [Int]
        
        assert(l >= 0)
        
        func permutations(in elements: [Int]) -> [RawPermutation] {
            if elements.isEmpty {
                return [[]]
            } else {
                return elements.enumerated().flatMap { (i, x) -> [RawPermutation] in
                    permutations(in: elements.removed(at: i)).map{ [x] + $0 }
                }
            }
        }
        
        return permutations(in: (0 ..< l).toArray())
    }

    public static func permutations(length l: Int) -> [DPermutation] {
        return DPermutation.rawPermutations(length: l).map{ DPermutation($0) }
    }
}

extension Array where Element: Hashable {
    public func permuted<n>(by p: Permutation<n>) -> [Element] {
        return (0 ..< count).map{ i in self[p[i]] }
    }
}
