//
//  EchelonEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/11/08.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

class RowEchelonEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    let reduced: Bool
    var currentRow = 0
    var currentCol = 0
    
    init(worker: RowEliminationWorker<R>, reduced: Bool = false, debug: Bool = false) {
        self.reduced = reduced
        super.init(worker: worker, debug: debug)
    }

    override func isDone() -> Bool {
        currentRow >= size.rows || currentCol >= size.cols
    }
    
    @_specialize(where R == 𝐙)
    override func iteration() {
        
        // find pivot point
        let elements = worker.headElements(inCol: currentCol)
        guard let (i0, a0) = findPivot(in: elements) else {
            currentCol += 1
            return
        }
        
        log("Pivot: \((i0, currentCol)), \(a0)")
        
        // eliminate target col
        
        if elements.count > 1 {
            var again = false
            
            let targets = elements.compactMap { (i, a) -> (Int, R)? in
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
        
        if reduced {
            reduceCurrentCol()
        }
        
        currentRow += 1
        currentCol += 1
    }
    
    private func reduceCurrentCol() {
        let a0 = worker.row(currentRow).headElement!.value
        let targets = worker
            .elements(inCol: currentCol, aboveRow: currentRow)
            .compactMap { (i, a) -> (Int, R)? in
                let q = a / a0
                return !q.isZero ? (i, -q) : nil
            }
        
        batchAddRow(at: currentRow, targets: targets)
    }
    
    private func batchAddRow(at i0: Int, targets: [(Int, R)]) {
        worker.batchAddRow(
            at: i0,
            to: targets.map{ $0.0 },
            multipliedBy: targets.map{ $0.1 }
        )
        
        append(targets.map{ (i, r) in
            .AddRow(at: i0, to: i, mul: r)
        })
    }
    
    @_specialize(where R == 𝐙)
    private func findPivot(in candidates: [(row: Int, value: R)]) -> (row: Int, value: R)? {
        candidates.min { (c1, c2) in
            let (i1, i2) = (c1.row, c2.row)
            let (d1, d2) = (c1.value.euclideanDegree, c2.value.euclideanDegree)
            return d1 < d2 || (d1 == d2 && worker.rowWeight(i1) < worker.rowWeight(i2))
        }
    }
}

final class ColEchelonEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    let reduced: Bool
    
    init(worker: RowEliminationWorker<R>, reduced: Bool = false, debug: Bool = false) {
        self.reduced = reduced
        super.init(worker: worker, debug: debug)
    }

    override func prepare() {
        let sub = RowEchelonEliminator(worker: worker, reduced: reduced, debug: debug)
        subrun(sub, transpose: true)
    }
    
    override func isDone() -> Bool {
        true
    }
}
