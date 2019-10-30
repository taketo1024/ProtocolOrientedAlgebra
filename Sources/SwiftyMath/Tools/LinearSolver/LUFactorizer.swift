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

    public static func prefactorize<n, m>(_ A: Matrix<n, m, R>, with result: MatrixPivotFinder<R>.Result<n, m, R>) ->
        (L: Matrix<n, DynamicSize, R>, U: Matrix<DynamicSize, m, R>, S: DMatrix<R>)
    {
        // Let
        //
        //   PAQ = [U, B]
        //         [C, D] ,
        //
        // and
        //
        //   S = D - C * U^{-1} * B,
        //
        // the Schur complement of U.
        // Then
        //
        //   PAQ = [I] * [U, B] + [0, 0]
        //         [L]            [0, S] .
        //
        // From
        //
        //   [L, S] * [U, B] = [C, D] ,
        //            [O, I]
        //
        // L, S can be obtained by solving an upper-triangle linear system.
        
        let (n, m) = A.size
        let r = result.pivots.count
        let (P, Q) = (result.rowPermutation, result.colPermutation)
        
        let pA = Matrix<n, m, R>(size: A.size) { setEntry in
            A.nonZeroComponents.forEach{ (i, j, a) in
                setEntry(P[i], Q[j], a)
            }
        }
        
        let (UB, CD) = pA.splitVertically(at: r)
        
        let O = DMatrix<R>.zero(size: (m - r, r))
        let I = DMatrix<R>.identity(size: (m - r))
        let OI = O.concatHorizontally(I).as(Matrix<DynamicSize, m, R>.self)
        let UBOI = UB.concatVertically(OI).as(Matrix<m, m, R>.self)
        
        let cd = CD.splitIntoRowVectors()
        let LS = DMatrix<R>(size: (n - r, m), concurrentIterations: n - r) { (i, setEntry) in
            let li = LinearSolver.forwardSolve(UBOI, cd[i])
            li.nonZeroComponents.forEach{ (_, j, a) in
                setEntry(i, j, a)
            }
        }
        let (L, S) = LS.splitHorizontally(at: r)
        let Ir = DMatrix<R>.identity(size: r)
        let IL = Ir.concatVertically(L).as(Matrix<n, DynamicSize, R>.self)
        
        assert({
            let O = DMatrix<R>.zero(size: (r, r))
            let S2 = (O ⊕ S).as(Matrix<n, m, R>.self)
            return (pA == IL * UB + S2)
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
