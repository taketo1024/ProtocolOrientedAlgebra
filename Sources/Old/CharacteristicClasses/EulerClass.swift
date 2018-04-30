//
//  TopologicalInvariants.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/11/10.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation
import SwiftyAlgebra

// TODO absract up to GeometricComplex
public extension SimplicialComplex {
    public var eulerClass: CohomologyClass<Dual<Simplex>, 𝐙>? {
        return eulerClass(𝐙.self)
    }

    public func eulerClass<R: EuclideanRing>(_ type: R.Type) -> CohomologyClass<Dual<Simplex>, R>? {
        fatalError("not working")

        // See [Milnor-Stasheff: Characteristic Classes §11]

        let M = self
        let d = SimplicialMap.diagonal(from: M)

        let MxM = M × M
        let ΔM = d.image

        let cH = Cohomology(MxM, MxM - ΔM, R.self) // TODO this
        let top = cH[dim]

        if top.isFree && top.rank == 1 {
            let u = top.generator(0).representative
            let e = d.asCochainMap(R.self).applied(to: u)  // the Euler class of M
            return CohomologyClass(e, Cohomology(self, R.self))
        } else {
            return nil
        }
    }
}

public func e(_ M: SimplicialComplex) -> CohomologyClass<Dual<Simplex>, 𝐙> {
    return M.eulerClass!
}

public func e<R: EuclideanRing>(_ M: SimplicialComplex, _ type: R.Type) -> CohomologyClass<Dual<Simplex>, R> {
    return M.eulerClass(R.self)!
}
