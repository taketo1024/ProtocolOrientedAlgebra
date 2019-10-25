//
//  MatrixEliminationResult.swift
//  Sample
//
//  Created by Taketo Sano on 2018/04/26.
//

public struct MatrixEliminationResult<n: SizeType, m: SizeType, R: EuclideanRing> {
    public let form: MatrixEliminator<R>.Form
    public let result: Matrix<n, m, R>
    let rowOps: [RowElementaryOperation<R>]
    let colOps: [ColElementaryOperation<R>]
    
    internal init(form: MatrixEliminator<R>.Form, result: Matrix<n, m, R>, rowOps: [RowElementaryOperation<R>], colOps: [ColElementaryOperation<R>]) {
        self.form = form
        self.result = result
        self.rowOps = rowOps
        self.colOps = colOps
    }
    
    // returns P of: P * A * Q = B
    
    public var left: Matrix<n, n, R> {
        let n = result.size.rows
        let P = RowEliminationWorker<R>.identity(size: n)
        for s in rowOps {
            P.apply(s)
        }
        return P.resultAs(Matrix.self)
    }
    
    // returns P^{-1} of: P * A * Q = B
    
    public var leftInverse: Matrix<n, n, R> {
        let n = result.size.rows
        let P = RowEliminationWorker<R>.identity(size: n)
        for s in rowOps.reversed() {
            P.apply(s.inverse)
        }
        return P.resultAs(Matrix.self)
    }
    
    // returns Q of: P * A * Q = B
    
    public var right: Matrix<m, m, R> {
        let m = result.size.cols
        let Q = ColEliminationWorker<R>.identity(size: m)
        for s in colOps {
            Q.apply(s)
        }
        return Q.resultAs(Matrix.self)
    }
    
    // returns Q^{-1} of: P * A * Q = B
    
    public var rightInverse: Matrix<m, m, R> {
        let m = result.size.cols
        let Q = ColEliminationWorker<R>.identity(size: m)
        for s in colOps.reversed() {
            Q.apply(s.inverse)
        }
        return Q.resultAs(Matrix.self)
    }
    
    // returns r of:
    //
    //  P * A * Q = [ D_r | O,  ]
    //              [ O   | O_k ]

    public var rank: Int {
        // TODO support Echelon types
        assert(result.isDiagonal)
        return result.diagonalComponents.count{ !$0.isZero }
    }
    
    public var nullity: Int {
        return result.size.cols - rank
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
    // Note that Q is multiplied to [O; I_k] from the <left>,
    // so we must consider the corresponding <row> operations.
    
    public var kernelMatrix: Matrix<m, DynamicSize, R>  {
        assert(result.isDiagonal)
        let (m, r) = (result.size.cols, rank)
        let k = m - r
        let size = (rows: m, cols: k)
        
        if size.rows == 0 || size.cols == 0 {
            return DMatrix.zero(size: size).as(Matrix.self)
        }
        
        let comps = (0 ..< k).map{ j -> MatrixComponent<R> in (r + j, j, R.identity) }
        let Z = RowEliminationWorker<R>(size: size, components: comps)
        for s in colOps.reversed() {
            switch s {
            case let .AddCol(at: i, to: j, mul: a):
                Z.apply(.AddRow(at: j, to: i, mul: a))
            default:
                Z.apply(s.transposed)
            }
        }
        
        return Z.resultAs(Matrix.self)
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
        let (m, r) = (result.size.cols, rank)
        let k = m - r
        let size = (rows: k, cols: m)
        
        if size.rows == 0 || size.cols == 0 {
            return DMatrix.zero(size: size).as(Matrix.self)
        }
        
        let comps = (0 ..< k).map{ i -> MatrixComponent<R> in (i, r + i, R.identity) }
        let T = ColEliminationWorker<R>(size: size, components: comps)
        for s in colOps.reversed() {
            T.apply(s.inverse)
        }
        return T.resultAs(Matrix.self)
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
        let n = result.size.rows
        let r = rank
        let size = (rows: n, cols: r)
        
        if size.rows == 0 || size.cols == 0 {
            return DMatrix.zero(size: size).as(Matrix.self)
        }
        
        let diag = result.diagonalComponents
        let comps = (0 ..< r).map{ i -> MatrixComponent<R> in (i, i, diag[i]) }
        let D = RowEliminationWorker<R>(size: size, components: comps)
        for s in rowOps.reversed() {
            D.apply(s.inverse)
        }
        
        return D.resultAs(Matrix.self)
    }
    
    // Returns the transition matrix T from B = Im(A) to D_r,
    //
    //     B = P^{-1} [D_r; O]
    //     <=> D_r = [I_r, O] (P * B)
    //
    // so
    //
    //     T = [I_r, O] * P
    //       = P[0 ..< r, -].
    //
    // Note that P is multiplied to [I_r | O] from the <right>,
    // so we must consider the corresponding <col> operations.

    public var imageTransitionMatrix: Matrix<DynamicSize, m, R> {
        assert(result.isDiagonal)
        let (n, r) = (result.size.rows, rank)
        let size = (rows: r, cols: n)
        
        if size.rows == 0 || size.cols == 0 {
            return DMatrix.zero(size: size).as(Matrix.self)
        }
        
        let comps = (0 ..< r).map{ i -> MatrixComponent<R> in (i, i, R.identity) }
        let T = ColEliminationWorker<R>(size: size, components: comps)
        for s in rowOps.reversed() {
            switch s {
            case let .AddRow(at: i, to: j, mul: a):
                T.apply(.AddCol(at: j, to: i, mul: a))
            default:
                T.apply(s.transposed)
            }
        }
        return T.resultAs(Matrix.self)
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
        
        if Pb.nonZeroComponents.contains(where: { (i, _, a) in i >= r && !a.isZero } ) {
            return nil // no solution
        }
        
        let Q = right
        let y = ColVector<m, R>(size: (B.size.cols, 1), grid: B.diagonalComponents.enumerated().map{ (i, d) in
            d.isZero ? .zero : Pb[i] / d
        })
        return Q * y
    }
}

extension MatrixEliminationResult where n == m {
    public var determinant: R {
        assert(result.isDiagonal)
        
        if rank == result.size.rows {
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
