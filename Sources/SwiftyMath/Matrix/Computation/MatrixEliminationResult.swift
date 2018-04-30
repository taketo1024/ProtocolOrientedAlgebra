//
//  MatrixEliminationResult.swift
//  Sample
//
//  Created by Taketo Sano on 2018/04/26.
//

public struct MatrixEliminationResult<n: _Int, m: _Int, R: EuclideanRing> {
    internal let impl: MatrixEliminationResultImpl<R>
    
    internal init<n, m>(_ matrix: _Matrix<n, m, R>, _ impl: MatrixEliminationResultImpl<R>) {
        self.impl = impl
    }
    
    public var result: _Matrix<n, m, R> {
        return _Matrix(impl.result)
    }
    
    public var left: _Matrix<n, n, R> {
        return _Matrix(impl.left)
    }
    
    public var leftInverse: _Matrix<n, n, R> {
        return _Matrix(impl.leftInverse)
    }
    
    public var right: _Matrix<m, m, R> {
        return _Matrix(impl.right)
    }
    
    public var rightInverse: _Matrix<m, m, R> {
        return _Matrix(impl.rightInverse)
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
    
    public var kernelMatrix: _Matrix<m, Dynamic, R> {
        return _Matrix(impl.kernelMatrix)
    }
    
    public var imageMatrix: _Matrix<n, Dynamic, R> {
        return _Matrix(impl.imageMatrix)
    }
    
    // The left inverse of kernelMatrix
    public var kernelTransitionMatrix: _Matrix<Dynamic, m, R> {
        return _Matrix(impl.kernelTransitionMatrix)
    }
}

public extension MatrixEliminationResult where n == m {
    public var inverse: _Matrix<n, n, R>? {
        return impl.inverse.map{ _Matrix($0) }
    }
    
    public var determinant: R {
        return impl.determinant
    }
}
