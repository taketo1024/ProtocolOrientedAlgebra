//
//  HomologyMap.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/12/12.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public typealias   HomologyMap<A: FreeModuleBase, B: FreeModuleBase, R: EuclideanRing> = _HomologyMap<Descending, A, B, R>
public typealias CohomologyMap<A: FreeModuleBase, B: FreeModuleBase, R: EuclideanRing> = _HomologyMap<Ascending,  A, B, R>

public struct _HomologyMap<T: ChainType, A: FreeModuleBase, B: FreeModuleBase, R: EuclideanRing>: ModuleHom {
    public typealias CoeffRing = R
    public typealias Domain   = _HomologyClass<T, A, R>
    public typealias Codomain = _HomologyClass<T, B, R>

    internal let from: _Homology<T, A, R>
    internal let to:   _Homology<T, B, R>
    internal let chainMap: _ChainMap<T, A, B, R>
    internal let shift: Int

    public init(from: _Homology<T, A, R>, to: _Homology<T, B, R>, inducedFrom chainMap: _ChainMap<T, A, B, R>, shift: Int = 0) {
        self.from = from
        self.to   = to
        self.chainMap = chainMap
        self.shift = shift
    }

    public func appliedTo(_ x: _HomologyClass<T, A, R>) -> _HomologyClass<T, B, R> {
        return _HomologyClass(chainMap.appliedTo(x.representative), to)
    }

    public static func ==(lhs: _HomologyMap<T, A, B, R>, rhs: _HomologyMap<T, A, B, R>) -> Bool {
        fatalError("not yet impled.")
    }

    public static var zero: _HomologyMap<T, A, B, R> {
        fatalError("not yet impled.")
    }

    public static func +(a: _HomologyMap<T, A, B, R>, b: _HomologyMap<T, A, B, R>) -> _HomologyMap<T, A, B, R> {
        fatalError("not yet impled.")
    }

    public static prefix func -(x: _HomologyMap<T, A, B, R>) -> _HomologyMap<T, A, B, R> {
        fatalError("not yet impled.")
    }

    public static func *(r: R, m: _HomologyMap<T, A, B, R>) -> _HomologyMap<T, A, B, R> {
        fatalError("not yet impled.")
    }

    public static func *(m: _HomologyMap<T, A, B, R>, r: R) -> _HomologyMap<T, A, B, R> {
        fatalError("not yet impled.")
    }

    public var hashValue: Int {
        return 0 // TODO
    }
}

