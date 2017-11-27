//
//  ChainMap.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/08/01.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public typealias   ChainMap<A: FreeModuleBase, B: FreeModuleBase, R: Ring> = _ChainMap<Descending, A, B, R>
public typealias CochainMap<A: FreeModuleBase, B: FreeModuleBase, R: Ring> = _ChainMap<Ascending,  A, B, R>

public struct _ChainMap<chainType: ChainType, A: FreeModuleBase, B: FreeModuleBase, R: Ring>: Map {
    public typealias Domain   = FreeModule<A, R>
    public typealias Codomain = FreeModule<B, R>

    public let shift: Int
    private let f: FreeModuleHom<A, B, R>

    public init(shift: Int = 0, _ f: @escaping (A) -> [(B, R)]) {
        self.shift = shift
        self.f = FreeModuleHom(f)
    }

    public init(from: _ChainComplex<chainType, A, R>, to: _ChainComplex<chainType, B, R>, shift: Int = 0, _ f: @escaping (A) -> [(B, R)]) {
        self.init(shift: shift, f)
    }

    public func appliedTo(_ a: A) -> FreeModule<B, R> {
        return f.appliedTo(a)
    }

    public func appliedTo(_ x: FreeModule<A, R>) -> FreeModule<B, R> {
        return f.appliedTo(x)
    }

    public func assertChainMap(from: _ChainComplex<chainType, A, R>, to: _ChainComplex<chainType, B, R>, debug: Bool = false) {
        (min(from.offset, to.offset) ... max(from.topDegree, to.topDegree)).forEach { i1 in

            //        f1
            //  C_i1 ----> C'_i1
            //    |          |
            //  d1|    c     |d2
            //    v          v
            //  C_i2 ----> C'_i2
            //        f2

            let b1 = from.chainBasis(i1)
            let (d1, d2) = (from.boundaryMap(i1), to.boundaryMap(i1 + shift))

            if debug {
                print("----------")
                print("C\(i1) -> C'\(i1 + shift)")
                print("----------")
                print("C\(i1) : \(b1)\n")

                for a in b1 {
                    let x1 =  f.appliedTo(a)
                    let y1 = d2.appliedTo(x1)
                    let x2 = d1.appliedTo(a)
                    let y2 =  f.appliedTo(x2)

                    print("\td2 ∘ f1: \(a) ->\t\(x1) ->\t\(y1)")
                    print("\tf2 ∘ d1: \(a) ->\t\(x2) ->\t\(y2)")
                    print()
                }
            }

            assert( (d2 ∘ f).equals(f ∘ d1, forElements: b1.map{ FreeModule($0) } ) )
        }
    }
}

