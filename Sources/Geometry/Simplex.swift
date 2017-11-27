//
//  Simplex.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public struct Simplex: GeometricCell, Comparable {
    public let vertices: [Vertex] // ordered list of vertices.
    fileprivate let unorderedVertices: Set<Vertex>  // unordered set of vertices.
    
    private let id: String
    private let label: String
    
    public init<S: Sequence>(_ vs: S) where S.Iterator.Element == Vertex {
        let vertices = vs.toArray()
        let unordered = Set(vertices)
        assert(vertices.count == unordered.count)
        
        self.vertices = vertices
        self.unorderedVertices = unordered
        self.id = vertices.sorted().map{ "\($0.id)" }.joined(separator: ",")
        self.label = (vertices.count == 1) ? vertices.first!.label : "(\(vertices.map{ $0.label }.joined(separator: ", ")))"
    }
    
    public init(_ vs: Vertex...) {
        self.init(vs)
    }
    
    public init<S: Sequence>(vertexSet V: [Vertex], indices: S) where S.Element == Int {
        self.init(indices.map{ V[$0] })
    }
    
    public var dim: Int {
        return vertices.count - 1
    }
    
    public func index(ofVertex v: Vertex) -> Int? {
        return vertices.index(of: v)
    }
    
    public func face(_ index: Int) -> Simplex {
        var vs = vertices.sorted()
        vs.remove(at: index)
        return Simplex(vs)
    }
    
    public func faces() -> [Simplex] {
        if dim == 0 {
            return []
        } else {
            return (0 ... dim).map{ face($0) }
        }
    }
    
    public func contains(_ v: Vertex) -> Bool {
        return unorderedVertices.contains(v)
    }
    
    public func contains(_ s: Simplex) -> Bool {
        return s.unorderedVertices.isSubset(of: self.unorderedVertices)
    }
    
    public func allSubsimplices() -> [Simplex] {
        var queue = [self]
        var i = 0
        while(i < queue.count) {
            let s = queue[i]
            if s.dim > 0 {
                queue += queue[i].faces()
            }
            i += 1
        }
        return queue.unique()
    }
    
    public func join(_ s: Simplex) -> Simplex {
        return Simplex(self.unorderedVertices.union(s.unorderedVertices))
    }
    
    public func subtract(_ s: Simplex) -> Simplex {
        return Simplex(self.unorderedVertices.subtracting(s.unorderedVertices))
    }
    
    public func subtract(_ v: Vertex) -> Simplex {
        return Simplex(self.unorderedVertices.subtracting([v]))
    }
    
    public func boundary<R: Ring>(_ type: R.Type) -> SimplicialChain<R> {
        let values: [(Simplex, R)] = faces().enumerated().map { (i, t) -> (Simplex, R) in
            let e = R(intValue: (-1).pow(i))
            return (t, e)
        }
        return SimplicialChain(values)
    }
    
    public var hashValue: Int {
        return id.hashValue
    }
    
    public static func ==(a: Simplex, b: Simplex) -> Bool {
        return a.id == b.id
    }
    
    public static func <(a: Simplex, b: Simplex) -> Bool {
        if a.dim == b.dim {
            for (v, w) in zip(a.vertices, b.vertices) {
                if v == w {
                    continue
                } else {
                    return v < w
                }
            }
            return false
        } else {
            return a.dim < b.dim
        }
    }
    
    public var description: String {
        return label
    }
}

public extension Vertex {
    public func join(_ s: Simplex) -> Simplex {
        return Simplex([self] + s.vertices)
    }
    
    public func join<R>(_ chain: SimplicialChain<R>) -> SimplicialChain<R> {
        return SimplicialChain(chain.basis.map{ (s) -> (Simplex, R) in
            let t = self.join(s)
            let e = R(intValue: (-1).pow(t.vertices.index(of: self)!))
            return (t, e * chain[s])
        })
    }
}

public typealias SimplicialChain<R: Ring>   = FreeModule<Simplex, R>
public typealias SimplicialCochain<R: Ring> = FreeModule<Dual<Simplex>, R>

public extension SimplicialChain where A == Simplex {
    public func boundary() -> SimplicialChain<R> {
        return self.reduce(SimplicialChain<R>.zero) { (res, next) -> SimplicialChain<R> in
            let (s, r) = next
            return res + r * s.boundary(R.self)
        }
    }
    
    public func cap(_ d: SimplicialCochain<R>) -> SimplicialChain<R> {
        typealias C = SimplicialChain<R>
        
        return self.reduce(.zero) { (res, next) -> C in
            let (s, r1) = next
            let eval = d.reduce(.zero) { (res, next) -> C in
                let (f, r2) = next
                let (i, j) = (s.dim, f.base.dim)
                assert(i >= j)
                
                let (s1, s2) = (Simplex(s.vertices[0 ... j]), Simplex(s.vertices[j ... i]))
                if s1 == f.base {
                    let e = R(intValue: (-1).pow(s1.dim * s2.dim))
                    return res + e * r2 * SimplicialChain<R>(s2)
                } else {
                    return res
                }
            }
            return res + r1 * eval
        }
    }
}

public extension SimplicialCochain where A == Dual<Simplex> {
    public func cup(_ f: SimplicialCochain<R>) -> SimplicialCochain<R> {
        typealias D = Dual<Simplex>
        let pairs = self.basis.allCombinations(with: f.basis)
        let elements: [(D, R)] = pairs.flatMap{ (d1, d2) -> (D, R)? in
            let (s1, s2) = (d1.base, d2.base)
            let (n1, n2) = (s1.dim, s2.dim)
            
            let s = Simplex(s1.unorderedVertices.union(s2.unorderedVertices))
            if (s1.vertices.last! == s2.vertices.first!) && (s.vertices == s1.vertices + s2.vertices.dropFirst()) {
                let e = R(intValue: (-1).pow(n1 * n2))
                return (Dual(s), e * self[d1] * f[d2])
            } else {
                return nil
            }
        }
        return SimplicialCochain<R>(elements)
    }
    
    public func cap(_ z: SimplicialChain<R>) -> SimplicialChain<R> {
        return z.cap(self)
    }
}

public func ∩<R>(a: SimplicialChain<R>, b: SimplicialCochain<R>) -> SimplicialChain<R> {
    return a.cap(b)
}

public func ∩<R>(a: SimplicialCochain<R>, b: SimplicialChain<R>) -> SimplicialChain<R> {
    return a.cap(b)
}

public func ∪<R>(a: SimplicialCochain<R>, b: SimplicialCochain<R>) -> SimplicialCochain<R> {
    return a.cup(b)
}

