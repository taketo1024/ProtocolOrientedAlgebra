//
//  HermiteEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/11/08.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

final class RowHermiteEliminator<R: EuclideanRing>: RowEchelonEliminator<R> {
    override func iterationFinalStep() {
        super.iterationFinalStep()
        
        let a0 = worker.headComponent(ofRow: currentRow)!.value
        for (i, _, a) in worker.components(inCol: currentCol, withinRows: 0 ..< currentRow) {
            let q = a / a0
            if !q.isZero {
                apply(.AddRow(at: currentRow, to: i, mul: -q))
            }
        }
    }
    
    override func updateComponents() {
        setComponents(worker.components)
    }
}

final class ColHermiteEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    override func iteration() {
        subrun(RowHermiteEliminator.self, transpose: true)
    }

    override func isDone() -> Bool {
        true
    }
}
