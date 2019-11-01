//
//  SmithEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/11/08.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

final class SmithEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    var currentIndex = 0
    var diagonals: [R] = []
    
    override func prepare() {
        subrun(DiagonalEliminator(worker: worker, debug: debug))
        diagonals = worker.components.sorted { $0.row }.map { $0.value }
    }
    
    override func isDone() -> Bool {
        currentIndex >= diagonals.count
    }
    
    @_specialize(where R == 𝐙)
    override func iteration() {
        guard let (i0, a0) = findPivot() else {
            return abort()
        }
        
        if !a0.isIdentity {
            for i in (currentIndex ..< diagonals.count) where i != i0 {
                let a = diagonals[i]
                if !a.isDivible(by: a0) {
                    diagonalGCD((i0, a0), (i, a))
                    return
                }
            }
        }
        
        if !a0.isNormalized {
            apply(.MulRow(at: i0, by: a0.normalizingUnit))
        }
        
        if i0 != currentIndex {
            swapDiagonal(i0, currentIndex)
        }
        
        currentIndex += 1
    }
    
    override func apply(_ s: RowElementaryOperation<R>) {
        switch s {
        case let .MulRow(at: i, by: a):
            diagonals[i] = a * diagonals[i]
            super.apply(s)
        default:
            fatalError()
        }
    }
    
    private func findPivot() -> (Int, R)? {
        diagonals[currentIndex...]
            .enumerated()
            .min { (c1, c2) in c1.1.matrixEliminationWeight < c2.1.matrixEliminationWeight }
            .map{ (i, a) in (i + currentIndex, a) }
    }
    
    private func diagonalGCD(_ d1: (Int, R), _ d2: (Int, R)) {
        let (i, a) = d1
        let (j, b) = d2
        
        log("DiagonalGCD:  (\(i), \(i)), (\(j), \(j))")
        
        // d = gcd(a, b) = pa + qb
        // m = lcm(a, b) = -a * b / d
        
        let (p, q, d) = extendedGcd(a, b)
        let m = -(a * b) / d
        
        set(i, d)
        set(j, m)
        
        append(.AddRow(at: i, to: j, mul: p))     // [a, 0; pa, b]
        append(.AddCol(at: j, to: i, mul: q))     // [a, 0;  d, b]
        append(.AddRow(at: j, to: i, mul: -a/d))  // [0, m;  d, b]
        append(.AddCol(at: i, to: j, mul: -b/d))  // [0, m;  d, 0]
        append(.SwapRows(i, j))                   // [d, 0;  0, m]
    }
    
    private func swapDiagonal(_ i: Int, _ j: Int) {
        log("SwapDiagonal: (\(i), \(i)), (\(j), \(j))")
        
        let (a, b) = (diagonals[i], diagonals[j])
        
        set(i, b)
        set(j, a)

        append(.SwapRows(i, j))
        append(.SwapCols(i, j))
    }
    
    private func set(_ i: Int, _ r: R) {
        worker.row(i).headPointer!.pointee.element.value = r
        diagonals[i] = r
    }
}
