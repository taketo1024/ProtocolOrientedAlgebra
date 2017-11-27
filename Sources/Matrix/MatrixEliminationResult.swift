//
//  MatrixEliminator.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/06/09.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public class MatrixEliminationResult<R: EuclideanRing> {
    public let result: ComputationalMatrix<R>
    internal let rowOps: [MatrixEliminator<R>.ElementaryOperation]
    internal let colOps: [MatrixEliminator<R>.ElementaryOperation]
    public let form: MatrixForm

    public required init(_ result: ComputationalMatrix<R>, _ rowOps: [MatrixEliminator<R>.ElementaryOperation], _ colOps: [MatrixEliminator<R>.ElementaryOperation], _ form: MatrixForm) {
        self.result = result
        self.rowOps = rowOps
        self.colOps = colOps
        self.form = form
    }

    public lazy var left: ComputationalMatrix<R>         = _left()
    public lazy var leftInverse: ComputationalMatrix<R>  = _leftInverse()
    public lazy var right: ComputationalMatrix<R>        = _right()
    public lazy var rightInverse: ComputationalMatrix<R> = _rightInverse()

    @_specialize(where R == IntegerNumber)
    internal func _left() -> ComputationalMatrix<R> {
        let P = ComputationalMatrix<R>.identity(result.rows)
        for s in rowOps {
            s.apply(to: P)
        }
        return P
    }

    @_specialize(where R == IntegerNumber)
    internal func _leftInverse(restrictedToCols colRange: CountableRange<Int>? = nil) -> ComputationalMatrix<R> {
        let P = (colRange == nil)
            ? ComputationalMatrix<R>.identity(result.rows)
            : ComputationalMatrix<R>.identity(result.rows).submatrix(colRange: colRange!)

        for s in rowOps.reversed() {
            s.inverse.apply(to: P)
        }

        return P
    }

    @_specialize(where R == IntegerNumber)
    internal func _right() -> ComputationalMatrix<R> {
        let P = ComputationalMatrix<R>.identity(result.cols, align: .Cols)
        for s in colOps {
            s.apply(to: P)
        }
        return P
    }

    @_specialize(where R == IntegerNumber)
    internal func _rightInverse(restrictedToRows rowRange: CountableRange<Int>? = nil) -> ComputationalMatrix<R> {
        let P = (rowRange == nil)
            ? ComputationalMatrix<R>.identity(result.cols, align: .Cols)
            : ComputationalMatrix<R>.identity(result.cols, align: .Cols).submatrix(rowRange: rowRange!)

        for s in colOps.reversed() {
            s.inverse.apply(to: P)
        }

        return P
    }

    public var rank: Int {
        fatalError("not available.")
    }

    public var diagonal: [R]{
        fatalError("not available.")
    }

    public var inverse: ComputationalMatrix<R>? {
        fatalError("not available.")
    }

    public var determinant: R {
        fatalError("not available.")
    }

    public var kernelMatrix: ComputationalMatrix<R> {
        fatalError("not available.")
    }

    public var imageMatrix: ComputationalMatrix<R> {
        fatalError("not available.")
    }

    public var kernelTransitionMatrix: ComputationalMatrix<R> {
        fatalError("not available.")
    }
}

// A Wrapper struct for Matrix<n, m, R> types.

public struct MatrixEliminationResultWrapper<n: _Int, m: _Int, R: EuclideanRing> {
    private let res: MatrixEliminationResult<R>

    public init<n, m>(_ matrix: Matrix<n, m, R>, _ res: MatrixEliminationResult<R>) {
        self.res = res
    }

    public var result: Matrix<n, m, R> {
        return res.result.asMatrix()
    }

    public var left: Matrix<n, n, R> {
        return res.left.asMatrix()
    }

    public var leftInverse: Matrix<n, n, R> {
        return res.leftInverse.asMatrix()
    }

    public var right: Matrix<m, m, R> {
        return res.right.asMatrix()
    }

    public var rightInverse: Matrix<m, m, R> {
        return res.rightInverse.asMatrix()
    }

    public var rank: Int {
        return res.rank
    }

    public var diagonal: [R] {
        return res.diagonal
    }

    public var kernelBasis: [ColVector<m, R>] {
        let matrix = res.kernelMatrix.asMatrix() as Matrix<m, Dynamic, R>
        return (0 ..< matrix.cols).map{ matrix.colVector($0) }
    }

    public var imageBasis: [ColVector<n, R>] {
        let matrix = res.imageMatrix.asMatrix() as Matrix<n, Dynamic, R>
        return (0 ..< matrix.cols).map{ matrix.colVector($0) }
    }
}

public extension MatrixEliminationResultWrapper where n == m {
    public var inverse: Matrix<n, n, R>? {
        return res.inverse?.asMatrix()
    }

    public var determinant: R {
        return res.determinant
    }
}
