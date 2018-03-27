//
//  ChainComplexOperations.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/12/15.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public extension ChainComplex {
    public static func ⊕<B>(C1: _ChainComplex<T, A, R>, C2: _ChainComplex<T, B, R>) -> _ChainComplex<T, Sum<A, B>, R> {
        typealias C = _ChainComplex<T, Sum<A, B>, R>

        let offset = min(C1.offset, C2.offset)
        let degree = max(C1.topDegree, C2.topDegree)

        let chain = (offset ... degree).map { i -> (C.ChainBasis, C.BoundaryMap) in
            let basis: C.ChainBasis = C1.chainBasis(i).map{ a in Sum(a) } + C2.chainBasis(i).map{ b in Sum(b) }

            let (f1, f2) = (C1.boundaryMap(i), C2.boundaryMap(i))
            let map = C.BoundaryMap { c in
                switch c {
                case let ._1(a): return FreeModule( f1.appliedTo(a).map{ (a, r) in (._1(a), r) } )
                case let ._2(b): return FreeModule( f2.appliedTo(b).map{ (b, r) in (._2(b), r) } )
                }
            }

            return (basis, map)
        }

        return _ChainComplex<T, Sum<A, B>, R>(name: "\(C1.name) ⊕ \(C2.name)", chain)
    }

    public static func ⊗<B>(C1: _ChainComplex<T, A, R>, C2: _ChainComplex<T, B, R>) -> _ChainComplex<T, Tensor<A, B>, R> {
        typealias C = _ChainComplex<T, Tensor<A, B>, R>

        let offset = C1.offset + C2.offset
        let degree = C1.topDegree + C2.topDegree

        let bases = (offset ... degree).map{ (k) -> C.ChainBasis in
            (offset ... k).flatMap{ i in
                C1.chainBasis(i).allCombinations(with: C2.chainBasis(k - i)).map{ $0 ⊗ $1 }
            }
        }

        let chain = (offset ... degree).map{ (k) -> (C.ChainBasis, C.BoundaryMap) in
            let from = bases[k - offset]
            let map = (offset ... k).sum { i -> C.BoundaryMap in
                let j = k - i
                let (d1, d2) = (C1.boundaryMap(i), C2.boundaryMap(j))
                let (I1, I2) = (FreeModuleHom<A, A, R>{ a in (a.degree == i) ? FreeModule(a) : .zero },
                                FreeModuleHom<B, B, R>{ b in (b.degree == j) ? FreeModule(b) : .zero })
                let e = R(from: (-1).pow(i))
                return d1 ⊗ I2 + e * I1 ⊗ d2
            }
            return (from, map)
        }

        return _ChainComplex<T, Tensor<A, B>, R>(name: "\(C1.name) ⊗ \(C2.name)", chain)
    }
}

