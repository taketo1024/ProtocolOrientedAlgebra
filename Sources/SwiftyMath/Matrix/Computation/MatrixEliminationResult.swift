//
//  MatrixEliminationResult.swift
//  Sample
//
//  Created by Taketo Sano on 2018/04/26.
//

import Foundation

public struct MatrixEliminationResult<n: SizeType, m: SizeType, R: EuclideanRing> {
    internal let impl: MatrixEliminationResultImpl<R>
    
    internal init<n, m>(_ matrix: Matrix<n, m, R>, _ impl: MatrixEliminationResultImpl<R>) {
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
