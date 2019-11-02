//
//  LUFactorizer.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/29.
//

public final class LUFactorizer<R: EuclideanRing> {
    public static func factorize<n, m>(_ A: Matrix<n, m, R>) -> Result<n, m, R> {
        let pivots = MatrixPivotFinder.findPivots(of: A)
        let (P, Q) = (pivots.rowPermutation, pivots.colPermutation)
        let (L, U, _) = prefactorize(A, with: pivots)
        
        // TODO eliminate S.
        
        return Result(
            rowPermutation: P,
            colPermutation: Q,
            L: L,
            U: U
        )
    }
    
    // Computes (L, U, S) of
    //
    //   PAQ = L * U + |0, 0|
    //                 |0, S|
    //
    // where L is lower triangle, U is upper triangle.

    public static func prefactorize<n, m>(_ A: Matrix<n, m, R>, with pivots: MatrixPivotFinder<R>.Result<n, m, R>) ->
        (L: Matrix<n, DynamicSize, R>, U: Matrix<DynamicSize, m, R>, S: DMatrix<R>)
    {
        // Let
        //
        //   PAQ = [U, B]
        //         [C, D]
        //
        //     L = C * U^{-1}
        //
        // and S be the Schur complement of U:
        //
        //   S = D - C * U^{-1} * B.
        //
        // Then
        //
        //   PAQ = [I, 0] * [U, B]
        //         [L, S]   [0, I]
        //
        //       = [I, 0] * [U, B]
        //         [L, I]   [0, S]
        //
        //       = [I] * [U, B] + [0, 0]
        //         [L]            [0, S] .
        //
        // Both L, S can be obtained by solving an upper-triangle linear system.
        
        let (n, m) = A.size
        let r = pivots.numberOfPivots
        let (P, Q) = (pivots.rowPermutation, pivots.colPermutation)
        
        let pA = RowAlignedMatrixData(size: A.size, components: A.nonZeroComponents.lazy.map{ (i, j, a) in
            (P[i], Q[j], a)
        })

        let (U1, CD) = (pA.sub(0 ..< r), pA.sub(r ..< n))
        let UB = U1.as(Matrix<DynamicSize, m, R>.self)
        
        let OI = RowAlignedMatrixData(size: (m - r, m), components:
            (0 ..< m - r).map { i in (i, r + i, R.identity) }
        )
        
        U1.concat(OI)
        
        let LS = DMatrix<R>(size: (n - r, m), concurrentIterations: n - r) { (i, setEntry) in
            LinearSolver.solveLeftUpperTriangular(U1, descructing: CD.rows[i]).forEach { (j, a) in
                setEntry(i, j, a)
            }
        }
        
        // CD should be 0.
        
        let (L, S) = LS.splitHorizontally(at: r)
        let Ir = DMatrix<R>.identity(size: r)
        let IL = Ir.concatVertically(L).as(Matrix<n, DynamicSize, R>.self)
        
        assert({
            let pA = Matrix<n, m, R>(size: A.size) { setEntry in
                A.nonZeroComponents.forEach{ (i, j, a) in
                    setEntry(P[i], Q[j], a)
                }
            }
            let O = DMatrix<R>.zero(size: (r, r))
            let S2 = (O ⊕ S).as(Matrix<n, m, R>.self)
            return (pA.as(Matrix<n, m, R>.self) == IL * UB + S2)
        }())
        
        return (IL, UB, S)
    }

    
    public struct Result<n: SizeType, m: SizeType, R: EuclideanRing> {
        public let rowPermutation: Permutation<n>
        public let colPermutation: Permutation<m>
        
        public let L: Matrix<n, DynamicSize, R>
        public let U: Matrix<DynamicSize, m, R>
        
        public init(rowPermutation: Permutation<n>, colPermutation: Permutation<m>, L: Matrix<n, DynamicSize, R>, U: Matrix<DynamicSize, m, R>) {
            self.rowPermutation = rowPermutation
            self.colPermutation = colPermutation
            self.L = L
            self.U = U
        }
        
        public var rank: Int {
            L.size.cols // == U.size.rows
        }
    }
}
