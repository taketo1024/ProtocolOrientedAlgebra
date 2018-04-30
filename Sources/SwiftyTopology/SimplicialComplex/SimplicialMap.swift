//
//  SimplicialMap.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/11/05.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import SwiftyMath

public struct SimplicialMap: GeometricComplexMap {
    public typealias Complex = SimplicialComplex
    public typealias Domain      = Simplex
    public typealias Codomain    = Simplex
    
    private let map: (Simplex) -> Simplex
    
    public init(_ f: @escaping (Vertex) -> Vertex) {
        self.init() { (s: Simplex) in
            Simplex(s.vertices.map(f).unique())
        }
    }
    
    public init(_ f: @escaping (Simplex) -> Simplex) {
        self.map = f
    }
    
    public init(_ map: [Vertex: Vertex]) {
        self.init { v in map[v] ?? v }
    }
    
    public func image(of K: SimplicialComplex) -> SimplicialComplex {
        let cells = K.maximalCells.map { s in self.applied(to: s) }.unique()
        return SimplicialComplex(cells: cells, filterMaximalCells: true)
    }
    
    public func applied(to v: Vertex) -> Vertex {
        return map(Simplex(v)).vertices[0]
    }
    
    public func applied(to s: Simplex) -> Simplex {
        return map(s)
    }
    
    public static var identity: SimplicialMap {
        return SimplicialMap { (s: Simplex) in s }
    }
    
    public static func inclusion(from: SimplicialComplex, to: SimplicialComplex) -> SimplicialMap {
        return identity
    }
    
    public static func diagonal(from: SimplicialComplex) -> SimplicialMap {
        return SimplicialMap { (v: Vertex) in v × v }
    }
    
    public static func projection(_ i: Int) -> SimplicialMap {
        return SimplicialMap { (v: Vertex) in v.components[i] }
    }
}
