//
//  SimplicialExactSequences.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/12/13.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation
import SwiftyAlgebra

public extension HomologyExactSequence where T == Descending, A == Simplex, B == Simplex, C == Simplex {
    public init(_ X: SimplicialComplex, _ A: SimplicialComplex, _ type: R.Type) {

        //             i         j
        //   0 -> CA  --->  CX  ---> CXA -> 0  (exact)
        //

        let CA  = ChainComplex(A, type)
        let CX  = ChainComplex(X, type)
        let CXA = ChainComplex(X, A, type)

        let i = ChainMap(SimplicialMap.inclusion(from: A, to: X), R.self)
        let j = ChainMap(from: CX, to: CXA) { (s: Simplex) in
            CXA.chainBasis(s.degree).contains(s) ? SimplicialChain(s) : SimplicialChain.zero
        }
        let d = ChainMap(from: CXA, to: CA, shift: -1) { (s: Simplex) in
            s.boundary(R.self)
        }

        self.init(CA, i, CX, j, CXA, d)
    }
}

public extension HomologyExactSequence where T == Descending, A == Simplex, B == Sum<Simplex, Simplex>, C == Simplex {
    public static func MayerVietoris(_ X: SimplicialComplex, _ A: SimplicialComplex, _ B: SimplicialComplex, _ type: R.Type) -> HomologyExactSequence<A, B, C, R> {

        //               A
        //         iA ↗︎     ↘︎ jA
        //   A ∩ B               A ∪ B = X
        //         iB ↘︎     ↗︎ jB
        //               B
        //
        // ==>
        //                   iA⊕iB               jA-jB
        //   0  -> C(A ∩ B) ------> C(A) ⊕ C(B) ------> C(A + B) -> 0  (exact)
        //
        // ==>
        //
        //   .. -> H(A ∩ B) ------> H(A) ⊕ H(B) ------> H(A + B) ~= H(X) -> ... (exact)
        //

        let AnB = A ∩ B

        let CAnB = ChainComplex(AnB, type)
        let CA   = ChainComplex(A,   type)
        let CB   = ChainComplex(B,   type)
        let CX   = ChainComplex(X,   type)

        let iA = ChainMap(SimplicialMap.inclusion(from: AnB, to: A), R.self)
        let iB = ChainMap(SimplicialMap.inclusion(from: AnB, to: B), R.self)
        let jA = ChainMap(SimplicialMap.inclusion(from: A,   to: X), R.self)
        let jB = ChainMap(SimplicialMap.inclusion(from: B,   to: X), R.self)

        let CAoB = CA ⊕ CB
        let i    = iA ⊕ iB

        let j = ChainMap(from: CAoB, to: CX) { c in
            switch c {
            case let ._1(a): return  jA.appliedTo(a)
            case let ._2(b): return -jB.appliedTo(b)
            }
        }

        let d = ChainMap(from: CX, to: CAnB, shift: -1) { s in
            A.contains(s) ? s.boundary(type) : SimplicialChain.zero
        }

        return HomologyExactSequence(CAnB, i, CAoB, j, CX, d)
    }
}

public extension CohomologyExactSequence where T == Ascending, A == Dual<Simplex>, B == Dual<Simplex>, C == Dual<Simplex> {
    public init(_ X: SimplicialComplex, _ A: SimplicialComplex, _ type: R.Type) {

        //             i         j
        //   0 -> CA  --->  CX  ---> CXA -> 0  (exact)
        //
        //
        // ==> Hom(-, R)
        //
        //             i*        j*
        //   0 <- C*A <--  C*X  <-- C*XA <- 0  (exact)

        let CXA = CochainComplex(X, A, type)
        let CX  = CochainComplex(X, type)
        let CA  = CochainComplex(A, type)

        let i = CochainMap(SimplicialMap.inclusion(from: A, to: X), R.self)
        let j = CochainMap(from: CXA, to: CX) { d in SimplicialCochain(d) }
        let d = CochainMap(from: CA, to: CXA, shift: +1) { d in X.coboundary(of: d, R.self) }

        self.init(CXA, j, CX, i, CA, d)
    }
}

public extension CohomologyExactSequence where T == Ascending, A == Dual<Simplex>, B == Sum<Dual<Simplex>, Dual<Simplex>>, C == Dual<Simplex> {
    public static func MayerVietoris(_ X: SimplicialComplex, _ A: SimplicialComplex, _ B: SimplicialComplex, _ type: R.Type) -> CohomologyExactSequence<A, B, C, R> {

        //                   jA⊕(-jB)                 iA+iB
        //   0  -> C*(A + B) --------> C*(A) ⊕ C*(B) ------> C*(A ∩ B) -> 0  (exact)
        //
        // ==>
        //
        //   .. -> H*(A + B) --------> H*(A) ⊕ H*(B) ------> H*(A ∩ B) -> ... (exact)
        //         ~= H*(X)
        //

        let AnB = A ∩ B

        let CX   = CochainComplex(X,   type)
        let CA   = CochainComplex(A,   type)
        let CB   = CochainComplex(B,   type)
        let CAnB = CochainComplex(AnB, type)

        let jA = CochainMap(SimplicialMap.inclusion(from: A,   to: X), R.self)
        let jB = CochainMap(SimplicialMap.inclusion(from: B,   to: X), R.self)

        let CAoB = CA ⊕ CB
        let j    = jA ⊕ (-jB)

        let i = CochainMap(from: CAoB, to: CAnB) { d in
            switch d {
            case let ._1(dA): return FreeModule(dA)
            case let ._2(dB): return FreeModule(dB)
            }
        }

        let d = CochainMap(from: CAnB, to: CX, shift: +1) { d in A.coboundary(of: d, R.self) }

        return CohomologyExactSequence(CX, j, CAoB, i, CAnB, d)
    }
}
