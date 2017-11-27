//
//  SimplicialComplex.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/05/17.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public struct SimplicialComplex: GeometricComplex {
    public typealias Cell = Simplex
    
    public var name: String
    public let vertices: [Vertex]
    internal let cellTable: [[Simplex]]
    
    // root initializer
    internal init(name: String? = nil, _ cellTable: [[Simplex]]) {
        self.name = name ?? "_"
        self.cellTable = cellTable
        self.vertices = cellTable[0].map{ $0.vertices[0] }
    }
    
    public init<S: Sequence>(name: String? = nil, allCells cells: S) where S.Iterator.Element == Simplex {
        self.init(name: name, SimplicialComplex.alignCells(cells, generateFaces: false))
    }
    
    public init(name: String? = nil, allCells cells: Simplex...) {
        self.init(name: name, allCells: cells)
    }
    
    public init<S: Sequence>(name: String? = nil, maximalCells cells: S) where S.Iterator.Element == Simplex {
        self.init(name: name, SimplicialComplex.alignCells(cells, generateFaces: true))
    }
    
    public init(name: String? = nil, maximalCells cells: Simplex...) {
        self.init(name: name, maximalCells: cells)
    }
    
    public var dim: Int {
        return cellTable.count - 1
    }
    
    public func skeleton(_ dim: Int) -> SimplicialComplex {
        let sub = Array(cellTable[0 ... dim])
        return SimplicialComplex(name: "\(self.name)_(\(dim))", sub)
    }
    
    public func cells(ofDim i: Int) -> [Simplex] {
        return (0...dim).contains(i) ? cellTable[i] : []
    }
    
    private var _maximalCells: Cache<[Simplex]> = Cache()
    
    public var maximalCells: [Simplex] {
        if let cells = _maximalCells.value {
            return cells
        }
        
        var cells = Array(self.cellTable.reversed().joined())
        var i = 0
        while i < cells.count {
            let s = cells[i]
            let subs = s.allSubsimplices().dropFirst()
            for t in subs {
                if let j = cells.index(of: t) {
                    cells.remove(at: j)
                }
            }
            i += 1
        }
        
        _maximalCells.value = cells
        return cells
    }
    
    public func boundary<R: Ring>(ofCell s: Simplex, _ type: R.Type) -> FreeModule<Simplex, R> {
        return s.boundary(R.self)
    }
    
    public func cofaces(ofCell s: Simplex) -> [Simplex] {
        return cells(ofDim: s.dim + 1).filter{ $0.contains(s) }
    }
    
    public func named(_ name: String) -> SimplicialComplex {
        var K = self
        K.name = name
        return K
    }
    
    internal static func alignCells<S: Sequence>(_ cells: S, generateFaces gFlag: Bool) -> [[Simplex]] where S.Iterator.Element == Simplex {
        let dim = cells.reduce(0) { max($0, $1.dim) }
        let set = gFlag ? cells.reduce( [] ){ (set, cell) in set.union( cell.allSubsimplices() ) }
                        : Set(cells)
        
        var cells: [[Simplex]] = (0 ... dim).map{_ in []}
        for s in set {
            cells[s.dim].append(s)
        }
        
        return cells.map { list in list.sorted() }
    }
}
