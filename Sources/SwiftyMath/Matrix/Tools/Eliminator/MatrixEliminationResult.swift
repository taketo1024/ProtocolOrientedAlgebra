//
//  MatrixEliminationResult.swift
//  Sample
//
//  Created by Taketo Sano on 2018/04/26.
//

// TODO remove these
public extension Matrix where Impl: SparseMatrixImpl {
    var isIdentity: Bool {
        isSquare && nonZeroComponents.allSatisfy{ (i, j, a) in (i == j && a.isIdentity) }
    }
    
    var isDiagonal: Bool {
        nonZeroComponents.allSatisfy{ (i, j, a) in i == j }
    }
    
    var diagonalComponents: [BaseRing] {
        let r = Swift.min(size.rows, size.cols)
        return (0 ..< r).map{ i in self[i, i] }
    }
}

public struct MatrixEliminationResult<n: SizeType, m: SizeType, R: EuclideanRing> {
    public let form: MatrixEliminator<R>.Form
    public let result: Matrix<n, m, R>
    
    internal let rowOps: [RowElementaryOperation<R>]
    internal let colOps: [ColElementaryOperation<R>]
    
    internal init(form: MatrixEliminator<R>.Form, result: Matrix<n, m, R>, rowOps: [RowElementaryOperation<R>], colOps: [ColElementaryOperation<R>]) {
        self.form = form
        self.result = result
        self.rowOps = rowOps
        self.colOps = colOps
    }
    
    public var size: MatrixSize {
        result.size
    }
    
    public var rank: Int {
        // TODO support Echelon types
        assert(result.isDiagonal)
        return result.diagonalComponents.count{ !$0.isZero }
    }
    
    public var nullity: Int {
        return size.cols - rank
    }
    
    // returns P of: P * A * Q = B

    public var left: Matrix<n, n, R> {
        composeRowOps(rowOps, restrictedToRows: 0 ..< size.rows)
    }
    
    public func left(restrictedToRows rowRange: Range<Int>) -> Matrix<DynamicSize, n, R> {
        composeRowOps(rowOps, restrictedToRows: rowRange)
    }
    
    // returns P^{-1} of: P * A * Q = B
    
    public var leftInverse: Matrix<n, n, R> {
        composeRowOps(rowOpsInverse, restrictedToCols: 0 ..< size.rows)
    }
    
    public func leftInverse(restrictedToCols colRange: Range<Int>) -> Matrix<n, DynamicSize, R> {
        composeRowOps(rowOpsInverse, restrictedToCols: colRange)
    }
    
    // returns Q of: P * A * Q = B
    
    public var right: Matrix<m, m, R> {
        composeColOps(colOps, restrictedToRows: 0 ..< size.cols)
    }
    
    public func right(restrictedToCols colRange: Range<Int>) -> Matrix<m, DynamicSize, R> {
        composeColOps(colOps, restrictedToCols: colRange)
    }
    
    // returns Q^{-1} of: P * A * Q = B
    
    public var rightInverse: Matrix<m, m, R> {
        composeColOps(colOpsInverse, restrictedToRows: 0 ..< size.cols)
    }
    
    public func rightInverse(restrictedToRows rowRange: Range<Int>) -> Matrix<DynamicSize, m, R> {
        composeColOps(colOpsInverse, restrictedToRows: rowRange)
    }
    
    // Returns the matrix consisting of the basis vectors of Ker(A).
    // If
    //
    //     P * A * Q = [ D_r | O   ]
    //                 [   O | O_k ]
    //
    // then for any j in (r <= j < m),
    //
    //     0 = (A * Q) * e_j = A * (Q * e_j)
    //
    // so
    //
    //     Ker(A) = Q * [O; I_k]
    //            = Q[-, r ..< m]
    //
    
    public var kernelMatrix: Matrix<m, DynamicSize, R>  {
        assert(result.isDiagonal)
        return right(restrictedToCols: rank ..< size.cols)
    }
    
    // Returns the transition matrix T from Z = Ker(A) to I,
    // i.e.
    //
    //     T * Z = I_k
    //     <=> z_j = q_{r + j} ∈ R^m  --T--> e_j ∈ R^k  (0 <= j < k)
    //
    // Since Z = Q * [O; I_k],
    //
    //     T = [O, I_k] Q^{-1}
    //       = Q^{-1}[r ..< n; -]
    //
    // satisfies the desired equation.
    
    public var kernelTransitionMatrix: Matrix<DynamicSize, m, R> {
        assert(result.isDiagonal)
        return rightInverse(restrictedToRows: rank ..< size.cols)
    }
    
    // Returns the matrix consisting of the basis vectors of Im(A).
    // If
    //
    //     P * A * Q = [ D_r | O   ]
    //                 [   O | O_k ]
    //
    // then
    //
    //     A * Q =  [ P^{-1} [D_r] | O ]
    //              [        [O  ] | O ]
    //
    // so
    //
    //    Im(A) = P^{-1} [D_r; O]
    //          = P^{-1}[-, 0 ..< r] * D_r.
    
    public var imageMatrix: Matrix<n, DynamicSize, R> {
        assert(result.isDiagonal)
        let r = rank
        return leftInverse(restrictedToCols: 0 ..< r) * result.submatrix(rowRange: 0 ..< r, colRange: 0 ..< r)
    }
    
    // Returns the transition matrix T from Im(A) to D_r,
    // i.e.
    //
    //     D_r = T * Im(A)
    //         = T * P^{-1} * [D_r; O]
    //         = T * P^{-1} * [I_r; O] * D_r
    //
    // so
    //
    //     T = [I_r, O] * P
    //       = P[0 ..< r, -].

    public var imageTransitionMatrix: Matrix<DynamicSize, n, R> {
        assert(result.isDiagonal)
        return left(restrictedToRows: 0 ..< rank)
    }
    
    // Find a solution x to: Ax = b.
    // With PAQ = B,
    //
    //    Ax = b  <==>  (PAQ) Q^{-1}x = Pb
    //            <==>    B      y    = Pb
    //
    // where y = Q^{-1}x <==> x = Qy.
    
    public func invert(_ b: ColVector<n, R>) -> ColVector<m, R>? {
        assert(result.isDiagonal)
        let B = result
        let r = rank
        let P = left
        let Pb = P * b
        
        if B.diagonalComponents.enumerated().contains(where: { (i, d) in
            (d.isZero && !Pb[i].isZero) || (!d.isZero && !Pb[i].isDivible(by: d))
        }) {
            return nil // no solution
        }
        
        if Pb.nonZeroEntries.contains(where: { (i, _, a) in i >= r && !a.isZero } ) {
            return nil // no solution
        }
        
        let Q = right
        let y = ColVector<m, R>(size: (B.size.cols, 1)) { setEntry in
            B.diagonalComponents.enumerated().forEach { (i, d) in
                if !d.isZero {
                    setEntry(i, 0, Pb[i] / d)
                }
            }
        }
        return Q * y
    }
}

extension MatrixEliminationResult where n == m {
    public var determinant: R {
        assert(result.isDiagonal)
        
        if rank == size.rows {
            return rowOps.multiply { $0.determinant }.inverse!
                * colOps.multiply { $0.determinant }.inverse!
                * result.diagonalComponents.multiplyAll()
        } else {
            return .zero
        }
    }
    
    public var inverse: Matrix<n, n, R>? {
        assert(result.isSquare)
        return (result.isIdentity) ? right * left : nil
    }
}

private extension MatrixEliminationResult {
    
    var rowOpsInverse: [RowElementaryOperation<R>] {
        rowOps.reversed().map{ $0.inverse }
    }

    var colOpsInverse: [ColElementaryOperation<R>] {
        colOps.reversed().map{ $0.inverse }
    }

    //  Given row ops [P1, ..., Pn],
    //  produce P = (Pn ... P1) * I by applying the row-ops from P1 to Pn.
    
    func composeRowOps<n, m, S>(_ ops: S, restrictedToCols colRange: Range<Int>) -> Matrix<n, m, R> where S: Sequence, S.Element == RowElementaryOperation<R> {
        composeRowOps(size: size.rows, ops: ops, restrictedToCols: colRange)
    }
    
    //  Given row ops [P1, ..., Pn],
    //  produce P = I * (Pn ... P1) by applying the corresponding col-ops from Pn to P1.
    //  Compute by P^t = (P1^t ... Pn^t) * I^t,
    
    func composeRowOps<n, m, S>(_ ops: S, restrictedToRows rowRange: Range<Int>) -> Matrix<n, m, R> where S: Sequence, S.Element == RowElementaryOperation<R> {
        composeRowOps(size: size.rows, ops: ops.reversed().map{ $0.transposed.asRowOperation }, restrictedToCols: rowRange).transposed
    }
    
    //  Given col ops [Q1, ..., Qn],
    //  produce Q = I * (Q1 ... Qn) by applying the col-ops from Q1 to Qn.
    //  Compute by Q^t = (Qn^t ... Q1^t) * I^t.

    func composeColOps<n, m, S>(_ ops: S, restrictedToRows rowRange: Range<Int>) -> Matrix<n, m, R> where S: Sequence, S.Element == ColElementaryOperation<R> {
        composeRowOps(size: size.cols, ops: ops.map{ $0.transposed }, restrictedToCols: rowRange).transposed
    }
    
    //  Given col ops [Q1, ..., Qn],
    //  produce Q = (Q1 ... Qn) * I by applying the corresponding row-ops from Qn to Q1.
    
    func composeColOps<n, m, S>(_ ops: S, restrictedToCols colRange: Range<Int>) -> Matrix<n, m, R> where S: Sequence, S.Element == ColElementaryOperation<R> {
        composeRowOps(size: size.cols, ops: ops.reversed().map{ $0.asRowOperation }, restrictedToCols: colRange)
    }
    
    private func composeRowOps<n, m, S>(size n: Int, ops: S, restrictedToCols colRange: Range<Int>) -> Matrix<n, m, R> where S: Sequence, S.Element == RowElementaryOperation<R> {
        MatrixEliminationWorker(
            size: (n, colRange.endIndex - colRange.startIndex),
            entries: colRange.map { i in (i, i - colRange.startIndex, .identity) }
        ).applyAll(ops).resultAs(Matrix.self)
    }
}
