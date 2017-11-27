//
//  SimplicialComplexExamples.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/11/10.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public extension SimplicialComplex {
    static func point() -> SimplicialComplex {
        let v = Vertex("pt")
        return SimplicialComplex(name: "pt", allCells: Simplex([v]))
    }

    static func interval(vertices n: Int = 2) -> SimplicialComplex {
        assert(n >= 2)
        let V = Vertex.generate(n)
        let segments = (0 ..< n - 1).map { i in Simplex(vertexSet: V, indices: [i, i + 1]) }
        return SimplicialComplex(name: "I", maximalCells: segments)
    }

    static func circle(vertices n: Int = 3) -> SimplicialComplex {
        assert(n >= 3)
        let V = Vertex.generate(n)
        let segments = (0 ..< n).map { i in Simplex(vertexSet: V, indices: [i, (i + 1) % n]) }
        return SimplicialComplex(name: "S^1", maximalCells: segments)
    }

    static func sphere(dim: Int) -> SimplicialComplex {
        let V = Vertex.generate(dim + 2)
        let faces = Simplex(vertexSet: V, indices: 0 ... (dim + 1)).faces()
        return SimplicialComplex(name: "S^\(dim)", maximalCells: faces)
    }

    static func ball(dim: Int) -> SimplicialComplex {
        let V = Vertex.generate(dim + 1)
        let s = Simplex(vertexSet: V, indices: 0...dim)
        return SimplicialComplex(name: "D^\(dim)", maximalCells: [s])
    }

    static func torus(dim: Int) -> SimplicialComplex {
        let S = SimplicialComplex.circle()
        var T = (1 ..< dim).reduce(S) { (K, _) in K × S }
        T.name = "T^\(dim)"
        return T
    }

    // ref: Minimal Triangulations of Manifolds https://arxiv.org/pdf/math/0701735.pdf
    static func realProjectiveSpace(dim: Int) -> SimplicialComplex {
        switch dim {
        case 1:
            return circle()
        case 2:
            let V = Vertex.generate(6)
            let indices = [(0,1,3),(1,4,3),(1,2,4),(4,2,0),(4,0,5),(0,1,5),(1,2,5),(2,3,5),(0,3,2),(3,4,5)]
            let simplices = indices.map { v in Simplex(vertexSet: V, indices: [v.0, v.1, v.2]) }
            return SimplicialComplex(name: "RP^2", maximalCells: simplices)
        case 3:
            let V = Vertex.generate(11)
            let indices = [(1,2,3,7), (1,2,3,0), (1,2,6,9), (1,2,6,0), (1,2,7,9), (1,3,5,10), (1,3,5,0), (1,3,7,10), (1,4,7,9), (1,4,7,10), (1,4,8,9), (1,4,8,10), (1,5,6,8), (1,5,6,0), (1,5,8,10), (1,6,8,9), (2,3,4,8), (2,3,4,0), (2,3,7,8), (2,4,6,10), (2,4,6,0), (2,4,8,10), (2,5,7,8), (2,5,7,9), (2,5,8,10), (2,5,9,10), (2,6,9,10), (3,4,5,9), (3,4,5,0), (3,4,8,9), (3,5,9,10), (3,6,7,8), (3,6,7,10), (3,6,8,9), (3,6,9,10), (4,5,6,7), (4,5,6,0), (4,5,7,9), (4,6,7,10), (5,6,7,8)]
            let simplices = indices.map { v in Simplex(vertexSet: V, indices: [v.0, v.1, v.2, v.3]) }
            return SimplicialComplex(name: "RP^3", maximalCells: simplices)
        default:
            fatalError("RP^n (n >= 4) not yet supported.")
        }
    }

    static func lensSpace(_ n: Int) -> SimplicialComplex {
        let (p, q) = (n, 1) // TODO: q > 1
        let k = 3 // #vertices of a circle
        let kp = k * p

        let B1 = SimplicialComplex.circle(vertices: k * p)
        let B2 = SimplicialComplex.circle(vertices: k * p)
        let D1 = Vertex().join(B1)
        let D2 = Vertex().join(B2)

        let S = SimplicialComplex.circle(vertices: k) // the fiber S^1
        let K1 = (D1 × S) + (D2 × S) // disjoint union

        let L = K1.identifyVertices(B1.vertices.enumerated().flatMap { (i, b1) -> [(Vertex, Vertex)] in
            let b2 = B2.vertices[(kp - i) % kp]
            return S.vertices.enumerated().map { (j, v) -> (Vertex, Vertex) in
                let w = S.vertices[((kp - i) * q + j) % k]
                return (b2 × w, b1 × v)
            }}).named("L(\(p),\(q))")

        return L
    }
}
