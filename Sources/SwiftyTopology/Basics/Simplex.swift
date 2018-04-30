//
//  Simplex.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/05/03.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import SwiftyMath

public struct Simplex: GeometricCell, Comparable {
    public let vertices: [Vertex]          // vertices in input order.
    internal let sortedVertices: [Vertex]  // vertices in v-id ordering.
    internal let unorderedVertices: Set<Vertex>  // unordered set of vertices.

    private let id: String
    private let label: String

    public init<S: Sequence>(_ vs: S) where S.Iterator.Element == Vertex {
        assert(vs.isUnique)
        let vertices = vs.toArray()
        let unordered = Set(vertices)
        assert(vertices.count == unordered.count)

        self.vertices = vs.toArray()
        self.sortedVertices = vs.sorted()
        self.unorderedVertices = Set(vs)

        self.id = sortedVertices.map{ "\($0.id)" }.joined(separator: ",")
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
        var vs = sortedVertices
        vs.remove(at: index)
        return Simplex(vs)
    }

    public func faces() -> [Simplex] {
        if dim <= 0 {
            return []
        } else {
            return (0 ... dim).map{ face($0) }
        }
    }

    public func subsimplicices(dim k: Int) -> [Simplex] {
        guard 0 <= k && k <= dim else {
            return []
        }

        if k == dim {
            return [self]
        } else if k == 0 {
            return vertices.map{ v in Simplex(v) }
        } else {
            return (dim + 1).choose(k + 1).map { I in Simplex(vertexSet: vertices, indices: I) }
        }
    }

    public var isEmpty: Bool {
        return dim == -1
    }

    public func contains(_ v: Vertex) -> Bool {
        return unorderedVertices.contains(v)
    }

    public func contains(_ s: Simplex) -> Bool {
        return s.unorderedVertices.isSubset(of: self.unorderedVertices)
    }

    public func subtract(_ s: Simplex) -> Simplex {
        return Simplex(self.unorderedVertices.subtracting(s.unorderedVertices))
    }

    public func subtract(_ v: Vertex) -> Simplex {
        return Simplex(self.unorderedVertices.subtracting([v]))
    }

    public func boundary<R: Ring>(_ type: R.Type) -> SimplicialChain<R> {
        let values: [(Simplex, R)] = faces().enumerated().map { (i, t) -> (Simplex, R) in
            let e = R(from: (-1).pow(i))
            return (t, e)
        }
        return SimplicialChain(values)
    }

    public static func ∪(_ s1: Simplex, _ s2: Simplex) -> Simplex {
        return Simplex(s1.unorderedVertices.union(s2.unorderedVertices))
    }

    public static func ∩(_ s1: Simplex, _ s2: Simplex) -> Simplex {
        return Simplex(s1.unorderedVertices.intersection(s2.unorderedVertices))
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
}
