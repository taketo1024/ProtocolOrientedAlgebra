//
//  SimplicialExactSequences.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/12/13.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation
import SwiftyMath

public extension HomologyExactSequence where T == Descending, A == Simplex, B == Simplex, C == Simplex {
    public static func pair(_ X: SimplicialComplex, _ A: SimplicialComplex, _ type: R.Type) -> HomologyExactSequence<A, B, C, R> {

        //             i         j
        //   0 -> CA  --->  CX  ---> CXA -> 0  (exact)
        //

        typealias C = ChainComplex
        typealias M = ChainMap

        let (CA, CX, CXA) = (C(A, R.self), C(X, R.self), C(X, A, R.self))

        let i = M.induced(from: SimplicialMap.inclusion(from: A, to: X), R.self)
        let j = M.induced(from: SimplicialMap.inclusion(from: X, to: X), R.self)
        let d = M { (s: Simplex) in s.boundary(R.self) }

        return HomologyExactSequence(CA, i, CX, j, CXA, d)
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

        typealias C = ChainComplex
        typealias M = ChainMap

        let AnB = A ∩ B

        let (CAnB, CA, CB, CX) = (C(AnB, R.self), C(A, R.self), C(B, R.self), C(X, R.self))
        let CAB = CA ⊕ CB

        let iA = M.induced(from: SimplicialMap.inclusion(from: AnB, to: A), R.self)
        let iB = M.induced(from: SimplicialMap.inclusion(from: AnB, to: B), R.self)
        let jA = M.induced(from: SimplicialMap.inclusion(from: A,   to: X), R.self)
        let jB = M.induced(from: SimplicialMap.inclusion(from: B,   to: X), R.self)

        let Δ = ChainMap.diagonal(from: CAnB)
        let i = (iA ⊕ iB) ∘ Δ
        let j = ChainMap { (c: Sum<Simplex, Simplex>) -> SimplicialChain<R>  in
            switch c {
            case let ._1(a): return  jA.applied(to: a)
            case let ._2(b): return -jB.applied(to: b)
            }
        }
        let d = M { (s: Simplex) in s.boundary(R.self) }

        return HomologyExactSequence(CAnB, i, CAB, j, CX, d)
    }
}

public extension CohomologyExactSequence where T == Ascending, A == Dual<Simplex>, B == Dual<Simplex>, C == Dual<Simplex> {
    public static func pair(_ X: SimplicialComplex, _ A: SimplicialComplex, _ type: R.Type) -> CohomologyExactSequence<A, B, C, R> {

        //             i         j
        //   0 -> CA  --->  CX  ---> CXA -> 0  (exact)
        //
        //
        // ==> Hom(-, R)
        //
        //             i*        j*
        //   0 <- C*A <--  C*X  <-- C*XA <- 0  (exact)

        typealias C = ChainComplex<Simplex, R>
        typealias M = ChainMap<Simplex, Simplex, R>

        let (CA, CX, CXA) = (C(A, R.self), C(X, R.self), C(X, A, R.self))
        let (DA, DX, DXA) = (CA.dual, CX.dual, CXA.dual)

        let i = M.induced(from: SimplicialMap.inclusion(from: A, to: X), R.self).dual(domain: CA)
        let j = M.induced(from: SimplicialMap.inclusion(from: X, to: X), R.self).dual(domain: CX)
        let d = M { (s: Simplex) in s.boundary(R.self) }.dual(domain: CXA)

        return CohomologyExactSequence(DXA, j, DX, i, DA, d)
    }
}

public extension CohomologyExactSequence where T == Ascending, A == Dual<Simplex>, B == Sum<Dual<Simplex>, Dual<Simplex>>, C == Dual<Simplex> {
    public static func MayerVietoris(_ X: SimplicialComplex, _ A: SimplicialComplex, _ B: SimplicialComplex, _ type: R.Type) -> CohomologyExactSequence<A, B, C, R> {

        //               A
        //         iA ↗︎     ↘︎ jA
        //   A ∩ B               A ∪ B = X
        //         iB ↘︎     ↗︎ jB
        //               B
        //
        // ==>
        //
        //                   iA* + iB*                jA* ⊕ (-jB)*
        //   0  <- C*(A ∩ B) <-------- C*(A) ⊕ C*(B) <----------- C*(A + B) <- 0  (exact)
        //
        // ==>
        //
        //   .. <- H*(A ∩ B) <-------- H*(A) ⊕ H*(B) <----------- H*(A + B) <- 0  (exact)
        //                                                        ~= H*(X)
        //

        typealias C = ChainComplex
        typealias M = ChainMap

        let AnB = A ∩ B

        let (CAnB, CA, CB, CX) = (C(AnB, R.self), C(A, R.self), C(B, R.self), C(X, R.self))
        let (DAnB, DA, DB, DX) = (CAnB.dual, CA.dual, CB.dual, CX.dual)
        let DAB = DA ⊕ DB

        let iA = M.induced(from: SimplicialMap.inclusion(from: AnB, to: A), R.self).dual(domain: CAnB)
        let iB = M.induced(from: SimplicialMap.inclusion(from: AnB, to: B), R.self).dual(domain: CAnB)
        let jA = M.induced(from: SimplicialMap.inclusion(from: A,   to: X), R.self).dual(domain: CA)
        let jB = M.induced(from: SimplicialMap.inclusion(from: B,   to: X), R.self).dual(domain: CB)

        let i = CochainMap { (c: Sum<Dual<Simplex>, Dual<Simplex>>) -> SimplicialCochain<R>  in
            switch c {
            case let ._1(a): return iA.applied(to: a)
            case let ._2(b): return iB.applied(to: b)
            }
        }

        let Δ = CochainMap.diagonal(from: DX)
        let j = (jA ⊕ (-jB)) ∘ Δ
        let d = M { (s: Simplex) in s.boundary(R.self) }.dual(domain: CX)

        return CohomologyExactSequence(DX, j, DAB, i, DAnB, d)
    }
}

