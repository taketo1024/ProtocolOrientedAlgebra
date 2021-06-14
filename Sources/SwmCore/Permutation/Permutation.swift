//
//  Permutation.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/12.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Algorithms

public struct Permutation<n: SizeType>: Multiplicative, MathSet, Hashable {
    public let indices: [Int]
    
    public init(indices: [Int]) {
        assert(n.isArbitrary || n.intValue == indices.count)
        assert(Set(indices) == Set(0 ..< indices.count))
        self.indices = indices
    }
    
    public init(indices: Int...)  {
        self.init(indices: indices)
    }
    
    public init<S: Sequence>(indices: S) where S.Element == Int {
        self.init(indices: Array(indices))
    }
    
    public init(length: Int, table: [Int : Int]) {
        assert(Set(table.keys) == Set(table.values))
        let indices = (0 ..< length).map { i in table[i] ?? i }
        self.init(indices: indices)
    }
    
    public static func identity(length: Int) -> Self {
        .init(indices: 0 ..< length)
    }
    
    public static func fill<S: Sequence>(length: Int, indices: S) -> Self where S.Element == Int {
        var filled: [Int] = []
        var remainings = Array(repeating: true, count: length)

        for i in indices {
            filled.append(i)
            remainings[i] = false
        }
        
        for (i, remaining) in remainings.enumerated() where remaining {
            filled.append(i)
        }
        
        return .init(indices: filled)
    }
    
    public static func transposition(length: Int, indices t: (Int, Int)) -> Self {
        let indices = Array(0 ..< length).with { $0.swapAt(t.0, t.1) }
        return .init(indices: indices)
    }
    
    public static func cyclic(length: Int, indices: [Int]) -> Self {
        var d = [Int : Int]()
        let l = indices.count
        for (p, i) in indices.enumerated() {
            d[i] = indices[(p + 1) % l]
        }
        return .init(length: length, table: d)
    }
    
    @inlinable
    public subscript(i: Int) -> Int {
        indices[i]
    }
    
    public var length: Int {
        indices.count
    }
    
    public var inverse: Self? {
        var inv = Array(0 ..< length)
        for (i, j) in indices.enumerated() {
            inv[j] = i
        }
        return .init(indices: inv)
    }
    
    public var table: [Int : Int] {
        Dictionary(keys: 0 ..< length) { self[$0] }
    }
    
    // memo: the number of transpositions in it's decomposition.
    // the sign of a cyclic-perm of length l (l >= 2) is (-1)^{l - 1}
    public var signature: Int {
        cyclicDecomposition.multiply { I in (-1).pow( I.count - 1 ) }
    }
    
    public func extended(_ n: Int) -> Permutation<anySize> {
        .init(indices: indices + Array(length ..< length + n))
    }

    public func shifted(_ n: Int) -> Permutation<anySize> {
        .init(indices: Array(0 ..< n) + indices.map{ $0 + n })
    }
    
    public static func *(a: Self, b: Self) -> Self {
        assert(a.length == b.length)
        return .init(indices: (0 ..< a.length).map{ a[b[$0]] } )
    }
    
    public static func ==(a: Self, b: Self) -> Bool {
        a.indices == b.indices
    }
    
    public func `as`<m>(_ type: Permutation<m>.Type) -> Permutation<m> {
        Permutation<m>(indices: indices)
    }
    
    public var asAnySize: Permutation<anySize> {
        self.as(Permutation<anySize>.self)
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
    
    public var cyclicDecomposition: [[Int]] {
        typealias Indices = [Int]
        
        var bucket = Set(0 ..< length)
        var result: [Indices] = []
        
        while !bucket.isEmpty {
            var i = bucket.first!
            var indices: Indices = []
            
            while bucket.contains(i) {
                bucket.remove(i)
                indices.append(i)
                i = self[i]
            }
            
            if indices.count > 1 {
                result.append(indices)
            }
        }
        
        return result
    }
    
    public var transpositionDecomposition: [(Int, Int)] {
        cyclicDecomposition.flatMap { I in
            (0 ..< I.count - 1).reversed().map { i in
                (I[i], I[i + 1])
            }
        }
    }
    
    public var description: String {
        self == .identity(length: length) ? "id" : indices.description
    }
    
    public static var symbol: String {
        "𝔖\(n.isFixed ? Format.sub(n.intValue) : "")"
    }
}

extension Permutation: Monoid, Group, FiniteSet where n: FixedSizeType {
    public init(table: [Int : Int]) {
        self.init(length: n.intValue, table: table)
    }
    
    public static func fill<S: Sequence>(indices: S) -> Self where S.Element == Int {
        fill(length: n.intValue, indices: indices)
    }
    
    public static func fill(indices: Int...) -> Self {
        fill(indices: indices)
    }
    
    public static func transposition(_ i: Int, _ j: Int) -> Self {
        transposition(length: n.intValue, indices: (i, j))
    }
    
    public static func cyclic(_ indices: [Int]) -> Self {
        cyclic(length: n.intValue, indices: indices)
    }
    
    public static func cyclic(_ indices: Int...) -> Self {
        cyclic(indices)
    }

    public static var identity: Self {
        .init(length: n.intValue, table: [:])
    }
    
    public static var allElements: [Self] {
        (0 ..< n.intValue).permutations().map {
            .init(indices: $0)
        }
    }
    
    public static var allTranspositions: [Self] {
        (0 ..< n.intValue).combinations(ofCount: 2).map {
            .transposition($0[0], $0[1])
        }
    }
    
    public static var countElements: Int {
        n.intValue.factorial
    }
}

extension Permutation where n == anySize {
    public static func allPermutations(length n: Int) -> [Self] {
        (0 ..< n).permutations().map {
            .init(indices: $0)
        }
    }
    
    public static func allTranspositions(within n: Int) -> [Self] {
        (0 ..< n).combinations(ofCount: 2).map {
            .transposition(length: n, indices: ($0[0], $0[1]))
        }
    }
}

extension Array {
    public func permuted<n>(by p: Permutation<n>) -> Array {
        let pInv = p.inverse!
        return (0 ..< count).map{ i in self[pInv[i]] }
    }
}
