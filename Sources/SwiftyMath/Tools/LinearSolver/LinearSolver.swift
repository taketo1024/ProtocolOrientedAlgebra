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

extension LinearSolver where R: Field {
    public static func hasSolution<n, m>(_ A: Matrix<n, m, R>, _ b: ColVector<n, R>) -> Bool {
        let pivots = MatrixPivotFinder.findPivots(of: A.asDynamicMatrix)
        let Ab = A.concatHorizontally(b).asDynamicMatrix
        let (_, _, Sb) = MatrixPivotFinder.computeLUS(of: Ab, with: pivots)
        
        let E = MatrixEliminator.eliminate(target: Sb, form: .RowEchelon)
        let (B, b2) = E.result.splitHorizontally(at: A.size.cols)
        
        let r1 =  B.numberOfRows
        let r2 = b2.numberOfRows
        
        return r1 >= r2
    }
}

private extension Matrix {
    var numberOfRows: Int {
        Set(nonZeroComponents.lazy.map { $0.row } ).count
    }
}
