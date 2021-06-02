//
//  Permutation.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/12.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

public struct Permutation<n: SizeType>: Multiplicative, MathSet, Hashable {
    public let length: Int
    public let table: [Int : Int]
    
    public init(length: Int, table: [Int : Int]) {
        assert(Set(table.keys) == Set(table.values))
        assert(table.keys.allSatisfy { i in (0 ..< length).contains(i) })
        
        self.length = length
        self.table = table.exclude{ (k, v) in k == v }
    }
    
    public init<S: Sequence>(length: Int, indices: S, fillRemaining: Bool = false) where S.Element == Int {
        if fillRemaining {
            let remain = Set(0 ..< length).subtracting(indices)
            self.init(length: length, indices: Array(indices) + remain.sorted(), fillRemaining: false)
        } else {
            let table = Dictionary(indices.enumerated().map{ ($0, $1) })
            self.init(length: length, table: table)
        }
    }
    
    public init(length: Int, indices: Int...)  {
        self.init(length: length, indices: indices)
    }
    
    public static func transposition(length: Int, indices: (Int, Int)) -> Self {
        let (i, j) = indices
        return .init(length: length, table: [i : j, j : i])
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
        table[i] ?? i
    }
    
    public static func identity(length: Int) -> Self {
        .init(length: length, table: [:])
    }
    
    public var inverse: Self? {
        .init(length: length, table: table.invert())
    }
    
    public var indices: [Int] {
        (0 ..< length).map{ self[$0] }
    }
    
    // memo: the number of transpositions in it's decomposition.
    // the sign of a cyclic-perm of length l (l >= 2) is (-1)^{l - 1}
    public var signature: Int {
        cyclicDecomposition.multiply { I in (-1).pow( I.count - 1 ) }
    }
    
    public func extended(_ n: Int) -> Permutation<anySize> {
        .init(length: length + n, indices: indices, fillRemaining: true)
    }

    public func shifted(_ n: Int) -> Permutation<anySize> {
        .init(length: length + n, table: table.mapPairs{ (i, j) in (i + n, j + n) } )
    }
    
    public static func *(a: Self, b: Self) -> Self {
        assert(a.length == b.length)
        return .init(length: a.length, table: b.table.mapValues{ a[$0] }.merging(a.table, overwrite: false))
    }
    
    public static func ==(a: Self, b: Self) -> Bool {
        a.table == b.table
    }
    
    public func `as`<m>(_ type: Permutation<m>.Type) -> Permutation<m> {
        Permutation<m>(length: length, table: self.table)
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
        
        var bucket = Set(table.keys)
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
        table.isEmpty
            ? "id"
            : "[\((0 ..< length).map{ i in "\(i): \(self[i])" }.joined(separator: ", "))]"
    }
    
    public static var symbol: String {
        "𝔖\(n.isFixed ? Format.sub(n.intValue) : "")"
    }
}

extension Permutation: Monoid, Group, FiniteSet where n: FixedSizeType {
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

extension Permutation where n == anySize {
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
