//
//  ChainComplex.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/05/04.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public protocol ChainType {
    static var descending: Bool { get }
    static func target(_ i: Int) -> Int
}
public struct Descending : ChainType {    // for ChainComplex / Homology
    public static let descending = true
    public static func target(_ i: Int) -> Int { return i - 1 }
}
public struct Ascending : ChainType {
    public static let descending = false
    public static func target(_ i: Int) -> Int { return i + 1 }
}

public typealias   ChainComplex<A: FreeModuleBase, R: Ring> = _ChainComplex<Descending, A, R>
public typealias CochainComplex<A: FreeModuleBase, R: Ring> = _ChainComplex<Ascending,  A, R>

public struct _ChainComplex<T: ChainType, A: FreeModuleBase, R: Ring>: Equatable, CustomStringConvertible {
    public typealias ChainBasis = [A]
    public typealias BoundaryMap = FreeModuleHom<A, A, R>

    public let name: String
    internal let chain: [(basis: ChainBasis, map: BoundaryMap)]
    internal let matrices: [ComputationalMatrix<R>]
    internal let offset: Int

    // root initializer
    public init(name: String? = nil, _ chain: [(ChainBasis, BoundaryMap)], offset: Int = 0) {
        self.name = name ?? "_"
        self.chain = chain
        self.matrices = _ChainComplex<T, A, R>.makeMatrices(chain)
        self.offset = offset
    }

    public var topDegree: Int {
        return chain.count + offset - 1
    }

    public func chainBasis(_ i: Int) -> ChainBasis {
        return (offset ... topDegree).contains(i) ? chain[i - offset].basis : []
    }

    public func boundaryMap(_ i: Int) -> BoundaryMap {
        return (offset ... topDegree).contains(i) ? chain[i - offset].map : .zero
    }

    public func boundaryMatrix(_ i: Int) -> ComputationalMatrix<R> {
        switch i {
        case (offset ... topDegree):
            return matrices[i - offset]

        case topDegree + 1 where T.descending:
            return .zero(rows: chainBasis(topDegree).count, cols: 0)

        case offset - 1 where !T.descending:
            return .zero(rows: chainBasis(offset).count, cols: 0)

        default:
            return .zero(rows: 0, cols: 0)
        }
    }

    public func shifted(_ d: Int) -> _ChainComplex<T, A, R> {
        return _ChainComplex.init(name: "\(name)[\(d)]", chain, offset: offset + d)
    }

    internal static func makeMatrices(_ chain: [(ChainBasis, BoundaryMap)]) -> [ComputationalMatrix<R>] {
        return chain.enumerated().map { (i, c) in
            let (from, map) = c
            let next = T.target(i)
            let to = (0 ..< chain.count).contains(next) ? chain[next].0 : []

            let toIndex = Dictionary(pairs: to.enumerated().map{($1, $0)}) // [toBasisElement: toBasisIndex]
            let components = from.enumerated().flatMap{ (j, x) -> [MatrixComponent<R>] in
                map.appliedTo(x).flatMap { (y, a) -> MatrixComponent<R>? in
                    toIndex[y].flatMap{ i in (i, j, a) } // nil if toIndex[y] == nil
                }
            }

            return ComputationalMatrix(rows: to.count, cols: from.count, components: components)
        }
    }

    public func assertComplex(debug: Bool = false) {
        (offset ... topDegree).forEach { i1 in
            let i2 = T.target(i1)
            let b1 = chainBasis(i1)
            let (d1, d2) = (boundaryMap(i1), boundaryMap(i2))
            let (m1, m2) = (boundaryMatrix(i1), boundaryMatrix(i2))

            if debug {
                print("----------")
                print("C\(i1) -> C\(i2)")
                print("----------")
                print("C\(i1) : \(b1)\n")
                for s in b1 {
                    let x = d1.appliedTo(s)
                    let y = d2.appliedTo(x)
                    print("\t\(s) ->\t\(x) ->\t\(y)")
                }
                print()
            }

            let matrix = m2 * m1
            assert(matrix.isZero, "d\(i2)∘d\(i1) = \(matrix)")
        }
    }

    public static func ==<T, A, R>(a: _ChainComplex<T, A, R>, b: _ChainComplex<T, A, R>) -> Bool {
        let offset = min(a.offset, b.offset)
        let degree = max(a.topDegree, b.topDegree)
        return (offset ... degree).forAll { i in (a.chainBasis(i) == b.chainBasis(i)) && (a.boundaryMatrix(i) == b.boundaryMatrix(i)) }
    }

    public var description: String {
        return chain.description
    }
}
