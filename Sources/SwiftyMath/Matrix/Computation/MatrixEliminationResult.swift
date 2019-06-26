//
//  MatrixEliminationResult.swift
//  Sample
//
//  Created by Taketo Sano on 2018/04/26.
//

import Foundation

public struct MatrixEliminationResult<n: SizeType, m: SizeType, R: EuclideanRing> {
    public let form: MatrixEliminationForm
    public let result: Matrix<n, m, R>
    let rowOps: [MatrixEliminator<R>.ElementaryOperation]
    let colOps: [MatrixEliminator<R>.ElementaryOperation]

    private let dataCache: CacheDictionary<String, MatrixData<R>> = .empty
    
    internal init(form: MatrixEliminationForm, result: Matrix<n, m, R>, rowOps: [MatrixEliminator<R>.ElementaryOperation], colOps: [MatrixEliminator<R>.ElementaryOperation]) {
        self.form = form
        self.result = result
        self.rowOps = rowOps
        self.colOps = colOps
    }
    
    public var left: Matrix<n, n, R> {
        let n = result.size.rows
        let data = dataCache.useCacheOrSet(key: "left") {
            let P = RowEliminationWorker<R>.identity(size: n)
            for s in rowOps {
                P.apply(s)
            }
            return P.resultData
        }
        return .init(size: (n, n), data: data)
    }
    
    public var leftInverse: Matrix<n, n, R> {
        let n = result.size.rows
        let data = dataCache.useCacheOrSet(key: "leftinv") {
            let P = RowEliminationWorker<R>.identity(size: n)
            for s in rowOps.reversed() {
                P.apply(s.inverse)
            }
            return P.resultData
        }
        return .init(size: (n, n), data: data)
    }
    
    public var right: Matrix<m, m, R> {
        let m = result.size.cols
        let data = dataCache.useCacheOrSet(key: "right") {
            let P = RowEliminationWorker<R>.identity(size: m)
            for s in colOps {
                P.apply(s.transposed)
            }
            return P.resultData.mapKeys{ $0.transposed }
        }
        return .init(size: (m, m), data: data)
    }
    
    public var rightInverse: Matrix<m, m, R> {
        let m = result.size.cols
        let data = dataCache.useCacheOrSet(key: "rightinv") {
            let P = RowEliminationWorker<R>.identity(size: m)
            for s in colOps.reversed() {
                P.apply(s.inverse.transposed)
            }
            return P.resultData.mapKeys{ $0.transposed }
        }
        return .init(size: (m, m), data: data)
    }
    
    public var rank: Int {
        // TODO support Echelon types
        assert(result.isDiagonal)
        return result.diagonal.count{ $0 != .zero }
    }
    
    // The matrix made by the basis of Ker(A).
    // Z = (z1, ..., zk) , k = col(A) - rank(A).
    //
    // P * A * Q = [D_r; O_k]
    // =>  Z := Q[:, r ..< m], then A * Z = O_k
    
    public var kernelMatrix: Matrix<m, DynamicSize, R>  {
        assert(result.isDiagonal)
        return right.submatrix(colRange: rank ..< result.size.cols)
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
        return rightInverse.submatrix(rowRange: rank ..< result.size.cols)
    }
}

extension MatrixEliminationResult where n == m {
    public var determinant: R {
        assert(result.isDiagonal)
        
        if rank == result.size.rows {
            return rowOps.multiply { $0.determinant }.inverse!
                * colOps.multiply { $0.determinant }.inverse!
                * result.diagonal.multiplyAll()
        } else {
            return .zero
        }
    }
    
    public var inverse: Matrix<n, n, R>? {
        assert(result.isSquare)
        return (result.isIdentity) ? right * left : nil
    }
}
