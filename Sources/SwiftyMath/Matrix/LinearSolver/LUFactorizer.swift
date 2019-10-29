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
        let (L, U, _) = MatrixPivotFinder.computeLUS(of: A, with: pivots)
        
        // TODO eliminate S.
        
        return Result(
            rowPermutation: P,
            colPermutation: Q,
            L: L,
            U: U
        )
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
