//
//  HermiteEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/11/08.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public final class RowHermiteEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    var worker: RowEliminationWorker<R>!
    var currentRow = 0
    var rank = 0
    
    override var form: MatrixEliminationForm {
        return .RowHermite
    }
    
    override func prepare() {
        let e = RowEchelonEliminator<R>(debug: debug)
        subrun(e)
        
        worker = e.worker
        worker.redo()
    }
    
    override func shouldIterate() -> Bool {
        return currentRow < target.pointee.size.rows
    }
    
    @_specialize(where R == 𝐙)
    override func iteration() {
        guard let (j0, a0) = worker.headElement(row: currentRow) else {
            return exit()
        }
        
        for i in 0 ..< currentRow {
            let a = target.pointee[i, j0]
            if a == .zero {
                continue
            }
            
            let q = a / a0
            if q != .zero {
                apply(.AddRow(at: currentRow, to: i, mul: -q))
            }
        }
        
        currentRow += 1
    }
    
    override func apply(_ s: MatrixEliminator<R>.ElementaryOperation) {
        worker.apply(s)
        
        if debug {
            target.pointee.data = worker.resultData
        }
        
        super.apply(s)
    }
    
    override func finalize() {
        target.pointee.data = worker.resultData
    }
}

public final class ColHermiteEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    override var form: MatrixEliminationForm {
        return .ColHermite
    }

    override func prepare() {
        subrun(RowHermiteEliminator(debug: debug), transpose: true)
        exit()
    }
}
