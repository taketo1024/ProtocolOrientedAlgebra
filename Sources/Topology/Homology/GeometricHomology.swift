//
//  GeometricComplexExtensions.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2018/02/10.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation
import SwiftyAlgebra

// TODO implement `ChainComplex.dual`

public extension ChainComplex where T == Descending {
    public init<C: GeometricComplex>(_ K: C, _ type: R.Type) where A == C.Cell {
        let chain = K.validDims.map{ (i) -> (ChainBasis, BoundaryMap) in
            (K.cells(ofDim: i), K.boundaryMap(i, R.self))
        }
        self.init(name: K.name, chain)
    }

    public init<C: GeometricComplex>(_ K: C, _ L: C, _ type: R.Type) where A == C.Cell {
        let chain = K.validDims.map{ (i) -> (ChainBasis, BoundaryMap) in

            let from = K.cells(ofDim: i).subtract(L.cells(ofDim: i))
            let map  = K.boundaryMap(i, R.self)

            return (from, map)
        }
        self.init(name: "\(K.name), \(L.name)", chain)
    }
}

public extension CochainComplex where T == Ascending {
    public init<C: GeometricComplex>(_ K: C, _ type: R.Type) where Dual<C.Cell> == A {
        let cochain = K.validDims.map{ (i) -> (ChainBasis, BoundaryMap) in
            let from = K.cells(ofDim: i)
            let map = BoundaryMap { d in FreeModule(K.coboundary(of: d, R.self)) }
            return (from.map{ Dual($0) }, map)
        }
        self.init(name: K.name, cochain)
    }

    public init<C: GeometricComplex>(_ K: C, _ L: C, _ type: R.Type) where Dual<C.Cell> == A {
        let cochain = K.validDims.map{ (i) -> (ChainBasis, BoundaryMap) in
            let from = K.cells(ofDim: i).subtract(L.cells(ofDim: i))
            let to   = K.cells(ofDim: i + 1).subtract(L.cells(ofDim: i + 1))

            let map = BoundaryMap { d in
                let c = K.coboundary(of: d, R.self)
                let vals = c.filter{ (d, _) in to.contains( d.base ) }
                return FreeModule(vals)
            }

            return (from.map{ Dual($0) }, map)
        }
        self.init(name: "\(K.name), \(L.name)", cochain)
    }
}

public extension Homology where T == Descending {
    public convenience init<C: GeometricComplex>(_ K: C, _ type: R.Type) where C.Cell == A {
        let c = ChainComplex(K, type)
        self.init(c)
    }

    public convenience init<C: GeometricComplex>(_ K: C, _ L: C, _ type: R.Type) where C.Cell == A {
        let c = ChainComplex(K, L, type)
        self.init(c)
    }
}

public extension Cohomology where T == Ascending {
    public convenience init<C: GeometricComplex>(_ K: C, _ type: R.Type) where Dual<C.Cell> == A {
        let c = CochainComplex(K, type)
        self.init(c)
    }

    public convenience init<C: GeometricComplex>(_ K: C, _ L: C, _ type: R.Type) where Dual<C.Cell> == A {
        let c = CochainComplex(K, L, type)
        self.init(c)
    }
}
