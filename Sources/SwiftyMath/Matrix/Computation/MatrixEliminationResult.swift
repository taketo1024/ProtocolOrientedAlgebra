//
//  MatrixEliminationResult.swift
//  Sample
//
//  Created by Taketo Sano on 2018/04/26.
//

import Foundation

public struct MatrixEliminationResult<n: SizeType, m: SizeType, R: EuclideanRing> {
    internal let impl: MatrixEliminationResultImpl<R>
    
    internal init(_ impl: MatrixEliminationResultImpl<R>) {
        self.impl = impl
    }
    
    public var result: Matrix<n, m, R> {
        return Matrix(impl.result)
    }
    
    public var left: Matrix<n, n, R> {
        return Matrix(impl.left)
    }
    
    public var leftInverse: Matrix<n, n, R> {
        return Matrix(impl.leftInverse)
    }
    
    public var right: Matrix<m, m, R> {
        return Matrix(impl.right)
    }
    
    public var rightInverse: Matrix<m, m, R> {
        return Matrix(impl.rightInverse)
    }
    
    public var rank: Int {
        return impl.rank
    }
    
    public var nullity: Int {
        return impl.nullity
    }
    
    public var diagonal: [R] {
        return impl.diagonal
    }
    
    public var kernelMatrix: Matrix<m, DynamicSize, R> {
        return Matrix(impl.kernelMatrix)
    }
    
    public var kernelTransitionMatrix: Matrix<DynamicSize, m, R> {
        return Matrix(impl.kernelTransitionMatrix)
    }
    
    public var imageMatrix: Matrix<n, DynamicSize, R> {
        return Matrix(impl.imageMatrix)
    }
    
    public var imageTransitionMatrix: Matrix<DynamicSize, n, R> {
        return Matrix(impl.imageTransitionMatrix)
    }
    
    public var isInjective: Bool {
        return impl.isInjective
    }
    
    public var isSurjective: Bool {
        return impl.isSurjective
    }
    
    public var isBijective: Bool {
        return impl.isBijective
    }
}

public extension MatrixEliminationResult where n == m {
    var inverse: Matrix<n, n, R>? {
        return impl.inverse.map{ Matrix($0) }
    }
    
    var determinant: R {
        return impl.determinant
    }
}

internal class MatrixEliminationResultImpl<R: EuclideanRing> {
    let result: MatrixImpl<R>
    let rowOps: [MatrixEliminator<R>.ElementaryOperation]
    let colOps: [MatrixEliminator<R>.ElementaryOperation]
    
    required init(_ result: MatrixImpl<R>, _ rowOps: [MatrixEliminator<R>.ElementaryOperation], _ colOps: [MatrixEliminator<R>.ElementaryOperation]) {
        self.result = result
        self.rowOps = rowOps
        self.colOps = colOps
    }
    
    final lazy var left: MatrixImpl<R>         = _left()
    final lazy var leftInverse: MatrixImpl<R>  = _leftInverse()
    final lazy var right: MatrixImpl<R>        = _right()
    final lazy var rightInverse: MatrixImpl<R> = _rightInverse()
    final lazy var rank: Int                   = _rank()
    final lazy var diagonal: [R]               = _diagonal()
    final lazy var inverse: MatrixImpl<R>?     = _inverse()
    final lazy var determinant: R              = _determinant()
    final lazy var kernelMatrix: MatrixImpl<R> = _kernelMatrix()
    final lazy var imageMatrix: MatrixImpl<R>  = _imageMatrix()
    final lazy var kernelTransitionMatrix: MatrixImpl<R> = _kernelTransitionMatrix()
    final lazy var imageTransitionMatrix: MatrixImpl<R>  = _imageTransitionMatrix()
    
    final var nullity: Int {
        return result.cols - rank
    }
    
    final var isInjective: Bool {
        return result.cols <= result.rows && rank == result.cols
    }
    
    final var isSurjective: Bool {
        return result.cols >= result.rows && rank == result.rows && diagonal.allSatisfy{ $0.isInvertible }
    }
    
    final var isBijective: Bool {
        return isInjective && isSurjective
    }
    
    @_specialize(where R == ComputationSpecializedRing)
    final func _left() -> MatrixImpl<R> {
        let P = MatrixImpl<R>.identity(size: result.rows, align: .Rows)
        for s in rowOps {
            P.apply(s)
        }
        return P
    }
    
    @_specialize(where R == ComputationSpecializedRing)
    final func _leftInverse(restrictedToCols colRange: CountableRange<Int>? = nil) -> MatrixImpl<R> {
        let P = (colRange == nil)
            ? MatrixImpl<R>.identity(size: result.rows, align: .Rows)
            : MatrixImpl<R>.identity(size: result.rows, align: .Rows).submatrix(colRange: colRange!)
        
        for s in rowOps.reversed() {
            P.apply(s.inverse)
        }
        
        return P
    }
    
    @_specialize(where R == ComputationSpecializedRing)
    final func _right() -> MatrixImpl<R> {
        let P = MatrixImpl<R>.identity(size: result.cols, align: .Cols)
        for s in colOps {
            P.apply(s)
        }
        return P
    }
    
    @_specialize(where R == ComputationSpecializedRing)
    final func _rightInverse(restrictedToRows rowRange: CountableRange<Int>? = nil) -> MatrixImpl<R> {
        let P = (rowRange == nil)
            ? MatrixImpl<R>.identity(size: result.cols, align: .Cols)
            : MatrixImpl<R>.identity(size: result.cols, align: .Cols).submatrix(rowRange: rowRange!)
        
        for s in colOps.reversed() {
            P.apply(s.inverse)
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
    
    func _imageTransitionMatrix() -> MatrixImpl<R> {
        fatalError("not available.")
    }
}
