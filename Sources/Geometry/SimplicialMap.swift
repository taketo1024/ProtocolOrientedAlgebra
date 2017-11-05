//
//  SimplicialMap.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/11/05.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public struct SimplicialMap: GeometricComplexMap {
    public typealias ComplexType = SimplicialComplex
    public typealias Domain      = Simplex
    public typealias Codomain    = Simplex
    
    public var domain:   SimplicialComplex
    public var codomain: SimplicialComplex?
    private let map: (Vertex) -> Vertex
    
    public init(from: SimplicialComplex, to: SimplicialComplex? = nil, _ map: @escaping (Vertex) -> Vertex) {
        self.domain = from
        self.codomain = to
        self.map = map
    }
    
    public init(from: SimplicialComplex, to: SimplicialComplex? = nil, _ map: [Vertex: Vertex]) {
        self.init(from: from, to: to, { v in map[v]! })
    }
    
    public var image: SimplicialComplex {
        let cells = domain.cells.map{ cells in
            cells.flatMap{ s -> Simplex? in
                let t = self.appliedTo(s)
                return (s.dim == t.dim) ? t : nil
            }
        }
        return SimplicialComplex(cells)
    }
    
    public func appliedTo(_ x: Vertex) -> Vertex {
        return map(x)
    }
    
    public func appliedTo(_ s: Simplex) -> Simplex {
        return Simplex(s.vertices.map{ self.appliedTo($0) }.unique())
    }
    
    public static func identity(from: SimplicialComplex) -> SimplicialMap {
        return SimplicialMap(from: from) { v in v }
    }
    
    public static func diagonal(from: SimplicialComplex) -> SimplicialMap {
        return SimplicialMap(from: from) { v in v × v }
    }
    
    public static func projection(from: SimplicialComplex, _ i: Int) -> SimplicialMap {
        return SimplicialMap(from: from) { v in v.components[i] }
    }
}
