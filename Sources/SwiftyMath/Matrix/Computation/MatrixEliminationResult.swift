//
//  MatrixEliminationResult.swift
//  Sample
//
//  Created by Taketo Sano on 2018/04/26.
//

import Foundation

public struct MatrixEliminationResult<n: SizeType, m: SizeType, R: EuclideanRing> {
    public let result: Matrix<n, m, R>
    let rowOps: [MatrixEliminator<R>.ElementaryOperation]
    let colOps: [MatrixEliminator<R>.ElementaryOperation]

    internal init(_ result: MatrixImpl<R>, _ rowOps: [MatrixEliminator<R>.ElementaryOperation], _ colOps: [MatrixEliminator<R>.ElementaryOperation]) {
        self.result = Matrix(result)
        self.rowOps = rowOps
        self.colOps = colOps
    }
    
    private let _matrixCache: CacheDictionary<String, MatrixImpl<R>> = .empty

    public var rank: Int {
        return result.impl.table.count
    }
    
    public var left: Matrix<n, n, R> {
        return Matrix(_matrixCache.useCacheOrSet(key: "left") {
            let P = MatrixImpl<R>.identity(size: result.rows, align: .Rows)
            for s in rowOps {
                P.apply(s)
            }
            return P
        })
    }
    
    public var leftInverse: Matrix<n, n, R> {
        return Matrix(_matrixCache.useCacheOrSet(key: "leftinv") {
            let P = MatrixImpl<R>.identity(size: result.rows, align: .Rows)
            for s in rowOps.reversed() {
                P.apply(s.inverse)
            }
            return P
        })
    }
    
    public var right: Matrix<m, m, R> {
        return Matrix(_matrixCache.useCacheOrSet(key: "right") {
            let P = MatrixImpl<R>.identity(size: result.cols, align: .Cols)
            for s in colOps {
                P.apply(s)
            }
            return P
        })
    }
    
    public var rightInverse: Matrix<m, m, R> {
        return Matrix(_matrixCache.useCacheOrSet(key: "rightinv") {
            let P = MatrixImpl<R>.identity(size: result.cols, align: .Cols)
            for s in colOps.reversed() {
                P.apply(s.inverse)
            }
            return P
        })
    }
    
    // The matrix made by the basis of Ker(A).
    // Z = (z1, ..., zk) , k = col(A) - rank(A).
    //
    // P * A * Q = [D_r; O_k]
    // =>  Z := Q[:, r ..< m], then A * Z = O_k
    
    public var kernelMatrix: Matrix<m, DynamicSize, R>  {
        assert(result.isDiagonal)
        return right.submatrix(colRange: rank ..< result.cols)
    }

    // The matrix made by the basis of Im(A).
    // B = (b1, ..., br) , r = rank(A)
    //
    // P * A * Q = [D_r; O_k]
    // => [D; O] is the imageMatrix with basis P.
    // => P^-1 * [D; O] is the imageMatrix with the standard basis.
    
    public var imageMatrix: Matrix<n, DynamicSize, R> {
        assert(result.isDiagonal)
        return leftInverse.submatrix(colRange: 0 ..< rank) * result.submatrix(rowRange: 0 ..< rank, colRange: 0 ..< rank)
    }
    
    // T: The basis transition matrix from (ei) to (zi),
    // i.e. T * zi = ei.
    //
    // Z = Q * [O_r; I_k]
    // =>  Q^-1 * Z = [O; I_k]
    //
    // T = Q^-1[r ..< m, :]  gives  T * Z = I_k.
    
    public var kernelTransitionMatrix: Matrix<DynamicSize, m, R> {
        assert(result.isDiagonal)
        return rightInverse.submatrix(rowRange: rank ..< result.cols)
    }
}

extension MatrixEliminationResult where n == m {
    public var determinant: R {
        assert(result.rows == result.cols)
        assert(result.isDiagonal)
        
        if rank == result.rows {
            return rowOps.multiply { $0.determinant }.inverse!
                * colOps.multiply { $0.determinant }.inverse!
                * result.diagonal.multiplyAll()
        } else {
            return .zero
        }
    }
    
    public var inverse: Matrix<n, n, R>? {
        assert(result.rows == result.cols)
        return (result.isIdentity) ? right * left : nil
    }
}
