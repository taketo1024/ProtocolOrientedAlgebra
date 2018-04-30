//
//  SimplicialCohomologyRing.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/02/10.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import SwiftyMath

public typealias SimplicialHomology<R: EuclideanRing> = Homology<Simplex, R>
public typealias SimplicialHomologyClass<R: EuclideanRing> = HomologyClass<Simplex, R>

public typealias SimplicialCohomology<R: EuclideanRing> = Cohomology<Dual<Simplex>, R>
public typealias SimplicialCohomologyClass<R: EuclideanRing> = CohomologyClass<Dual<Simplex>, R>

// TODO conform to Ring after conditional-conformance is supported.

public extension SimplicialCohomologyClass where T == Ascending, A == Dual<Simplex> {
    public func cup(_ b: SimplicialCohomologyClass<R>) -> SimplicialCohomologyClass<R> {
        let a = self
        guard let H1 = a.structure, let H2 = b.structure else {
            return SimplicialCohomologyClass.zero
        }
        
        assert(H1 == H2)
        
        let x = a.representative.cup(b.representative)
        return H1.homologyClass(x)
    }
    
    public static func *(a: SimplicialCohomologyClass<R>, b: SimplicialCohomologyClass<R>) -> SimplicialCohomologyClass<R> {
        return a.cup(b)
    }
    
    public static func ∪(a: SimplicialCohomologyClass<R>, b: SimplicialCohomologyClass<R>) -> SimplicialCohomologyClass<R> {
        return a.cup(b)
    }
    
    public func pow(_ n: Int) -> SimplicialCohomologyClass<R> {
        let a = self
        return n == 1 ? a : a * a.pow(n - 1)
    }

    public func cap(_ x: HomologyClass<Simplex, R>) -> SimplicialHomologyClass<R> {
        guard let _ = self.structure, let H2 = x.structure else {
            return .zero
        }
        
        // TODO check H1, H2 matches.
        
        let y = self.representative.cap(x.representative)
        return H2.homologyClass(y)
    }
    
    public static func ∩(a: SimplicialCohomologyClass<R>, x: SimplicialHomologyClass<R>) -> SimplicialHomologyClass<R> {
        return a.cap(x)
    }
}

public extension SimplicialCohomologyClass where T == Ascending, A == Dual<Simplex>, R == 𝐙₂ {
    public func Sq(_ i: Int) -> SimplicialCohomologyClass<R> {
        if let H = structure {
            let a = self.representative
            return H.homologyClass(a.Sq(i))
        } else {
            return .zero
        }
    }
}
