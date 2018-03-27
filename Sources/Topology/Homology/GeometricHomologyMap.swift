//
//  GeometricComplexMap.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/11/05.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation
import SwiftyAlgebra

// TODO clean up the clutters.

public extension GeometricComplexMap {
    public func asChainMap<R: EuclideanRing>(_ type: R.Type) -> ChainMap<ComplexType.Cell, ComplexType.Cell, R> {
        return ChainMap(self, R.self)
    }

    public func asCochainMap<R: EuclideanRing>(_ type: R.Type) -> CochainMap<Dual<ComplexType.Cell>, Dual<ComplexType.Cell>, R> {
        return CochainMap(self, R.self)
    }
}

public extension ChainMap where T == Descending {

    // f: K1 -> K2  ==> f_*: C(K1) -> C(K2)
    //                          s |-> f(s)
    public init<F: GeometricComplexMap>(_ f: F, _ type: R.Type) where A == F.ComplexType.Cell, B == F.ComplexType.Cell {
        typealias Cell = F.ComplexType.Cell
        self.init { s -> Codomain in
            let t = f.appliedTo(s)
            return (s.dim == t.dim) ? Codomain(t) : Codomain.zero
        }
    }
}

public extension CochainMap where T == Ascending {

    // f: K1 -> K2  ==> f^*: C^*(K2) -> C^*(K1) , pullback
    //                            g  -> (g∘f: s -> g∘f(s))

    public init<F: GeometricComplexMap>(_ f: F, _ type: R.Type) where A == Dual<F.ComplexType.Cell>, B == Dual<F.ComplexType.Cell> {
        typealias Cell = F.ComplexType.Cell
        self.init { (g: Dual<Cell>) -> Codomain in
            let i = g.degree
            let ss = f.domain.cells(ofDim: i).flatMap { (s: Cell) -> (Dual<Cell>, R)? in
                let t = f.appliedTo(s)
                return (g.pair(t) == 1) ? (Dual(s), .identity) : nil
            }
            return Codomain(ss)
        }
    }
}

public extension HomologyMap where T == Descending {
    public init<F: GeometricComplexMap>(from: Homology<A, R>, to: Homology<B, R>, inducedFrom f: F) where A == F.ComplexType.Cell, B == F.ComplexType.Cell {
        self.init(from: from, to: to, inducedFrom: ChainMap(f, R.self))
    }
}

public extension CohomologyMap where T == Ascending {
    public init<F: GeometricComplexMap>(from: Cohomology<A, R>, to: Cohomology<B, R>, inducedFrom f: F) where A == Dual<F.ComplexType.Cell>, B == Dual<F.ComplexType.Cell> {
        self.init(from: from, to: to, inducedFrom: CochainMap(f, R.self))
    }
}
