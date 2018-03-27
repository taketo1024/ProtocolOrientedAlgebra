//
//  GeometricComplex.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/05/28.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation
import SwiftyAlgebra

public protocol GeometricComplex: CustomStringConvertible {
    associatedtype Cell: GeometricCell

    var name: String { get }
    var dim: Int { get }

    func contains(_ cell: Cell) -> Bool

    var allCells: [Cell] { get }
    func cells(ofDim: Int) -> [Cell]
    func skeleton(_ dim: Int) -> Self

    func boundaryMap<R: Ring>(_ i: Int, _ type: R.Type) -> FreeModuleHom<Cell, Cell, R>

    // MEMO would better write (if possible)
    //
    // extension<G> Dual<G.Cell> {
    //   func coboundary<R>(in: G, _ type: R.Type) -> ... {
    //
    func coboundary<R: Ring>(of d: Dual<Cell>, _ type: R.Type) -> FreeModule<Dual<Cell>, R>
}

public extension GeometricComplex {
    public var name: String {
        return "_" // TODO
    }

    public func contains(_ cell: Cell) -> Bool {
        return cells(ofDim: cell.dim).contains(cell)
    }

    internal var validDims: [Int] {
        return (dim >= 0) ? (0 ... dim).toArray() : []
    }

    public var allCells: [Cell] {
        return validDims.flatMap{ cells(ofDim: $0) }
    }

    public func boundaryMap<R: Ring>(_ i: Int, _ type: R.Type) -> FreeModuleHom<Cell, Cell, R> {
        return FreeModuleHom { s in
            (s.dim == i) ? s.boundary(R.self) : .zero
        }
    }

    public func coboundary<R: Ring>(of d: Dual<Cell>, _ type: R.Type) -> FreeModule<Dual<Cell>, R> {
        let s = d.base
        let e = R(from: (-1).pow(d.degree + 1))
        let vals = cells(ofDim: d.degree + 1).flatMap{ t -> (Dual<Cell>, R)? in
            let a = t.boundary(R.self)[s]
            return (a != .zero) ? (Dual(t), e * a) : nil
        }
        return FreeModule(vals)
    }

    public var description: String {
        return (name == "_") ? "\(type(of: self))" : name
    }

    public var detailDescription: String {
        return "\(description) {\n" +
            validDims.map{ (i) -> (Int, [Cell]) in (i, cells(ofDim: i)) }
                     .map{ (i, cells) -> String in "\t\(i): " + cells.map{"\($0)"}.joined(separator: ", ")}
                     .joined(separator: "\n")
            + "\n}"
    }
}
