//
//  MatrixEliminationResult.swift
//  Sample
//
//  Created by Taketo Sano on 2018/04/26.
//

import Foundation

public struct MatrixEliminationResult<n: SizeType, m: SizeType, R: EuclideanRing> {
    public let form: MatrixEliminator<R>.Form
    public let result: Matrix<n, m, R>
    let rowOps: [MatrixEliminator<R>.ElementaryOperation]
    let colOps: [MatrixEliminator<R>.ElementaryOperation]
    
    private let matrixCache: CacheDictionary<String, DMatrix<R>> = .empty
    
    internal init(form: MatrixEliminator<R>.Form, result: Matrix<n, m, R>, rowOps: [MatrixEliminator<R>.ElementaryOperation], colOps: [MatrixEliminator<R>.ElementaryOperation]) {
        self.form = form
        self.result = result
        self.rowOps = rowOps
        self.colOps = colOps
    }
    
    // returns P of: P * A * Q = B
    
    public var left: Matrix<n, n, R> {
        return matrixCache.useCacheOrSet(key: "left") {
            let n = result.size.rows
            let P = RowEliminationWorker<R>.identity(size: n)
            for s in rowOps {
                P.apply(s)
            }
            return DMatrix(size: (n, n), data: P.resultData)
        }.as(Matrix.self)
    }
    
    // returns P^{-1} of: P * A * Q = B
    
    public var leftInverse: Matrix<n, n, R> {
        return matrixCache.useCacheOrSet(key: "leftinv") {
            let n = result.size.rows
            let P = RowEliminationWorker<R>.identity(size: n)
            for s in rowOps.reversed() {
                P.apply(s.inverse)
            }
            return DMatrix(size: (n, n), data: P.resultData)
        }.as(Matrix.self)
    }
    
    // returns Q of: P * A * Q = B
    
    public var right: Matrix<m, m, R> {
        return matrixCache.useCacheOrSet(key: "right") {
            let m = result.size.cols
            let Q = ColEliminationWorker<R>.identity(size: m)
            for s in colOps {
                Q.apply(s)
            }
            return DMatrix(size: (m, m), data: Q.resultData)
        }.as(Matrix.self)
    }
    
    // returns Q^{-1} of: P * A * Q = B
    
    public var rightInverse: Matrix<m, m, R> {
        return matrixCache.useCacheOrSet(key: "rightinv") {
            let m = result.size.cols
            let Q = ColEliminationWorker<R>.identity(size: m)
            for s in colOps.reversed() {
                Q.apply(s.inverse)
            }
            return DMatrix(size: (m, m), data: Q.resultData)
        }.as(Matrix.self)
    }
    
    // returns r of:
    //
    //  P * A * Q = [ D_r | O,  ]
    //              [ O   | O_k ]

    public var rank: Int {
        // TODO support Echelon types
        assert(result.isDiagonal)
        return result.diagonal.count{ $0 != .zero }
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
    // so P^{-1} [D_r; O] gives the imageMatrix.
    
    public var imageMatrix: Matrix<n, DynamicSize, R> {
        assert(result.isDiagonal)
        return matrixCache.useCacheOrSet(key: "image") {
            let n = result.size.rows
            let r = rank
            let size = (rows: n, cols: r)
            
            if size.rows == 0 || size.cols == 0 {
                return DMatrix.zero(size: size)
            }
            
            let diag = result.diagonal
            let comps = (0 ..< r).map{ i -> MatrixComponent<R> in (i, i, diag[i]) }
            let D = RowEliminationWorker<R>(size: size, components: comps)
            for s in rowOps.reversed() {
                D.apply(s.inverse)
            }
            
            return DMatrix(size: size, data: D.resultData)
        }.as(Matrix.self)
    }
    
    // Returns the matrix consisting of the basis vectors of Ker(A).
    // If
    //
    //     P * A * Q = [ D_r | O   ]
    //                 [   O | O_k ]
    //
    // then for any j in (r <= j < m),
    //
    //     (A * Q) * e_j = A * (Q * e_j)
    //                   = A * q_j
    //                   = o
    //
    // so
    //
    //     Z = [q_r ... q_{m-1}] = Q * [O  ]
    //                                 [I_k]
    //
    // gives the kernelMatrix.
    //
    // Note that Q is multiplied to [O; I_k] from the <left>,
    // so we must consider the corresponding <row> operations.
    
    public var kernelMatrix: Matrix<m, DynamicSize, R>  {
        assert(result.isDiagonal)
        return matrixCache.useCacheOrSet(key: "kernel") {
            let (m, r) = (result.size.cols, rank)
            let k = m - r
            let size = (rows: m, cols: k)
            
            if size.rows == 0 || size.cols == 0 {
                return DMatrix.zero(size: size)
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
            
            return DMatrix(size: size, data: Z.resultData)
        }.as(Matrix.self)
    }
    
    // Returns the transition matrix T from Z to I,
    // i.e.
    //
    //     z_j = q_{r + j} ∈ R^m  --T--> e_j ∈ R^k  (0 <= j < k)
    //     <=> T * Z = I_k
    //
    // Sinze Z = Q * [O; I_k],
    //
    //     T = [O | I_k] Q^{-1}
    //
    // satisfies the desired equation.
    
    public var kernelTransitionMatrix: Matrix<DynamicSize, m, R> {
        assert(result.isDiagonal)
        return matrixCache.useCacheOrSet(key: "kerneltrans") {
            let (m, r) = (result.size.cols, rank)
            let k = m - r
            let size = (rows: k, cols: m)
            
            if size.rows == 0 || size.cols == 0 {
                return DMatrix.zero(size: size)
            }
            
            let comps = (0 ..< k).map{ i -> MatrixComponent<R> in (i, r + i, R.identity) }
            let T = ColEliminationWorker<R>(size: size, components: comps)
            for s in colOps.reversed() {
                T.apply(s.inverse)
            }
            return DMatrix(size: size, data: T.resultData)
        }.as(Matrix.self)
    }
    
    // Returns the transition matrix T from B = Im(A) to D_r,
    //
    //     B = P^{-1} [D_r; O]
    //     <=> D_r = [I_r | O] (P * B)
    //
    // so  T = [I_r | O] * P.
    //
    // Note that P is multiplied to [I_r | O] from the <right>,
    // so we must consider the corresponding <col> operations.

    public var imageTransitionMatrix: Matrix<DynamicSize, m, R> {
        assert(result.isDiagonal)
        return matrixCache.useCacheOrSet(key: "imagetrans") {
            let (n, r) = (result.size.rows, rank)
            let size = (rows: r, cols: n)
            
            if size.rows == 0 || size.cols == 0 {
                return DMatrix.zero(size: size)
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
            return DMatrix(size: size, data: T.resultData)
        }.as(Matrix.self)
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
        
        if B.diagonal.enumerated().contains(where: { (i, d) in
            (d == .zero && Pb[i] != .zero) || (d != .zero && Pb[i] % d != .zero)
        }) {
            return nil // no solution
        }
        
        if Pb.components.contains(where: { (i, _, a) in i >= r && a != .zero } ) {
            return nil // no solution
        }
        
        let Q = right
        let y = ColVector<m, R>(size: (B.size.cols, 1), grid: B.diagonal.enumerated().map{ (i, d) in
            (d == .zero) ? .zero : Pb[i] / d
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
                * result.diagonal.multiplyAll()
        } else {
            return .zero
        }
    }
    
    public var inverse: Matrix<n, n, R>? {
        assert(result.isSquare)
        return (result.isIdentity) ? right * left : nil
    }
}
