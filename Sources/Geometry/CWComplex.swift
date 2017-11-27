//
//  CellularComplex.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/07/26.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public typealias CWCellChain = FreeModule<CWCell, IntegerNumber>

public struct CWCell: GeometricCell {
    public let id: Int
    public let dim: Int
    internal let boundary: CWCellChain

    public init(id: Int, dim: Int, boundary: CWCellChain) {
        self.id = id
        self.dim = dim
        self.boundary = boundary
    }

    public var hashValue: Int {
        return id
    }

    public static func ==(a: CWCell, b: CWCell) -> Bool {
        return (a.dim, a.id) == (b.dim, b.id)
    }

    public var description: String {
        return "e\(dim)(\(id))"
    }
}

public struct CWComplex: GeometricComplex {
    public typealias Cell = CWCell

    internal var cells: [[CWCell]]

    public init(_ cells: [[CWCell]] = []) {
        self.cells = cells
    }

    public var dim: Int {
        return max(0, cells.count - 1)
    }

    public func skeleton(_ dim: Int) -> CWComplex {
        let sub = Array(cells[0 ... dim])
        return CWComplex(sub)
    }

    public func cells(ofDim i: Int) -> [CWCell] {
        return (0...dim).contains(i) ? cells[i] : []
    }

    public func boundary<R: Ring>(ofCell s: CWCell, _ type: R.Type) -> FreeModule<CWCell, R> {
        return s.boundary.mapValues{ R(intValue: $0) }
    }

    @discardableResult
    public mutating func appendVertex() -> CWCell {
        return appendCell(ofDim: 0)
    }

    @discardableResult
    public mutating func appendCell(ofDim i: Int, attachedTo boundary: CWCellChain = .zero) -> CWCell {
        assert(boundary.basis.forAll{ $0.dim == i - 1 }, "only attatching to 1-dim lower cells is supported.")

        while cells.count - 1 < i {
            cells.append([])
        }

        let cell = CWCell(id: cells[i].count, dim: i, boundary: boundary)
        cells[i].append(cell)

        return cell
    }
}

public extension CWComplex {
    static func point() -> CWComplex {
        return CWComplex.ball(dim: 0)
    }

    static func interval() -> CWComplex {
        return CWComplex.ball(dim: 1)
    }

    static func circle() -> CWComplex {
        return CWComplex.sphere(dim: 1)
    }

    static func ball(dim: Int) -> CWComplex {
        fatalError()
    }

    static func sphere(dim i: Int) -> CWComplex {
        if i == 0 {
            var C = CWComplex()
            C.appendVertex()
            C.appendVertex()
            return C
        } else {
            var C = CWComplex.sphere(dim: i - 1)
            let (d1, d2) = (C.cells[i - 1][0], C.cells[i - 1][1])
            let cycle = (i == 1) ? CWCellChain([(d1, -1), (d2, 1)])
                : CWCellChain([(d1,  1), (d2, 1)])
            C.appendCell(ofDim: i, attachedTo: cycle)
            C.appendCell(ofDim: i, attachedTo: -cycle)
            return C
        }
    }

    static func torus(dim: Int) -> SimplicialComplex {
        fatalError("TBD")
    }
}

