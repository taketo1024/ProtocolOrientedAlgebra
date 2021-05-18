//
//  EchelonEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/11/08.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

internal class RowEchelonEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    var currentRow = 0
    var currentCol = 0
    
    override var form: MatrixEliminationForm {
        !transposed ? .RowEchelon : .ColEchelon
    }
    
    override func isDone() -> Bool {
        currentRow >= size.rows || currentCol >= size.cols
    }
    
    @_specialize(where R == 𝐙)
    override func iteration() {
        
        // find pivot point
        let colEntries = worker.headColEntries(in: currentCol)
        guard let (i0, a0) = findPivot(in: colEntries) else {
            currentCol += 1
            return
        }
        
        log("Pivot: \((i0, currentCol)), \(a0)")
        
        // eliminate target col
        
        if colEntries.count > 1 {
            var again = false
            
            let targets = colEntries.compactMap { (i, a) -> (Int, R)? in
                if i == i0 {
                    return nil
                }
                
                let (q, r) = a /% a0
                
                if !r.isZero {
                    again = true
                }
                
                return (i, -q)
            }
            
            batchAddRow(at: i0, targets: targets)
            
            if again {
                return
            }
        }
        
        // final step
        if !a0.isNormalized {
            apply(.MulRow(at: i0, by: a0.normalizingUnit))
        }
        
        if i0 != currentRow {
            apply(.SwapRows(i0, currentRow))
        }
        
        reduceCurrentCol()
        currentRow += 1
        currentCol += 1
    }
    
    fileprivate func reduceCurrentCol() {
        // override in subclass
    }
    
    fileprivate func batchAddRow(at i0: Int, targets: [ColEntry<R>]) {
        worker.batchAddRow(
            at: i0,
            to: targets.map{ $0.row },
            multipliedBy: targets.map{ $0.value }
        )
        
        append(targets.map{ (i, r) in
            .AddRow(at: i0, to: i, mul: r)
        })
    }
    
    @_specialize(where R == 𝐙)
    private func findPivot(in candidates: [ColEntry<R>]) -> ColEntry<R>? {
        candidates.min { (c1, c2) in
            let (i1, i2) = (c1.row, c2.row)
            let (d1, d2) = (c1.value.euclideanDegree, c2.value.euclideanDegree)
            return d1 < d2 || (d1 == d2 && worker.rowWeight(i1) < worker.rowWeight(i2))
        }
    }
}

internal class ReducedRowEchelonEliminator<R: EuclideanRing>: RowEchelonEliminator<R> {
    override var form: MatrixEliminationForm {
        !transposed ? .RowHermite : .ColHermite
    }

    override func reduceCurrentCol() {
        let a0 = worker.row(currentRow).headElement!.value
        let targets = worker
            .colEntries(in: currentCol, aboveRow: currentRow)
            .compactMap { (i, a) -> (Int, R)? in
                let q = a / a0
                return !q.isZero ? (i, -q) : nil
            }
        
        batchAddRow(at: currentRow, targets: targets)
    }
}
