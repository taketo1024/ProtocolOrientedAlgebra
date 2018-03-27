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

// TODO conform Module<R>
public struct _ChainMap<T: ChainType, A: FreeModuleBase, B: FreeModuleBase, R: Ring>: Map {
    public typealias Domain   = FreeModule<A, R>
    public typealias Codomain = FreeModule<B, R>

    public let shift: Int
    internal let map: FreeModuleHom<A, B, R>

    public init(shift: Int = 0, _ map: @escaping (A) -> Codomain) {
        self.shift = shift
        self.map = FreeModuleHom(map)
    }

    public init(from: _ChainComplex<T, A, R>, to: _ChainComplex<T, B, R>, shift: Int = 0, _ f: @escaping (A) -> Codomain) {
        self.init(shift: shift, f)
    }

    public func appliedTo(_ a: A) -> FreeModule<B, R> {
        return map.appliedTo(a)
    }

    public func appliedTo(_ x: FreeModule<A, R>) -> FreeModule<B, R> {
        return map.appliedTo(x)
    }

    public func assertChainMap(from: _ChainComplex<T, A, R>, to: _ChainComplex<T, B, R>, debug: Bool = false) {
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
                    let x1 =  map.appliedTo(a)
                    let y1 = d2.appliedTo(x1)
                    let x2 = d1.appliedTo(a)
                    let y2 =  map.appliedTo(x2)

                    print("\td2 ∘ f1: \(a) ->\t\(x1) ->\t\(y1)")
                    print("\tf2 ∘ d1: \(a) ->\t\(x2) ->\t\(y2)")
                    print()
                }
            }

            assert( (d2 ∘ map).equals(map ∘ d1, forElements: b1.map{ FreeModule($0) } ) )
        }
    }

    public static func +(f1: _ChainMap<T, A, B, R>, f2: _ChainMap<T, A, B, R>) -> _ChainMap<T, A, B, R> {
        return _ChainMap{ a in f1.appliedTo(a) + f2.appliedTo(a) }
    }

    public static prefix func -(f: _ChainMap<T, A, B, R>) -> _ChainMap<T, A, B, R> {
        return _ChainMap{ a in -f.appliedTo(a) }
    }

    public static func ⊕<C>(f1: _ChainMap<T, A, B, R>, f2: _ChainMap<T, A, C, R>) -> _ChainMap<T, A, Sum<B, C>, R> {
        return _ChainMap<T, A, Sum<B, C>, R> { a in f1.appliedTo(a) ⊕ f2.appliedTo(a) }
    }
}

public extension ChainMap where T == Descending {
    public func dualMap(domainChainComplex C: ChainComplex<A, R>) -> CochainMap<Dual<B>, Dual<A>, R> {
        return CochainMap { (d: Dual<B>) -> FreeModule<Dual<A>, R> in
            let i = d.degree
            let values = C.chainBasis(i).flatMap { s -> (Dual<A>, R)? in
                let a = self.appliedTo(s)[d.base]
                return (a != .zero) ? (Dual(s), a) : nil
            }
            return FreeModule(values)
        }
    }
}
