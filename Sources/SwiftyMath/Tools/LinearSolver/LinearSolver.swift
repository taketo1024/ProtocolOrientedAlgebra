//
//  LinearSolver.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/29.
//

public final class LinearSolver<R: EuclideanRing> {
    
    // solve: x * A = b
    public static func solveLeftRegular<r>(_ A: Matrix<r, r, R>, _ b: RowVector<r, R>) -> RowVector<r, R> {
        assert(A.isSquare && A.size.rows == b.size.cols)
        assert(A.diagonalComponents.allSatisfy{ $0.isInvertible })
        
        let e = MatrixEliminator.eliminate(target: A, form: .ColEchelon)
        
        assert(e.result.isIdentity)
        
        return b.applyColOperations(e.colOps)
    }
    
    public static func solveLeftUpperTriangular<r>(_ U: Matrix<r, r, R>, _ b: RowVector<r, R>) -> RowVector<r, R> {
        assert(U.isSquare && U.size.rows == b.size.cols)
        assert(U.diagonalComponents.allSatisfy{ $0.isInvertible })
        
        let r = U.size.rows
        let x = solveLeftUpperTriangular(
            RowAlignedMatrixData(U), descructing: RowAlignedMatrixData(b).row(0)
        )
        
        return RowVector(size: (0, r)) { setEntry in x.forEach{ (j, a) in setEntry(0, j, a) } }
    }

    static func solveLeftUpperTriangular(_ U: RowAlignedMatrixData<R>, descructing b: RowAlignedMatrixData<R>.Row) -> RowAlignedMatrixData<R>.Row {
        let r = U.size.rows
        var x: [Int : R] = [:]
        
        for i in 0 ..< r {
            guard case (i, let bi)? = b.headElement else {
                continue
            }
            
            let ui = U.row(i).headElement!.value
            let xi = ui.inverse! * bi
            
            x[i] = xi
            RowAlignedMatrixData.addRow(U.row(i), into: b, multipliedBy: -xi)
        }
        
        return .init( x.map{ (i, a) in (i, a) } )
    }

}

extension LinearSolver where R: Field {
    public static func hasSolution<n, m>(_ A: Matrix<n, m, R>, _ b: ColVector<n, R>) -> Bool {
        
        // Compute the Schur complement S' of U in P(Ab)Q.
        // The original S-complement is the submatrix in cols: (0 ..< m - r).
        
        let m = A.size.cols
        
        let pivots = MatrixPivotFinder.findPivots(of: A.asDynamicMatrix)
        let r = pivots.numberOfPivots
        
        let Ab = A.concatHorizontally(b).asDynamicMatrix
        let (_, _, Sb) = LUFactorizer.prefactorize(Ab, with: pivots)
        
        let E = MatrixEliminator.eliminate(target: Sb, form: .RowEchelon)
        let (B, b2) = E.result.splitHorizontally(at: m - r)
        
        let r1 =  B.rowHeight // rank(A)  == r + r1
        let r2 = b2.rowHeight // rank(Ab) == r + max(r1, r2)
        
        return r1 >= r2
        // <=> r1 = max(r1, r2)
        // <=> rank(A) = rank(Ab)
    }
}

private extension Matrix {
    var rowHeight: Int {
        Set(nonZeroComponents.lazy.map { $0.row + 1 } ).max() ?? 0
    }
}
