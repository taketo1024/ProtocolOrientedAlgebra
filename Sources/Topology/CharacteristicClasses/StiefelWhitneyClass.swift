//
//  StiefelWhitneyClass.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/02/12.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation
import SwiftyAlgebra

public extension SimplicialComplex {
    internal func StiefelWhitneyClass(_ k: Int, _ v: [CohomologyClass<Dual<Simplex>, 𝐙₂>]) -> CohomologyClass<Dual<Simplex>, 𝐙₂>? {
        return (0 ... k).sum { i in
            v[i].Sq(k - i)
        }
    }

    public func StiefelWhitneyClass(_ k: Int) -> CohomologyClass<Dual<Simplex>, 𝐙₂>? {
        return StiefelWhitneyClass(k, WuClasses)
    }

    public var StiefelWhitneyClasses: [CohomologyClass<Dual<Simplex>, 𝐙₂>] {
        return validDims.flatMap { k in StiefelWhitneyClass(k, WuClasses) }
    }

    public var totalStiefelWhitneyClass: CohomologyClass<Dual<Simplex>, 𝐙₂> {
        return StiefelWhitneyClasses.sumAll()
    }
}

public func w(_ i: Int, _ M: SimplicialComplex) -> CohomologyClass<Dual<Simplex>, 𝐙₂> {
    return M.StiefelWhitneyClass(i)!
}

public func w(_ M: SimplicialComplex) -> CohomologyClass<Dual<Simplex>, 𝐙₂> {
    return M.totalStiefelWhitneyClass
}
