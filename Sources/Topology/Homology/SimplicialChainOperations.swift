//
//  SimplicialChainOperations.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/02/10.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation
import SwiftyAlgebra

public typealias SimplicialChain<R: Ring>   = FreeModule<Simplex, R>
public typealias SimplicialCochain<R: Ring> = FreeModule<Dual<Simplex>, R>

public extension SimplicialChain where A == Simplex {
    public func boundary() -> SimplicialChain<R> {
        return self.reduce(SimplicialChain<R>.zero) { (res, next) -> SimplicialChain<R> in
            let (s, r) = next
            return res + r * s.boundary(R.self)
        }
    }
}

public extension SimplicialCochain where A == Dual<Simplex> {
    public func coboundary(in K: SimplicialComplex) -> SimplicialCochain<R> {
        return self.reduce(SimplicialCochain<R>.zero) { (res, next) -> SimplicialCochain<R> in
            let (d, r) = next
            return res + r * K.coboundary(of: d, R.self)
        }
    }

    public func cup(_ f: SimplicialCochain<R>) -> SimplicialCochain<R> {
        typealias D = Dual<Simplex>

        func cup(_ d1: D, _ d2: D) -> (D, R)? {
            let (s1, s2) = (d1.base, d2.base)

            if s1.sortedVertices.last! == s2.sortedVertices.first! {

                let s = s1 ∪ s2 // MEMO: this simplex may not be a member of the simplicial complex.
                let (n1, n2) = (s1.dim, s2.dim)
                let e = R(from: (-1).pow(n1 * n2))

                return (Dual(s), e * self[d1] * f[d2])
            } else {
                return nil
            }
        }

        let pairs = self.basis.allCombinations(with: f.basis)
        let elements = pairs.flatMap{ (d1, d2) in cup(d1, d2) }

        return SimplicialCochain<R>(elements)
    }

    public func cap(_ z: SimplicialChain<R>) -> SimplicialChain<R> {
        typealias C = SimplicialChain<R>

        func cap(_ f: Dual<Simplex>, _ s: Simplex) -> (Simplex, R)? {
            let (i, j) = (s.dim, f.base.dim)
            assert(i >= j)

            let (s1, s2) = (Simplex(s.sortedVertices[0 ... j]), Simplex(s.sortedVertices[j ... i]))
            if s1 == f.base {
                let e = R(from: (-1).pow(s1.dim * s2.dim))
                return (s2, e)
            } else {
                return nil
            }
        }

        return z.sum { (s, r1) -> C in
            let eval = self.sum { (f, r2) -> C in
                if let (s2, e) = cap(f, s) {
                    return C([(s2, e * r2)])
                } else {
                    return .zero
                }
            }
            return r1 * eval
        }
    }

    public static func ∪<R>(a: SimplicialCochain<R>, b: SimplicialCochain<R>) -> SimplicialCochain<R> {
        return a.cup(b)
    }

    public static func ∩<R>(a: SimplicialCochain<R>, b: SimplicialChain<R>) -> SimplicialChain<R> {
        return a.cap(b)
    }
}

public extension SimplicialCochain where A == Dual<Simplex>, R == 𝐙₂ {

    // Steenrod's cup-n product.
    // The formula is given here: https://arxiv.org/abs/math/0110314
    // see Prop 5.1 (pg 12)

    public func cup(_ n: Int, _ g: SimplicialCochain<R>) -> SimplicialCochain<R> {
        func cup(_ d1: A, _ d2: A) -> (A, R)? {
            let (s1, s2) = (d1.base, d2.base)
            guard n <= s1.dim, n <= s2.dim else {
                return nil
            }

            let z = s1 ∪ s2  // (p + q - n)-simplex
            let w = s1 ∩ s2  // must be an n-simplex

            guard w.dim == n else {
                return nil
            }

            // d1 ∪_n d2 = z^* only when:
            //
            //  z  = (v_0  .. v_i0 .. v_i1 .. v_i2 .. v_i3 ..)  // union
            //  w  = (        v_i0    v_i1    v_i2    v_i3   )  // intersection
            //  s1 = (v_0  .. v_i0    v_i1 .. v_i2    v_i3 ..)  // even union
            //  s2 = (        v_i0 .. v_i1    v_i2 .. v13    )  // odd union

            var i = 0
            var e = true
            let even = z.sortedVertices.filter { v in
                if i <= w.dim && w.sortedVertices[i] == v {
                    defer {
                        e = !e
                        i = i + 1
                    }
                    return true
                }
                return e
            }

            if s1.sortedVertices == even {
                return (A(z), 1)
            } else {
                return nil
            }
        }

        let pairs = self.basis.allCombinations(with: g.basis)
        let elements = pairs.flatMap{ (d1, d2) in cup(d1, d2) }
                            .group{ $0.0 }
                            .map{ (d, e) in (d, e.sum{ $0.1 }) }

        return SimplicialCochain<R>(elements)
    }

    public func Sq(_ i: Int) -> SimplicialCochain<R> {
        let n = self.anyElement?.0.degree ?? 0 // MEMO only supports homogeneous element
        return self.cup(n - i, self)
    }
}
