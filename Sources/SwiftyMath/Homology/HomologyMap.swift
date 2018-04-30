//
//  HomologyMap.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/12/12.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public typealias   HomologyMap<A: BasisElementType, B: BasisElementType, R: EuclideanRing> = _HomologyMap<Descending, A, B, R>
public typealias CohomologyMap<A: BasisElementType, B: BasisElementType, R: EuclideanRing> = _HomologyMap<Ascending,  A, B, R>

public struct _HomologyMap<T: ChainType, A: BasisElementType, B: BasisElementType, R: EuclideanRing>: ModuleHomType {
    public typealias CoeffRing = R
    public typealias Domain   = _HomologyClass<T, A, R>
    public typealias Codomain = _HomologyClass<T, B, R>

    private let f: (Domain) -> Codomain

    public init(_ f: @escaping (_HomologyClass<T, A, R>) -> _HomologyClass<T, B, R>) {
        self.f = f
    }

    public func applied(to x: _HomologyClass<T, A, R>) -> _HomologyClass<T, B, R> {
        return f(x)
    }

    public static func induced(from chainMap: _ChainMap<T, A, B, R>, codomainStructure H: _Homology<T, B, R>) -> _HomologyMap<T, A, B, R> {
        return _HomologyMap { x in
            H.homologyClass(chainMap.applied(to: x.representative))
        }
    }
}

