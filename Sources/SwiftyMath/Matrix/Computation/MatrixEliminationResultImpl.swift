//
//  MatrixEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/06/09.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

internal class MatrixEliminationResultImpl<R: EuclideanRing> {
    let result: MatrixImpl<R>
    let rowOps: [MatrixEliminator<R>.ElementaryOperation]
    let colOps: [MatrixEliminator<R>.ElementaryOperation]
    let form: MatrixForm

    required init(_ result: MatrixImpl<R>, _ rowOps: [MatrixEliminator<R>.ElementaryOperation], _ colOps: [MatrixEliminator<R>.ElementaryOperation], _ form: MatrixForm) {
        self.result = result
        self.rowOps = rowOps
        self.colOps = colOps
        self.form = form
    }

    final lazy var left: MatrixImpl<R>         = _left()
    final lazy var leftInverse: MatrixImpl<R>  = _leftInverse()
    final lazy var right: MatrixImpl<R>        = _right()
    final lazy var rightInverse: MatrixImpl<R> = _rightInverse()
    final lazy var rank: Int                            = _rank()
    final lazy var diagonal: [R]                        = _diagonal()
    final lazy var inverse: MatrixImpl<R>?     = _inverse()
    final lazy var determinant: R                       = _determinant()
    final lazy var kernelMatrix: MatrixImpl<R> = _kernelMatrix()
    final lazy var imageMatrix: MatrixImpl<R>  = _imageMatrix()
    final lazy var kernelTransitionMatrix: MatrixImpl<R> = _kernelTransitionMatrix()

    final var nullity: Int {
        return result.cols - rank
    }

    final var isInjective: Bool {
        return result.cols <= result.rows && rank == result.cols
    }

    final var isSurjective: Bool {
        return result.cols >= result.rows && rank == result.rows && diagonal.forAll{ $0.isInvertible }
    }

    final var isBijective: Bool {
        return isInjective && isSurjective
    }

    @_specialize(where R == ComputationSpecializedRing)
    final func _left() -> MatrixImpl<R> {
        let P = MatrixImpl<R>.identity(size: result.rows, align: .Rows)
        for s in rowOps {
            s.apply(to: P)
        }
        return P
    }

    @_specialize(where R == ComputationSpecializedRing)
    final func _leftInverse(restrictedToCols colRange: CountableRange<Int>? = nil) -> MatrixImpl<R> {
        let P = (colRange == nil)
            ? MatrixImpl<R>.identity(size: result.rows, align: .Rows)
            : MatrixImpl<R>.identity(size: result.rows, align: .Rows).submatrix(colRange: colRange!)

        for s in rowOps.reversed() {
            s.inverse.apply(to: P)
        }

        return P
    }

    @_specialize(where R == ComputationSpecializedRing)
    final func _right() -> MatrixImpl<R> {
        let P = MatrixImpl<R>.identity(size: result.cols, align: .Cols)
        for s in colOps {
            s.apply(to: P)
        }
        return P
    }

    @_specialize(where R == ComputationSpecializedRing)
    final func _rightInverse(restrictedToRows rowRange: CountableRange<Int>? = nil) -> MatrixImpl<R> {
        let P = (rowRange == nil)
            ? MatrixImpl<R>.identity(size: result.cols, align: .Cols)
            : MatrixImpl<R>.identity(size: result.cols, align: .Cols).submatrix(rowRange: rowRange!)

        for s in colOps.reversed() {
            s.inverse.apply(to: P)
        }

        return P
    }

    // override points

    func _rank() -> Int {
        fatalError("not available.")
    }

    func _diagonal() -> [R]{
        fatalError("not available.")
    }

    func _inverse() -> MatrixImpl<R>? {
        fatalError("not available.")
    }

    func _determinant() -> R {
        fatalError("not available.")
    }

    func _kernelMatrix() -> MatrixImpl<R> {
        fatalError("not available.")
    }

    func _imageMatrix() -> MatrixImpl<R> {
        fatalError("not available.")
    }

    func _kernelTransitionMatrix() -> MatrixImpl<R> {
        fatalError("not available.")
    }
}
