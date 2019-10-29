//
//  LinearSolver.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/29.
//

public final class LinearSolver<R: Ring> {
    // forward-solve x * U = b
    public static func forwardSolve<r>(_ U: Matrix<r, r, R>, _ b: RowVector<r, R>) -> RowVector<r, R> {
        assert(U.isSquare && U.size.rows == b.size.cols)
        assert(U.diagonalComponents.allSatisfy{ $0.isInvertible })
        
        let U_ = U.splitIntoColVectors()
        let r = U.size.rows
        var x = RowVector<r, R>.zero(size: r)
        
        for i in 0 ..< r {
            // x_1 U_1i + ... + x_i U_ii = b_i
            // <==> x_i = U_ii^{-1} ( b_i - x * U_i )
            
            let U_i = U_[i]
            let s = b[i] - (x * U_i).asScalar
            
            if !s.isZero {
                let u = U_i[i].inverse!
                x[i] = u * s
            }
        }
        
        return x
    }
}
