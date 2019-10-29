//
//  LUFactorizer.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/29.
//

public final class LUFactorizer<R: EuclideanRing> {
    public static func factorize<n, m>(_ A: Matrix<n, m, R>) -> LUFactorization<n, m, R>? {
        
        // PAQ = L * U + |0, 0|
        //               |0, S|
        
        let (P, L, U, Q, S) = prefactor(A)
        
        print("S:", S.detailDescription, "\n")
        
        return LUFactorization(P.inverse!, L, U, Q.inverse!)
    }
    
    private static func prefactor<n, m>(_ A: Matrix<n, m, R>) -> (P: Permutation<n>, L: Matrix<n, DynamicSize, R>, U: Matrix<DynamicSize, m, R>, Q: Permutation<m>, S: DMatrix<R>) {
        let (n, m) = A.size
        let pf = MatrixPivotFinder(A)
        
        let (pivots, P, Q) = pf.start()
        let r = pivots.count
        
        // We have
        //
        //   PAQ = [U, B]
        //         [C, D]
        //
        //       = [I] * [U, B] + [O, O]
        //         [L]            [O, S]
        //
        // where
        //
        //   L = C * U^{-1},
        //   S = D - C * U^{-1} * B.
        //
        
        let pA = Matrix<n, m, R>(size: A.size) { setEntry in
            A.nonZeroComponents.forEach{ (i, j, a) in
                setEntry(P[i], Q[j], a)
            }
        }
        
        let UB = pA.submatrix(rowRange: 0 ..< r) // size (r, m)
        let CD = pA.submatrix(rowRange: r ..< n) // size (n - r, m)
        let U = UB.submatrix(colRange: 0 ..< r)  // size (r, r)
        let B = UB.submatrix(colRange: r ..< m)  // size (r, m - r)
        let C = CD.submatrix(colRange: 0 ..< r)  // size (n - r, r)
        let D = CD.submatrix(colRange: r ..< m)  // size (n - r, m - r)
        
        let L = DMatrix<R>(size: (n - r, r), concurrentIterations: n - r) { (i, setEntry) in
            let li = self.forwardSolve(U, C.rowVector(i))
            li.nonZeroComponents.forEach{ (_, j, a) in
                setEntry(i, j, a)
            }
        } // size (n - r, r)
        
        let IL = DMatrix<R>.identity(size: r).concatVertically(L).as(Matrix<n, DynamicSize, R>.self)
        let S = D - L * B
        
        assert({
            let O = DMatrix<R>.zero(size: (r, r))
            let S2 = (O ⊕ S).as(Matrix<n, m, R>.self)
            return (pA == IL * UB + S2)
        }())
        
        return (P, IL, UB, Q, S)
    }
    
    // forward-solve x * U = b
    private static func forwardSolve<r>(_ U: Matrix<r, r, R>, _ b: RowVector<r, R>) -> RowVector<r, R> {
        assert(U.isSquare && U.size.rows == b.size.cols)
        let r = U.size.rows
        var x = RowVector<r, R>.zero(size: r)
        for i in 0 ..< r {
            // x_1 U_1i + ... + x_i U_ii = b_i
            let U_i = U.colVector(i)
            let x_i = U_i[i].inverse! * ( b[i] - (x * U_i).asScalar )
            x[i] = x_i
        }
        return x
    }
}

public struct LUFactorization<n: SizeType, m: SizeType, R: EuclideanRing> {
    public let rowPermutation: Permutation<n>
    public let colPermutation: Permutation<m>
    
    public let L: Matrix<n, DynamicSize, R>
    public let U: Matrix<DynamicSize, m, R>
    
    public init(_ P: Permutation<n>, _ L: Matrix<n, DynamicSize, R>, _ U: Matrix<DynamicSize, m, R>, _ Q: Permutation<m>) {
        self.rowPermutation = P
        self.colPermutation = Q
        self.L = L
        self.U = U
    }
    
    public var rank: Int {
        L.size.cols // == U.size.rows
    }
    
    public var PLUQ: (Matrix<n, n, R>, Matrix<n, DynamicSize, R>, Matrix<DynamicSize, m, R>, Matrix<m, m, R>) {
        (P, L, U, Q)
    }

    public var P: Matrix<n, n, R> {
        rowPermutation.asMatrix(size: L.size.rows, over: R.self)
    }
    
    public var PInverse: Matrix<n, n, R> {
        rowPermutation.inverse!.asMatrix(size: L.size.rows, over: R.self)
    }
    
    public var Q: Matrix<m, m, R> {
        colPermutation.inverse!.asMatrix(size: U.size.cols, over: R.self)
    }
    
    public var QInverse: Matrix<m, m, R> {
        colPermutation.asMatrix(size: U.size.cols, over: R.self)
    }
}
