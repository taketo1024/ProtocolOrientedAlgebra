//
//  SimplicialComplex.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/05/17.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation
import SwiftyAlgebra

public struct SimplicialComplex: GeometricComplex {
    public typealias Cell = Simplex

    public var name: String
    public let dim: Int

    public let vertices: [Vertex]
    public let maximalCells: [Simplex]
    private let _table = Cache<[[Simplex]]>()

    public init<S: Sequence>(name: String? = nil, cells: S, filterMaximalCells: Bool = false) where S.Iterator.Element == Simplex {
        self.name = name ?? "_"
        self.maximalCells = filterMaximalCells ? SimplicialComplex.filterMaximalCells(cells) : cells.toArray()
        self.vertices = maximalCells.reduce(Set<Vertex>()){ (set, s) in set.union(s.vertices) }.sorted()
        self.dim = maximalCells.reduce(-1){ (res, s) in max(res, s.dim) }
    }

    public init(name: String? = nil, cells: Simplex...) {
        self.init(name: name, cells: cells)
    }

    public static var empty: SimplicialComplex {
        return SimplicialComplex.init(name: "∅", cells: [])
    }

    public func skeleton(_ i: Int) -> SimplicialComplex {
        if validDims.contains(i) {
            return SimplicialComplex(name: "\(self.name)_(\(i))", cells: table[i])
        } else {
            return SimplicialComplex.empty
        }
    }

    public func cells(ofDim i: Int) -> [Simplex] {
        return validDims.contains(i) ? table[i] : []
    }

    public func cofaces(ofCell s: Simplex) -> [Simplex] {
        return cells(ofDim: s.dim + 1).filter{ $0.contains(s) }
    }

    public func named(_ name: String) -> SimplicialComplex {
        var K = self
        K.name = name
        return K
    }

    internal var table: [[Simplex]] {
        if let table = _table.value {
            return table
        }

        let set = maximalCells.reduce( Set<Simplex>() ){ (set, cell) in
            set.union( cell.allSubsimplices() )
        }

        var table: [[Simplex]] = (0 ... dim).map{_ in []}
        for s in set {
            table[s.dim].append(s)
        }
        table = table.map{ list in list.sorted() }

        _table.value = table
        return table
    }

    static public func filterMaximalCells<S: Sequence>(_ _cells: S) -> [Simplex] where S.Element == Simplex {
        var result = [Simplex]()
        for s in _cells.sorted().reversed() {
            if result.forAll({ t in !t.contains(s) }) {
                result.append(s)
            }
        }
        return result
    }
}
