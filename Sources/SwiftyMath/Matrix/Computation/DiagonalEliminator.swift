//
//  DiagonalEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/11/08.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

internal final class DiagonalEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    override var resultType: MatrixEliminationResultImpl<R>.Type {
        return DiagonalEliminationResult.self
    }
    
    override func isDone() -> Bool {
        let n = target.table.keys.count
        return target.table.forAll{ (i, list) in
            i < n && (list.count == 1)
                  && list.first!.0 == i
                  && list.first!.1.normalizeUnit == .identity
        }
    }
    
    override func iteration() {
        run(RowHermiteEliminator.self)
        
        if isDone() {
            return
        }
        
        run(ColHermiteEliminator.self)
    }
}

internal final class DiagonalEliminationResult<R: EuclideanRing>: MatrixEliminationResultImpl<R> {
    override func _diagonal() -> [R] {
        return result.table.map{ (_, list) in list.first!.1 }
    }
    
    override func _rank() -> Int {
        return diagonal.count
    }
    
    override func _determinant() -> R {
        assert(result.rows == result.cols)
        assert(diagonal.forAll{ $0 == .identity })
        
        if rank == result.rows {
            return rowOps.multiply { $0.determinant }.inverse!
                * colOps.multiply { $0.determinant }.inverse!
                * diagonal.multiplyAll()
        } else {
            return .zero
        }
    }
    
    override func _inverse() -> MatrixImpl<R>? {
        assert(result.rows == result.cols)
        assert(determinant.isInvertible)
        return (rank == result.rows) ? right * left : nil
    }
    
    // The matrix made by the basis of Ker(A).
    // Z = (z1, ..., zk) , k = col(A) - rank(A).
    //
    // P * A * Q = [D_r; O_k]
    // =>  Z := Q[:, r ..< m], then A * Z = O_k
    
    override func _kernelMatrix() -> MatrixImpl<R> {
        return right.submatrix(colRange: rank ..< result.cols)
    }
    
    // The matrix made by the basis of Im(A).
    // B = (b1, ..., br) , r = rank(A)
    //
    // P * A * Q = [D_r; O_k]
    // => D is the imageMatrix with basis P.
    // => P^-1 * D is the imageMatrix with the standard basis.
    
    override func _imageMatrix() -> MatrixImpl<R> {
        let A = _leftInverse(restrictedToCols: 0 ..< rank)
        return A * result.submatrix(0 ..< rank, 0 ..< rank)
    }
    
    // T: The basis transition matrix from (ei) to (zi),
    // i.e. T * zi = ei.
    //
    // P * A * Q = [D_r; O_k]
    // =>  Z = Q[:, r ..< m] = Q * [O_r; I_k]
    // =>  Q^-1 * Z = [O; I_k]
    //
    // T = Q^-1[r ..< m, :]  gives  T * Z = I_k.
    
    override func _kernelTransitionMatrix() -> MatrixImpl<R> {
        return _rightInverse(restrictedToRows: rank ..< result.cols)
    }
}
