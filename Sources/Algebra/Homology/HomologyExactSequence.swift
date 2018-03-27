//
//  HomologyExactSequence.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/12/12.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public typealias   HomologyExactSequence<A: FreeModuleBase, B: FreeModuleBase, C: FreeModuleBase, R: EuclideanRing>
    = _HomologyExactSequence<Descending, A, B, C, R>

public typealias CohomologyExactSequence<A: FreeModuleBase, B: FreeModuleBase, C: FreeModuleBase, R: EuclideanRing>
    = _HomologyExactSequence<Ascending , A, B, C, R>

public struct _HomologyExactSequence<T: ChainType, A: FreeModuleBase, B: FreeModuleBase, C: FreeModuleBase, R: EuclideanRing>: Sequence, CustomStringConvertible {
    public typealias Object = ExactSequence<R>.Object

    public let H0: _Homology<T, A, R>
    public let H1: _Homology<T, B, R>
    public let H2: _Homology<T, C, R>

    internal let map0:  _HomologyMap<T, A, B, R>
    internal let map1:  _HomologyMap<T, B, C, R>
    internal let delta: _HomologyMap<T, C, A, R>

    public let topDegree: Int
    public let bottomDegree: Int
    public var sequence : ExactSequence<R>

    public init(_ chain0: _ChainComplex<T, A, R>, _ map0 : _ChainMap<T, A, B, R>,
                _ chain1: _ChainComplex<T, B, R>, _ map1 : _ChainMap<T, B, C, R>,
                _ chain2: _ChainComplex<T, C, R>, _ delta: _ChainMap<T, C, A, R>) {

        self.H0 = _Homology(chain0)
        self.H1 = _Homology(chain1)
        self.H2 = _Homology(chain2)

        self.map0  = _HomologyMap(from: H0, to: H1, inducedFrom: map0)
        self.map1  = _HomologyMap(from: H1, to: H2, inducedFrom: map1)
        self.delta = _HomologyMap(from: H2, to: H0, inducedFrom: delta)

        self.topDegree    = Swift.max(chain0.topDegree, chain1.topDegree, chain2.topDegree)
        self.bottomDegree = Swift.min(chain0.offset,    chain1.offset,    chain2.offset)

        self.sequence  = ExactSequence(count: 3 * (topDegree - bottomDegree + 1))
    }

    public var length: Int {
        return (topDegree - bottomDegree + 1) * 3
    }

    internal func seqIndex(_ i: Int, _ n: Int) -> Int {
        return T.descending ? (topDegree - n) * 3 + i : (n - bottomDegree) * 3 + i
    }

    internal func gridIndex(_ k: Int) -> (Int, Int) {
        let (i, j) = (k >= 0) ? (k % 3, k / 3) : (k % 3 + 3, k / 3 - 1)
        return (i, T.descending ? topDegree - j : bottomDegree + j)
    }

    public subscript(i: Int, n: Int) -> Object? {
        assert((0 ..< 3).contains(i))
        return sequence[seqIndex(i, n)]
    }

    public subscript(k: Int) -> Object? {
        return sequence[k]
    }

    internal var degrees: [Int] {
        return T.descending
            ? (bottomDegree ... topDegree).reversed().toArray()
            : (bottomDegree ... topDegree).toArray()
    }

    public mutating func isZeroMap(_ i: Int) -> Bool {
        return sequence.isZeroMap(i)
    }

    public mutating func isInjective(_ i: Int) -> Bool {
        return sequence.isZeroMap(i - 1)
    }

    public mutating func isSurjective(_ i: Int) -> Bool {
        return sequence.isZeroMap(i + 1)
    }

    public mutating func isIsomorphic(_ i: Int) -> Bool {
        return sequence.isIsomorphic(i)
    }


    public mutating func fill(column i: Int, degree n: Int) {
        assert((0 ..< 3).contains(i))

        let k = seqIndex(i, n)

        sequence[k] = {
            switch i {
            case 0: return H0[n].structure.asAbstract
            case 1: return H1[n].structure.asAbstract
            case 2: return H2[n].structure.asAbstract
            default: fatalError()
            }
        }()

        if sequence[k - 1] != nil && sequence.arrows[k - 1].map == nil {
            sequence.arrows[k - 1].map = makeMap(k - 1)
        }

        if sequence[k + 1] != nil && sequence.arrows[k].map == nil {
            sequence.arrows[k].map = makeMap(k)
        }
    }

    public mutating func fill(column i: Int) {
        assert((0 ..< 3).contains(i))
        for n in bottomDegree ... topDegree {
            fill(column: i, degree: n)
        }
    }

    private func makeMap(_ k: Int) -> ExactSequence<R>.Map {
        let (i0, n0) = gridIndex(k)
        let (_ , n1) = gridIndex(k + 1)

        switch i0 {
        case 0: return _makeMap(H0[n0], map0,  H1[n1])
        case 1: return _makeMap(H1[n0], map1,  H2[n1])
        case 2: return _makeMap(H2[n0], delta, H0[n1])
        default: fatalError()
        }
    }

    private func _makeMap<X, Y>(_ h0: _Homology<T, X, R>.Summand, _ f: _HomologyMap<T, X, Y, R>, _ h1: _Homology<T, Y, R>.Summand) -> ExactSequence<R>.Map {
        return ExactSequence<R>.Map { i in
            let z = h0.generator(i)
            let w = f.appliedTo(z)
            let n = h1.summands.count
            return FreeModule( zip( 0 ..< n, h1.factorize(w.representative) ) )
        }
    }

    @discardableResult
    public mutating func solve(column i: Int, degree n: Int, debug: Bool = false) -> Object? {
        sequence.solve(seqIndex(i, n), debug: debug)
        return self[i, n]
    }

    @discardableResult
    public mutating func solve(debug: Bool = false) -> [Object?] {
        return sequence.solve(debug: debug)
    }

    public func assertExactness(column i: Int, degree n: Int, debug: Bool = false) {
        let k = seqIndex(i, n)
        sequence.assertExactness(at: k, debug: debug)
    }

    public func assertExactness(debug: Bool = false) {
        sequence.assertExactness(debug: debug)
    }

    public func makeIterator() -> AnyIterator<Object?> {
        let lazy = (0 ..< length).lazy.map{ k in self[k] }
        return AnyIterator(lazy.makeIterator())
    }

    public var description: String {
        return "\(H0) -> \(H1) -> \(H2)"
    }

    public var detailDescription: String {
        func s(_ i: Int, _ n: Int) -> String {
            return self[i, n].map{ "\($0)" } ?? "?"
        }
        return "\(self.description)\n--------------------\n"
            + degrees.map { n -> String in
                "\(n): \t" + (0 ..< 3).map{ i in self[i, n].map{ "\($0)" } ?? "?" }.joined(separator: "\t-> ")
                }.joined(separator: "\t->\n")
            + "\t-> 0"
    }
}
