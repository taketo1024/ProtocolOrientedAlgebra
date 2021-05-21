//
//  MatrixEliminationResult.swift
//  Sample
//
//  Created by Taketo Sano on 2018/04/26.
//

public struct MatrixEliminationResult<Impl: MatrixImpl, n: SizeType, m: SizeType> {
    public typealias R = Impl.BaseRing
    
    private let eliminator: MatrixEliminator<R>
    public init(_ eliminator: MatrixEliminator<R>) {
        self.eliminator = eliminator
    }
    
    public var form: MatrixEliminationForm {
        eliminator.form
    }
    
    public var size: MatrixSize {
        eliminator.size
    }
    
    public var result: MatrixIF<Impl, n, m> {
        eliminator.resultAs(MatrixIF.self)
    }
    
    var rowOps: [RowElementaryOperation<R>] {
        eliminator.rowOps
    }
    
    var colOps: [ColElementaryOperation<R>] {
        eliminator.colOps
    }
    
    var rowOpsInverse: [RowElementaryOperation<R>] {
        rowOps.reversed().map{ $0.inverse }
    }

    var colOpsInverse: [ColElementaryOperation<R>] {
        colOps.reversed().map{ $0.inverse }
    }
    
    public var isSquare: Bool {
        size.rows == size.cols
    }
    
    public var isDiagonal: Bool {
        eliminator.entries.allSatisfy { (i, j, _) in i == j }
    }
    
    public var isIdentity: Bool {
        isSquare && eliminator.entries.allSatisfy { (i, j, a) in i == j && a.isIdentity }
    }
    
    public var diagonalEntries: [R] {
        eliminator.headEntries.map{ $0.value }
    }
    
    public var rank: Int {
        eliminator.headEntries.count
    }
    
    public var nullity: Int {
        return size.cols - rank
    }
    
    // returns P of: P * A * Q = B

    public var left: MatrixIF<Impl, n, n> {
        composeRowOps(rowOps, restrictedToRows: 0 ..< size.rows)
    }
    
    public func left(restrictedToRows rowRange: Range<Int>) -> MatrixIF<Impl, anySize, n> {
        composeRowOps(rowOps, restrictedToRows: rowRange)
    }
    
    // returns P^{-1} of: P * A * Q = B
    
    public var leftInverse: MatrixIF<Impl, n, n> {
        composeRowOps(rowOpsInverse, restrictedToCols: 0 ..< size.rows)
    }
    
    public func leftInverse(restrictedToCols colRange: Range<Int>) -> MatrixIF<Impl, n, anySize> {
        composeRowOps(rowOpsInverse, restrictedToCols: colRange)
    }
    
    // returns Q of: P * A * Q = B
    
    public var right: MatrixIF<Impl, m, m> {
        composeColOps(colOps, restrictedToRows: 0 ..< size.cols)
    }
    
    public func right(restrictedToCols colRange: Range<Int>) -> MatrixIF<Impl, m, anySize> {
        composeColOps(colOps, restrictedToCols: colRange)
    }
    
    // returns Q^{-1} of: P * A * Q = B
    
    public var rightInverse: MatrixIF<Impl, m, m> {
        composeColOps(colOpsInverse, restrictedToRows: 0 ..< size.cols)
    }
    
    public func rightInverse(restrictedToRows rowRange: Range<Int>) -> MatrixIF<Impl, anySize, m> {
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
    
    public var kernelMatrix: MatrixIF<Impl, m, anySize>  {
        assert(isDiagonal)
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
    
    public var kernelTransitionMatrix: MatrixIF<Impl, anySize, m> {
        assert(isDiagonal)
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
    
    public var imageMatrix: MatrixIF<Impl, n, anySize> {
        assert(isDiagonal)
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

    public var imageTransitionMatrix: MatrixIF<Impl, anySize, n> {
        assert(isDiagonal)
        return left(restrictedToRows: 0 ..< rank)
    }
}

extension MatrixEliminationResult where R: EuclideanRing {
    // Find a solution x to: Ax = b.
    // With PAQ = B,
    //
    //    Ax = b  <==>  (PAQ) Q^{-1}x = Pb
    //            <==>    B      y    = Pb
    //
    // where y = Q^{-1}x <==> x = Qy.
    
    public func invert(_ b: MatrixIF<Impl, n, _1>) -> MatrixIF<Impl, m, _1>? {
        assert(isDiagonal)
        let r = rank
        let P = left
        let Pb = P * b
        
        if diagonalEntries.enumerated().contains(where: { (i, d) in
            (d.isZero && !Pb[i].isZero) || (!d.isZero && !Pb[i].isDivible(by: d))
        }) {
            return nil // no solution
        }
        
        if Pb.nonZeroEntries.contains(where: { (i, _, a) in i >= r && !a.isZero } ) {
            return nil // no solution
        }
        
        let Q = right
        let y = MatrixIF<Impl, m, _1>(size: (size.cols, 1)) { setEntry in
            diagonalEntries.enumerated().forEach { (i, d) in
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
        assert(isSquare)
        if rank == size.rows {
            return rowOps.multiply { $0.determinant }.inverse!
                * colOps.multiply { $0.determinant }.inverse!
                * diagonalEntries.multiplyAll()
        } else {
            return .zero
        }
    }
    
    public var inverse: MatrixIF<Impl, n, n>? {
        assert(isSquare)
        return (isIdentity) ? right * left : nil
    }
}

private extension MatrixEliminationResult {
    
    //  Given row ops [P1, ..., Pn],
    //  produce P = (Pn ... P1) * I by applying the row-ops from P1 to Pn.
    
    func composeRowOps<n, m, S>(_ ops: S, restrictedToCols colRange: Range<Int>) -> MatrixIF<Impl, n, m> where S: Sequence, S.Element == RowElementaryOperation<R> {
        composeRowOps(size: size.rows, ops: ops, restrictedToCols: colRange)
    }
    
    //  Given row ops [P1, ..., Pn],
    //  produce P = I * (Pn ... P1) by applying the corresponding col-ops from Pn to P1.
    //  Compute by P^t = (P1^t ... Pn^t) * I^t,
    
    func composeRowOps<n, m, S>(_ ops: S, restrictedToRows rowRange: Range<Int>) -> MatrixIF<Impl, n, m> where S: Sequence, S.Element == RowElementaryOperation<R> {
        composeRowOps(size: size.rows, ops: ops.reversed().map{ $0.transposed.asRowOperation }, restrictedToCols: rowRange).transposed
    }
    
    //  Given col ops [Q1, ..., Qn],
    //  produce Q = I * (Q1 ... Qn) by applying the col-ops from Q1 to Qn.
    //  Compute by Q^t = (Qn^t ... Q1^t) * I^t.

    func composeColOps<n, m, S>(_ ops: S, restrictedToRows rowRange: Range<Int>) -> MatrixIF<Impl, n, m> where S: Sequence, S.Element == ColElementaryOperation<R> {
        composeRowOps(size: size.cols, ops: ops.map{ $0.transposed }, restrictedToCols: rowRange).transposed
    }
    
    //  Given col ops [Q1, ..., Qn],
    //  produce Q = (Q1 ... Qn) * I by applying the corresponding row-ops from Qn to Q1.
    
    func composeColOps<n, m, S>(_ ops: S, restrictedToCols colRange: Range<Int>) -> MatrixIF<Impl, n, m> where S: Sequence, S.Element == ColElementaryOperation<R> {
        composeRowOps(size: size.cols, ops: ops.reversed().map{ $0.asRowOperation }, restrictedToCols: colRange)
    }
    
    private func composeRowOps<n, m, S>(size n: Int, ops: S, restrictedToCols colRange: Range<Int>) -> MatrixIF<Impl, n, m> where S: Sequence, S.Element == RowElementaryOperation<R> {
        MatrixEliminationWorker(
            size: (n, colRange.endIndex - colRange.startIndex),
            entries: colRange.map { i in (i, i - colRange.startIndex, .identity) }
        ).applyAll(ops).resultAs(MatrixIF.self)
    }
}
