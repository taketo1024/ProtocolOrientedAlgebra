//
//  Permutation.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/12.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public typealias DPermutation = Permutation<DynamicSize>

public struct Permutation<n: SizeType>: Group, Hashable {
    internal var elements: [Int : Int]
    
    public init(_ elements: [Int : Int]) {
        assert(Set(elements.keys) == Set(elements.values))
        self.elements = elements.filter{ (k, v) in k != v }
    }
    
    public init<S: Sequence>(_ sequence: S) where S.Element == Int {
        let dict = Dictionary(pairs: sequence.enumerated().map{ ($0, $1) })
        self.init(dict)
    }
    
    public init(_ sequence: Int...)  {
        self.init(sequence)
    }
    
    public init(cyclic elements: [Int]) {
        var d = [Int : Int]()
        let l = elements.count
        for (i, a) in elements.enumerated() {
            d[a] = elements[(i + 1) % l]
        }
        self.init(d)
    }
    
    public init(cyclic elements: Int...) {
        self.init(cyclic: elements)
    }
    
    public static func transposition(_ i: Int, _ j: Int) -> Self {
        .init([i : j, j : i])
    }

    public static var identity: Self {
        .init([:])
    }
    
    public var inverse: Self? {
        let inv = elements.map{ (i, j) in (j, i)}
        return .init(Dictionary(pairs: inv))
    }
    
    public subscript(i: Int) -> Int {
        elements[i] ?? i
    }
    
    // memo: the number of transpositions in it's decomposition.
    public var signature: Int {
        // the sign of a cyclic-perm of length l (l >= 2) is (-1)^{l - 1}
        let decomp = cyclicDecomposition
        return decomp.multiply { p in (-1).pow( p.elements.count - 1) }
    }
    
    public var cyclicDecomposition: [Self] {
        var dict = elements
        var result: [Self] = []
        
        while !dict.isEmpty {
            let i = dict.keys.anyElement!
            var c: [Int] = []
            var x = i
            
            while !c.contains(x) {
                c.append(x)
                x = dict.removeValue(forKey: x)!
            }
            
            if c.count > 1 {
                let p = Self(cyclic: c)
                result.append(p)
            }
        }
        
        return result
    }
    
    public static func *(a: Self, b: Self) -> Self {
        var d = a.elements
        for i in b.elements.keys {
            d[i] = a[b[i]]
        }
        return .init(d)
    }
    
    public static func ==(a: Self, b: Self) -> Bool {
        a.elements == b.elements
    }
    
    public var asMap: Map<Int, Int> {
        Map{ i in self[i] }
    }
    
    public var description: String {
        elements.isEmpty
            ? "id"
            : "p[\(elements.keys.sorted().map{ i in "\(i): \(self[i])"}.joined(separator: ", "))]"
    }
    
    public static var symbol: String {
        "S_\(n.intValue)"
    }
}

extension Permutation: FiniteSetType where n: StaticSizeType {
    public var asMatrix: Matrix<n, n, 𝐙> {
        asMatrix(over: 𝐙.self)
    }

    public func asMatrix<R>(over: R.Type) -> Matrix<n, n, R> {
        let n = Self.size
        return Matrix(size: (n, n)) { setEntry in
            (0 ..< n).forEach { i in setEntry(self[i], i, .identity) }
        }
    }
    
    public static var size: Int {
        n.intValue
    }
    
    public static var allElements: [Self] {
        (0 ..< n.intValue).permutations.map{ .init($0) }
    }
    
    public static var allTranspositions: [Self] {
        (0 ..< n.intValue).choose(2).map { .transposition($0[0], $0[1]) }
    }
    
    public static var countElements: Int {
        n.intValue.factorial
    }
}

extension Permutation where n == DynamicSize {
    public func asMatrix(size n: Int) -> DMatrix<𝐙> {
        asMatrix(size: n, over: 𝐙.self)
    }

    public func asMatrix<R>(size n: Int, over: R.Type) -> DMatrix<R> {
        Matrix(size: (n, n)) { setEntry in
            (0 ..< n).forEach { i in setEntry(self[i], i, .identity) }
        }
    }
    
    public static func allPermutations(length n: Int) -> [Self] {
        (0 ..< n).permutations.map{ .init($0) }
    }
    
    public static func allTranspositions(within n: Int) -> [Self] {
        (0 ..< n).choose(2).map { .transposition($0[0], $0[1]) }
    }
}

extension Array where Element: Hashable {
    public func permuted<n>(by p: Permutation<n>) -> Array {
        (0 ..< count).map{ i in self[p[i]] }
    }
}
