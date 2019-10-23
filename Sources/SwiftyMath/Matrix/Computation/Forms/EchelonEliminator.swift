//
//  EchelonEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/11/08.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public class RowEchelonEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    var worker: RowEliminationWorker<R>!
    var currentRow = 0
    var currentCol = 0
    
    override func prepare() {
        worker = RowEliminationWorker(size: size, components: components, trackRowInfos: true)
    }
    
    override func isDone() -> Bool {
        currentRow >= size.rows || currentCol >= size.cols
    }
    
    @_specialize(where R == 𝐙)
    override func iteration() {
        
        // find pivot point
        let elements = worker.headComponents(inCol: currentCol)
        guard let (i0, _, a0) = findPivot(in: elements) else {
            currentCol += 1
            return
        }
        
        log("Pivot: \((i0, currentCol)), \(a0)")
        
        // eliminate target col
        
        var again = false
        
        let targets = elements.compactMap { (i, _, a) -> (Int, R)? in
            if i == i0 { return nil }
            let (q, r) = a /% a0
            
            if !r.isZero {
                again = true
            }
            
            return (i, -q)
        }
        
        worker.batchAddRow(at: i0, to: targets.map{ $0.0 }, multipliedBy: targets.map{ $0.1 })
        
        for (i, r) in targets {
            append(.AddRow(at: i0, to: i, mul: r))
        }
        
        if again {
            return
        }
        
        // final step
        if !a0.isNormalized {
            apply(.MulRow(at: i0, by: a0.normalizingUnit))
        }
        
        if i0 != currentRow {
            apply(.SwapRows(i0, currentRow))
        }
        
        iterationFinalStep()
        
        currentRow += 1
        currentCol += 1
    }
    
    func iterationFinalStep() {
        // override in subclass
    }
    
    @_specialize(where R == 𝐙)
    private func findPivot(in candidates: [MatrixComponent<R>]) -> MatrixComponent<R>? {
        candidates.min { (c1, c2) in
            let (i1, i2) = (c1.row, c2.row)
            let (d1, d2) = (c1.value.euclideanDegree, c2.value.euclideanDegree)
            return d1 < d2 || (d1 == d2 && worker.weight(ofRow: i1) < worker.weight(ofRow: i2))
        }
    }
    
    override func apply(_ s: MatrixEliminator<R>.ElementaryOperation) {
        worker.apply(s)
        
        if debug {
            components = worker.components
        }
        
        super.apply(s)
    }
    
    override func finalize() {
        components = worker.components
    }
}

public final class ColEchelonEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    override func prepare() {
        subrun(RowEchelonEliminator.self, transpose: true)
        exit()
    }
}
