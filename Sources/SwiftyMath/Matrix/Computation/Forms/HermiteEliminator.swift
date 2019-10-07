//
//  HermiteEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/11/08.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public final class RowHermiteEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    var worker: RowEliminationWorker<R>!
    var currentRow = 0
    var rank = 0
    
    override func prepare() {
        let e = RowEchelonEliminator(size: size, components: components, debug: debug)
        e.run()
        
        components = e.components
        worker = e.worker
        
        worker.redo()
    }
    
    override func isDone() -> Bool {
        currentRow >= size.rows
    }
    
    @_specialize(where R == 𝐙)
    override func iteration() {
        guard let (j0, a0) = worker.headElement(currentRow) else {
            return exit()
        }
        
        for i in 0 ..< currentRow {
            let a = R.zero // TODO
//            let a = components.pointee[i, j0]
            if a.isZero {
                continue
            }
            
            let q = a / a0
            if !q.isZero {
                apply(.AddRow(at: currentRow, to: i, mul: -q))
            }
        }
        
        currentRow += 1
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

public final class ColHermiteEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    override func prepare() {
        subrun(RowHermiteEliminator.self, transpose: true)
        exit()
    }
}
