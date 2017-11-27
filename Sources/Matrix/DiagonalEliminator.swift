//
//  DiagonalEliminator.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/11/08.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public final class DiagonalEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    internal override var resultType: MatrixEliminationResult<R>.Type {
        return DiagonalEliminationResult.self
    }
    
    override func iteration() -> Bool {
        if target.isDiagonal {
            return true
        }
        
        run(RowHermiteEliminator.self)
        
        if target.isDiagonal {
            return true
        }
        
        run(ColHermiteEliminator.self)

        return false
    }
}

public final class DiagonalEliminationResult<R: EuclideanRing>: MatrixEliminationResult<R> {
    public override lazy var diagonal: [R] = { [unowned self] in
        return result.diagonal
    }()
    
    public override var rank: Int {
        return diagonal.count
    }
    
    public override lazy var determinant: R = { [unowned self] in
        assert(result.rows == result.cols)
        assert(diagonal.forAll{ $0 == .identity })
        
        if rank == result.rows {
            return rowOps.multiply { $0.determinant }.inverse!
                * colOps.multiply { $0.determinant }.inverse!
                * diagonal.multiplyAll()
        } else {
            return 0
        }
    }()
    
    public override lazy var inverse: ComputationalMatrix<R>? = {
        assert(result.rows == result.cols)
        assert(determinant.isInvertible)
        return (rank == result.rows) ? right * left : nil
    }()
    
    // The matrix made by the basis of Ker(A).
    // Z = (z1, ..., zk) , k = col(A) - rank(A).
    //
    // P * A * Q = [D_r; O_k]
    // =>  Z := Q[:, r ..< m], then A * Z = O_k
    
    public override lazy var kernelMatrix: ComputationalMatrix<R> = { [unowned self] in
        return right.submatrix(colRange: rank ..< result.cols)
    }()
    
    // The matrix made by the basis of Im(A).
    // B = (b1, ..., br) , r = rank(A)
    //
    // P * A * Q = [D_r; O_k]
    // => D is the imageMatrix with basis P.
    // => P^-1 * D is the imageMatrix with the standard basis.
    
    public override lazy var imageMatrix: ComputationalMatrix<R> = { [unowned self] in
        let A = _leftInverse(restrictedToCols: 0 ..< rank)
        return A * result.submatrix(0 ..< rank, 0 ..< rank)
    }()
    
    // T: The basis transition matrix from (ei) to (zi),
    // i.e. T * zi = ei.
    //
    // P * A * Q = [D_r; O_k]
    // =>  Z = Q[:, r ..< m] = Q * [O_r; I_k]
    // =>  Q^-1 * Z = [O; I_k]
    //
    // T = Q^-1[r ..< m, :]  gives  T * Z = I_k.
    
    public override lazy var kernelTransitionMatrix: ComputationalMatrix<R> = { [unowned self] in
        return _rightInverse(restrictedToRows: rank ..< result.cols)
    }()
}
