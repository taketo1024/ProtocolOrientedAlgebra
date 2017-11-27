//
//  GeometricComplexMap.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/11/05.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public protocol GeometricComplexMap: Map where Domain == ComplexType.Cell, Codomain == ComplexType.Cell {
    associatedtype ComplexType: GeometricComplex
    var domain:   ComplexType { get }
    var codomain: ComplexType? { get }
    var image:    ComplexType { get }
}

public extension GeometricComplexMap {
    public func asChainMap<R: EuclideanRing>(_ type: R.Type) -> ChainMap<ComplexType.Cell, ComplexType.Cell, R> {
        return ChainMap(self, R.self)
    }
    
    public func asCochainMap<R: EuclideanRing>(_ type: R.Type) -> CochainMap<Dual<ComplexType.Cell>, Dual<ComplexType.Cell>, R> {
        return CochainMap(self, R.self)
    }
}

public extension ChainMap where chainType == Descending {
    
    // f: K1 -> K2  ==> f_*: C(K1) -> C(K2)
    //                          s |-> f(s)
    public init<F: GeometricComplexMap>(_ f: F, _ type: R.Type) where A == F.ComplexType.Cell, B == F.ComplexType.Cell {
        typealias Cell = F.ComplexType.Cell
        self.init { s -> [(Cell, R)] in
            let t = f.appliedTo(s)
            return (s.dim == t.dim) ? [(t, .identity)] : []
        }
    }
}

public extension CochainMap where chainType == Ascending {
    
    // f: K1 -> K2  ==> f^*: C^*(K2) -> C^*(K1) , pullback
    //                            g  -> (g∘f: s -> g∘f(s))
    
    public init<F: GeometricComplexMap>(_ f: F, _ type: R.Type) where A == Dual<F.ComplexType.Cell>, B == Dual<F.ComplexType.Cell> {
        typealias Cell = F.ComplexType.Cell
        self.init { (g: Dual<Cell>) -> [(Dual<Cell>, R)] in
            let i = g.degree
            let ss = f.domain.cells(ofDim: i)
            return ss.flatMap { (s: Cell) -> (Dual<Cell>, R)? in
                let t = f.appliedTo(s)
                return (g.pair(t) == 1) ? (Dual(s), .identity) : nil
            }
        }
    }
}
