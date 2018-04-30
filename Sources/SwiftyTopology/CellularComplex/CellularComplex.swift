//
//  CellularComplex.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/07/26.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import SwiftyMath

public typealias CellularChain<R: Ring> = FreeModule<CellularCell, R>

public struct CellularCell: GeometricCell {
    public let simplices: SimplicialChain<𝐙>
    internal let boundary: CellularChain<𝐙>

    internal init(_ simplices: SimplicialChain<𝐙>, _ boundary: CellularChain<𝐙>) {
        assert(!simplices.basis.isEmpty)
        assert({
            let n = simplices.basis[0].dim
            return simplices.basis.forAll{$0.dim == n}
        }())

        self.simplices = simplices
        self.boundary = boundary
    }

    public var dim: Int {
        return simplices.basis[0].dim
    }

    public func boundary<R: Ring>(_ type: R.Type) -> FreeModule<CellularCell, R> {
        return boundary.mapValues{ R(from: $0) }
    }

    public var hashValue: Int {
        return 0 // TODO
    }

    public static func < (lhs: CellularCell, rhs: CellularCell) -> Bool {
        return lhs != rhs // TODO
    }

    public static func ==(a: CellularCell, b: CellularCell) -> Bool {
        return a.simplices == b.simplices
    }

    public var description: String {
        return "e\(dim)(\(simplices))"
    }
}

public struct CellularComplex: GeometricComplex {
    public typealias Cell = CellularCell
    public typealias Map = CellularMap

    public internal(set) var underlyingComplex: SimplicialComplex
    internal var table: [[CellularCell]]

    public init(underlyingComplex: SimplicialComplex) {
        self.init(underlyingComplex, [])
    }

    internal init(_ K: SimplicialComplex, _ table: [[CellularCell]] = []) {
        self.underlyingComplex = K
        self.table = table
    }

    public static var empty: CellularComplex {
        return CellularComplex.init(underlyingComplex: SimplicialComplex.empty)
    }

    public var dim: Int {
        return table.count - 1
    }

    public func skeleton(_ n: Int) -> CellularComplex {
        if n >= 0 {
            let sub = table[0 ... n].toArray()
            return CellularComplex(underlyingComplex, sub)
        } else {
            return CellularComplex.empty
        }
    }

    public func cells(ofDim i: Int) -> [CellularCell] {
        return validDims.contains(i) ? table[i] : []
    }

    @discardableResult
    public mutating func appendVertex(_ v: Vertex) -> CellularCell {
        let c = SimplicialChain<𝐙>(Simplex(v))
        return appendCell(simplices: c)
    }

    @discardableResult
    public mutating func appendCell(simplices: SimplicialChain<𝐙>, attachedAlong boundary: CellularChain<𝐙> = .zero) -> CellularCell {
        if !simplices.basis.forAll({ underlyingComplex.contains($0) }) {
            let K = SimplicialComplex(cells: simplices.basis )
            self.underlyingComplex = self.underlyingComplex + K
        }

        let n = simplices.basis[0].dim
        assert(boundary.basis.forAll{ $0.dim == n - 1 }, "only attatching to 1-dim lower cells is supported.")

        while table.count - 1 < n {
            table.append([])
        }

        let cell = CellularCell(simplices, boundary)
        table[n].append(cell)

        return cell
    }
}

public extension CellularComplex {
    static func point() -> CellularComplex {
        let K = SimplicialComplex.point()
        var C = CellularComplex(underlyingComplex: K)
        C.appendVertex(K.vertices[0])
        return C
    }

    static func interval(vertices n: Int = 2) -> CellularComplex {
        let K = SimplicialComplex.interval(vertices: n)
        var C = CellularComplex(underlyingComplex: K)
        let v0 = C.appendVertex(K.vertices[0])
        let v1 = C.appendVertex(K.vertices[n - 1])
        let c = SimplicialChain(K.cells(ofDim: 1).map{ ($0, 1)} )
        C.appendCell(simplices: c, attachedAlong: CellularChain([(v1, 1), (v0, -1)]))
        return C
    }

    static func circle(vertices k: Int = 3) -> CellularComplex {
        return CellularComplex.sphere(dim: 1)
    }

    static func sphere(dim n: Int, suspensionVertices k: Int? = nil) -> CellularComplex {
        assert(n >= 0)

        let K = SimplicialComplex.sphere(dim: n, suspensionVertices: k)
        var C = CellularComplex(underlyingComplex: K)

        if n == 0 {
            C.appendVertex(K.vertices[0])
            C.appendVertex(K.vertices[1])
        } else {
            C.appendVertex(K.vertices[0])
            C.appendCell(simplices: SimplicialChain(K.cells(ofDim: 1).map{ ($0, 1)} ))
        }

        return C
    }

    static func ball(dim: Int) -> CellularComplex {
        fatalError("TBD")
    }

    static func torus(dim: Int) -> SimplicialComplex {
        fatalError("TBD")
    }
}

// TODO
public struct CellularMap: GeometricComplexMap {
    public typealias Domain = CellularCell
    public typealias Codomain = CellularCell
    public typealias Complex = CellularComplex

    public init(_ f: @escaping (CellularCell) -> CellularCell) {
        fatalError()
    }

    public func applied(to x: CellularCell) -> CellularCell {
        fatalError()
    }

    public static func inclusion(from: CellularComplex, to: CellularComplex) -> CellularMap {
        fatalError()
    }

    public static func diagonal(from: CellularComplex) -> CellularMap {
        fatalError()
    }
}
