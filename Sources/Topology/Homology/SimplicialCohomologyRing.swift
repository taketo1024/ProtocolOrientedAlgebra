//
//  SimplicialCohomologyRing.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/02/10.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation
import SwiftyAlgebra

// TODO conform to Ring after conditional-conformance is supported.

public extension CohomologyClass where T == Ascending, A == Dual<Simplex> {
    public func cup(_ b: CohomologyClass<A, R>) -> CohomologyClass<A, R> {
        let a = self
        guard let H1 = a.structure, let H2 = b.structure else {
            return CohomologyClass.zero
        }

        assert(H1 == H2)

        let x = a.representative.cup(b.representative)
        return CohomologyClass<A, R>(x, H1)
    }

    public static func *(a: CohomologyClass<A, R>, b: CohomologyClass<A, R>) -> CohomologyClass<A, R> {
        return a.cup(b)
    }

    public static func ∪(a: CohomologyClass<A, R>, b: CohomologyClass<A, R>) -> CohomologyClass<A, R> {
        return a.cup(b)
    }

    public func pow(_ n: Int) -> CohomologyClass<A, R> {
        let a = self
        return n == 1 ? a : a * a.pow(n - 1)
    }

    public func cap(_ x: HomologyClass<Simplex, R>) -> HomologyClass<Simplex, R> {
        guard let _ = self.structure, let H2 = x.structure else {
            return HomologyClass.zero
        }

        // TODO check H1, H2 matches.

        let y = self.representative.cap(x.representative)
        return HomologyClass<Simplex, R>(y, H2)
    }

    public static func ∩(a: CohomologyClass<A, R>, x: HomologyClass<Simplex, R>) -> HomologyClass<Simplex, R> {
        return a.cap(x)
    }
}

public extension CohomologyClass where T == Ascending, A == Dual<Simplex>, R == 𝐙₂ {
    public func Sq(_ i: Int) -> CohomologyClass<A, R> {
        if let H = structure {
            let a = self.representative
            return CohomologyClass( a.Sq(i), H )
        } else {
            return CohomologyClass.zero
        }
    }
}
