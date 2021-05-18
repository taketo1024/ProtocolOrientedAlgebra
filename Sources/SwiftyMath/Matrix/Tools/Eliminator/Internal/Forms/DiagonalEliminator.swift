//
//  DiagonalEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/11/08.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

internal final class DiagonalEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    override var form: MatrixEliminationForm {
        .Diagonal
    }
    
    override func isDone() -> Bool {
        worker.entries.allSatisfy { (i, j, a) in
            (i == j) && a.isNormalized
        }
    }
    
    override func iteration() {
        subrun(RowEchelonEliminator(worker: worker))
        
        if isDone() {
            return
        }
        
        worker.transpose()
        subrun(RowEchelonEliminator(worker: worker, transposed: true))
        worker.transpose()
    }
}
