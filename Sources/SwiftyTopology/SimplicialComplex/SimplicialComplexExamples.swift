//
//  SimplicialComplexExamples.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/11/10.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import SwiftyMath

public extension SimplicialComplex {
    static func point() -> SimplicialComplex {
        let v = Vertex("pt")
        return SimplicialComplex(name: "pt", cells: Simplex([v]))
    }
    
    static func interval(vertices k: Int = 2) -> SimplicialComplex {
        assert(k >= 2)
        let V = Vertex.generate(k)
        let segments = (0 ..< k - 1).map { i in Simplex(vertexSet: V, indices: [i, i + 1]) }
        return SimplicialComplex(name: "I", cells: segments)
    }
    
    static func circle(vertices k: Int = 3) -> SimplicialComplex {
        assert(k >= 3)
        let V = Vertex.generate(k)
        let segments = (0 ..< k).map { i in Simplex(vertexSet: V, indices: [i, (i + 1) % k]) }
        return SimplicialComplex(name: "S^1", cells: segments)
    }
    
    static func sphere(dim n: Int, suspensionVertices k: Int? = nil) -> SimplicialComplex {
        assert(n >= 0)
        assert(k == nil || k! >= 3)
        
        if k == nil || n == 0 {
            let V = Vertex.generate(n + 2)
            let faces = Simplex(vertexSet: V, indices: 0 ... (n + 1)).faces()
            return SimplicialComplex(name: "S^\(n)", cells: faces)
        } else {
            return sphere(dim: n - 1, suspensionVertices: k).suspension(intervalVertices: k!)
        }
    }
    
    static func ball(dim n: Int, suspensionVertices k: Int? = nil) -> SimplicialComplex {
        assert(n >= 0)
        assert(k == nil || k! >= 3)
        
        if k == nil || n == 0 {
            let V = Vertex.generate(n + 1)
            let s = Simplex(vertexSet: V, indices: 0...n)
            return SimplicialComplex(name: "D^\(n)", cells: [s])
        } else {
            let v = Vertex()
            let S = sphere(dim: n - 1, suspensionVertices: k)
            return v.join(S)
        }
    }
    
    static func torus(dim: Int, circleVertices n: Int = 3) -> SimplicialComplex {
        let S = SimplicialComplex.circle(vertices: n)
        return S.pow(dim).named("T^\(dim)")
    }
    
    // ref: Minimal Triangulations of Manifolds https://arxiv.org/pdf/math/0701735.pdf
    // ref: How to triangulate real projective spaces https://mathoverflow.net/a/50394
    static func realProjectiveSpace(dim n: Int) -> SimplicialComplex {
        switch n {
        case 1:
            return circle().named("RP^1")
            
        case 2:
            let V = Vertex.generate(6)
            let indices = [(0,1,3),(1,4,3),(1,2,4),(4,2,0),(4,0,5),(0,1,5),(1,2,5),(2,3,5),(0,3,2),(3,4,5)]
            let simplices = indices.map { v in Simplex(vertexSet: V, indices: [v.0, v.1, v.2]) }
            return SimplicialComplex(name: "RP^2", cells: simplices)
            
        case 3:
            let V = Vertex.generate(11)
            let indices = [(1,2,3,7), (1,2,3,0), (1,2,6,9), (1,2,6,0), (1,2,7,9), (1,3,5,10), (1,3,5,0), (1,3,7,10), (1,4,7,9), (1,4,7,10), (1,4,8,9), (1,4,8,10), (1,5,6,8), (1,5,6,0), (1,5,8,10), (1,6,8,9), (2,3,4,8), (2,3,4,0), (2,3,7,8), (2,4,6,10), (2,4,6,0), (2,4,8,10), (2,5,7,8), (2,5,7,9), (2,5,8,10), (2,5,9,10), (2,6,9,10), (3,4,5,9), (3,4,5,0), (3,4,8,9), (3,5,9,10), (3,6,7,8), (3,6,7,10), (3,6,8,9), (3,6,9,10), (4,5,6,7), (4,5,6,0), (4,5,7,9), (4,6,7,10), (5,6,7,8)]
            let simplices = indices.map { v in Simplex(vertexSet: V, indices: [v.0, v.1, v.2, v.3]) }
            return SimplicialComplex(name: "RP^3", cells: simplices)
 
        default:
            let S = sphere(dim: n)
            let (K, s2b, b2s) = S._barycentricSubdivision()
            
            func antipodal(_ v: Vertex) -> Vertex {
                let s = b2s[v]!
                let t = Simplex( S.link(s).vertices )
                return s2b[t]!
            }
            
            var table = [Vertex : Vertex]()
            for v in K.vertices {
                if table[v] != nil {
                    continue
                }
                let w = antipodal(v)
                table[w] = v
            }
            
            return K.identifyVertices(table).named("RP^\(n)")
        }
    }
    
    static func mobiusStrip(circleVertices k: Int = 3, intervalVertices l: Int = 3) -> SimplicialComplex {
        let I1 = interval(vertices: k + 1)
        let I2 = interval(vertices: l)
        let K = I1 × I2
        return K.identifyVertices( (0 ..< l).map { i in
            (I1.vertices[0] × I2.vertices[i], I1.vertices[k] × I2.vertices[l - 1 - i])
        } ).named("M")
    }
    
    static func kleinBottle(circleVertices k: Int = 3) -> SimplicialComplex {
        let I = interval(vertices: k + 1)
        let K = I × I
        return
            K.identifyVertices(
                (0 ... k).map { i in
                    (I.vertices[i] × I.vertices[k], I.vertices[i] × I.vertices[0])
                }
            ).identifyVertices(
                (0 ..< k).map { i in
                    (I.vertices[k] × I.vertices[k - 1 - i], I.vertices[0] × I.vertices[i])
                }
            ).named("Kl")
    }
    
    static func lensSpace(_ p: Int) -> SimplicialComplex {
        let q = 1 // TODO: q > 1
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
