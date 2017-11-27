//
//  SimplicialComplexOperations.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/11/06.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

// Operations
public extension SimplicialComplex {
    public func star(_ v: Vertex) -> [Simplex] { // returns only maximal cells
        return maximalCells.filter{ $0.contains(v) }
    }

    public func star(_ s: Simplex) -> [Simplex] { // returns only maximal cells
        return maximalCells.filter{ $0.contains(s) }
    }

    public func link(_ v: Vertex) -> [Simplex] { // returns only maximal cells
        return star(v).map{ $0.subtract(v) }.filter{ $0.dim >= 0 }
    }

    public func link(_ s: Simplex) -> [Simplex] { // returns only maximal cells
        return star(s).map{ $0.subtract(s) }.filter{ $0.dim >= 0 }
    }

    public var boundaryVertices: [Vertex] {
        return vertices.filter { v in
            SimplicialComplex(maximalCells: self.link(v)).orientationCycle == nil
        }
    }

    public func identifyVertices(_ pairs: [(Vertex, Vertex)]) -> SimplicialComplex {
        let dict = Dictionary(pairs: pairs)
        let map = SimplicialMap(from: self) { v in dict[v] ?? v }
        return map.image
    }

    // disjoint union
    public static func +(K1: SimplicialComplex, K2: SimplicialComplex) -> SimplicialComplex {
        let dim = max(K1.dim, K2.dim)
        let cells = (0 ... dim).map{ i in (K1.cells(ofDim: i) + K2.cells(ofDim: i)).unique() }
        return SimplicialComplex(name: "\(K1) + \(K2)", cells)
    }

    // subtraction (the result may not be a proper simplicial complex)
    public static func -(K1: SimplicialComplex, v: Vertex) -> SimplicialComplex {
        return K1 - Simplex(v)
    }

    public static func -(K1: SimplicialComplex, s: Simplex) -> SimplicialComplex {
        let K2 = SimplicialComplex(name: s.description, allCells: [s])
        return K1 - K2
    }

    public static func -(K1: SimplicialComplex, K2: SimplicialComplex) -> SimplicialComplex {
        let subtr = K2.allCells
        let cells = K1.cellTable.map{ list -> [Simplex] in
            return list.filter{ s in subtr.forAll{ !s.contains($0) } }
        }
        return SimplicialComplex(name: "\(K1) - \(K2)", cells)
    }

    // product complex
    public static func ×(K1: SimplicialComplex, K2: SimplicialComplex) -> SimplicialComplex {
        let simplexPairs = K1.maximalCells.allCombinations(with: K2.maximalCells)
        let vertexPairs  = simplexPairs.flatMap{ (s, t) -> [[(Vertex, Vertex)]] in
            let k = s.dim + t.dim

            // list of indices with each (k + 1)-elements in increasing order
            let Is: [[Int]] = (s.dim + 1).multichoose(k + 1)
            let Js: [[Int]] = (t.dim + 1).multichoose(k + 1)

            // list of pairs of ordered indices [(I, J), ...]
            let allPairs: [([Int], [Int])]  = Is.allCombinations(with: Js)

            // filter valid pairs that form a k-simplex
            // if (I[i], J[i]) == (I[i + 1], J[i + 1]), then these two vertices collapse.
            let validPairs = allPairs.filter{ (I, J) in
                (0 ..< k).forAll{ (i: Int) -> Bool in (I[i], J[i]) != (I[i + 1], J[i + 1]) }
            }

            // indexPairs that correspond to the indices of each VertexSets
            return validPairs.map{ (I, J) -> [(Vertex, Vertex)] in
                zip(I, J).map{ (i, j) in (s.vertices[i], t.vertices[j]) }
            }
        }

        let cells = vertexPairs.map { (list: [(Vertex, Vertex)]) -> Simplex in
            let vertices = list.map{ (v, w) in v × w }
            return Simplex(vertices)
        }

        return SimplicialComplex(name: "\(K1.name) × \(K2.name)", maximalCells: cells)
    }

    public func connectedSum(with K2: SimplicialComplex) -> SimplicialComplex {
        assert(self.dim == K2.dim)
        let (s1, s2) = (self.cells(ofDim: self.dim).anyElement!, K2.cells(ofDim: self.dim).anyElement!)
        return ((self + K2) - s1 - s2).identifyVertices(s1.vertices.enumerated().map{ (i, v) in (v, s2.vertices[i])})
    }

    public var barycentricSubdivision: SimplicialComplex {
        return _barycentricSubdivision().0
    }

    internal func _barycentricSubdivision() -> (SimplicialComplex, s2b: [Simplex: Vertex], b2s: [Vertex: Simplex]) {
        var bcells = Set<Simplex>()

        var b2s: [Vertex: Simplex] = [:]
        var s2b: [Simplex: Vertex] = [:]

        func generate(cells: [Simplex], barycenters: [Vertex]) {
            let s = cells.last!
            let v = s2b[s] ?? {
                let v = (s.dim > 0) ? Vertex(prefix: "b") : s.vertices.first!
                b2s[v] = s
                s2b[s] = v
                return v
                }()

            if s.dim > 0 {
                for t in s.faces() {
                    generate(cells: cells + [t], barycenters: barycenters + [v])
                }
            } else {
                let bcell = Simplex(barycenters + [v])
                bcells.insert(bcell)
            }
        }

        for s in self.maximalCells {
            generate(cells: [s], barycenters: [])
        }

        return (SimplicialComplex(name: "Sd(\(name))", maximalCells: bcells), s2b, b2s)
    }
}

public extension Vertex {
    public func join(_ K: SimplicialComplex) -> SimplicialComplex {
        let cells = K.maximalCells.map{ s in self.join(s) }
        return SimplicialComplex(name: "\(self) * \(K.name)", maximalCells: cells)
    }
}
