//
//  Permutation.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/12.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public struct Permutation<n: SizeType>: Multiplicative, SetType, Hashable {
    public let length: Int
    private let table: [Int : Int]
    
    public init(length: Int, table: [Int : Int]) {
        assert(Set(table.keys) == Set(table.values))
        assert(table.keys.allSatisfy { i in (0 ..< length).contains(i) })
        
        self.length = length
        self.table = table.exclude{ (k, v) in k == v }
    }
    
    public init<S: Sequence>(length: Int, indices: S) where S.Element == Int {
        let table = Dictionary(pairs: indices.enumerated().map{ ($0, $1) })
        self.init(length: length, table: table)
    }
    
    public static func transposition(length: Int, indices: (Int, Int)) -> Self {
        let (i, j) = indices
        return .init(length: length, table: [i : j, j : i])
    }
    
    public static func cyclic(length: Int, elements: [Int]) -> Self {
        var d = [Int : Int]()
        let l = elements.count
        for (i, a) in elements.enumerated() {
            d[a] = elements[(i + 1) % l]
        }
        return .init(length: length, table: d)
    }
    
    public subscript(i: Int) -> Int {
        table[i] ?? i
    }
    
    public var inverse: Self? {
        let inv = table.map{ (i, j) in (j, i)}
        return .init(length: length, table: Dictionary(pairs: inv))
    }
    
    // memo: the number of transpositions in it's decomposition.
    public var signature: Int {
        // the sign of a cyclic-perm of length l (l >= 2) is (-1)^{l - 1}
        let decomp = cyclicDecomposition
        return decomp.multiply { p in (-1).pow( p.table.count - 1) }
    }
    
    public static func *(a: Self, b: Self) -> Self {
        assert(a.length == b.length)
        var d = a.table
        for i in b.table.keys {
            d[i] = a[b[i]]
        }
        return .init(length: a.length, table: d)
    }
    
    public static func ==(a: Self, b: Self) -> Bool {
        a.table == b.table
    }
    
    public func `as`<m>(_ type: Permutation<m>.Type) -> Permutation<m> {
        Permutation<m>(length: length, table: self.table)
    }
    
    public var asDynamic: Permutation<DynamicSize> {
        self.as(Permutation<DynamicSize>.self)
    }
    
    public var asMatrix: Matrix<𝐙, n, n> {
        asMatrix(over: 𝐙.self)
    }

    public func asMatrix<R>(over: R.Type) -> Matrix<R, n, n> {
        asMatrix(DefaultMatrixImpl<R>.self)
    }
    
    public func asMatrix<_MatrixImpl>(_ implType: _MatrixImpl.Type) -> MatrixIF<_MatrixImpl, n, n> {
        .init(size: (length, length)) { setEntry in
            (0 ..< length).forEach { i in setEntry(self[i], i, .identity) }
        }
    }
    
    public var asMap: Map<Int, Int> {
        Map{ i in self[i] }
    }
    
    public var cyclicDecomposition: [Self] {
        var dict = table
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
                let p = Self.cyclic(length: length, elements: c)
                result.append(p)
            }
        }
        
        return result
    }
    
    public var description: String {
        table.isEmpty
            ? "id"
            : "[\((0 ..< length).map{ i in "\(i): \(self[i])" }.joined(separator: ", "))]"
    }
    
    public static var symbol: String {
        "S_\(n.intValue)"
    }
}

extension Permutation: Monoid, Group, FiniteSetType where n: StaticSizeType {
    public init(table: [Int : Int]) {
        self.init(length: n.intValue, table: table)
    }
    
    public init(indices: [Int]) {
        self.init(length: n.intValue, indices: indices)
    }

    public init(indices: Int...) {
        self.init(indices: indices)
    }
    
    public static func transposition(_ i: Int, _ j: Int) -> Self {
        transposition(length: n.intValue, indices: (i, j))
    }
    
    public static func cyclic(_ elements: [Int]) -> Self {
        cyclic(length: n.intValue, elements: elements)
    }
    
    public static func cyclic(_ elements: Int...) -> Self {
        cyclic(elements)
    }

    public static var identity: Self {
        .init(length: n.intValue, table: [:])
    }
    
    public static var allElements: [Self] {
        (0 ..< n.intValue).permutations.map{
            .init(length: n.intValue, indices: $0)
        }
    }
    
    public static var allTranspositions: [Self] {
        (0 ..< n.intValue).choose(2).map { .transposition($0[0], $0[1]) }
    }
    
    public static var countElements: Int {
        n.intValue.factorial
    }
}

extension Permutation where n == DynamicSize {
    public static func allPermutations(length n: Int) -> [Self] {
        (0 ..< n).permutations.map{ .init(length: n, indices: $0) }
    }
    
    public static func allTranspositions(within n: Int) -> [Self] {
        (0 ..< n).choose(2).map { .transposition(length: n, indices: ($0[0], $0[1])) }
    }
}

extension Array {
    public func permuted<n>(by p: Permutation<n>) -> Array {
        let pInv = p.inverse!
        return (0 ..< count).map{ i in self[pInv[i]] }
    }
}
