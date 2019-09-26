//
//  SmithEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/11/08.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public final class SmithEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    var currentIndex = 0
    var diagonal: [R] = []
    
    override var form: Form {
        .Smith
    }
    
    override func prepare() {
        subrun(DiagonalEliminator(mode: mode, debug: debug))
        diagonal = target.pointee.diagonal.exclude{ $0.isZero }
    }
    
    override func shouldIterate() -> Bool {
        currentIndex < diagonal.count
    }
    
    @_specialize(where R == 𝐙)
    override func iteration() {
        guard let pivot = findPivot() else {
            return exit()
        }
        
        let i0 = pivot.0
        var a0 = pivot.1
        
        if !a0.isNormalized {
            apply(.MulRow(at: i0, by: a0.normalizingUnit))
            a0 = a0.normalized
        }
        
        if !a0.isIdentity {
            var again = false

            for i in (currentIndex ..< diagonal.count) where i != i0 {
                let a = diagonal[i]
                if !a.isDivible(by: a0) {
                    diagonalGCD((i0, a0), (i, a))
                    again = true

                }
            }
            
            if again {
                return
            }
        }
        
        if i0 != currentIndex {
            swapDiagonal(i0, currentIndex)
        }
        
        currentIndex += 1
    }
    
    override func apply(_ s: MatrixEliminator<R>.ElementaryOperation) {
        switch s {
        case let .MulRow(at: i, by: a):
            set(i, a * diagonal[i])
        default:
            fatalError()
        }
        
        super.apply(s)
    }
    
    private func set(_ i: Int, _ a: R) {
        diagonal[i] = a
        target.pointee[i, i] = a
    }
    
    private func findPivot() -> (Int, R)? {
        diagonal
            .enumerated()
            .filter{ (i, _) in i >= currentIndex }
            .min { (c1, c2) in c1.1.euclideanDegree < c2.1.euclideanDegree }
    }
    
    private func diagonalGCD(_ d1: (Int, R), _ d2: (Int, R)) {
        let (i, a) = d1
        let (j, b) = d2
        
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
        
        log("DiagonalGCD:  (\(i), \(i)), (\(j), \(j))")
    }
    
    private func swapDiagonal(_ i: Int, _ j: Int) {
        let d0 = diagonal[i]
        set(i, diagonal[j])
        set(j, d0)
        
        append(.SwapRows(i, j))
        append(.SwapCols(i, j))
        
        log("SwapDiagonal: (\(i), \(i)), (\(j), \(j))")
    }
}
