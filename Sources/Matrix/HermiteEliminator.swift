//
//  HermiteEliminator.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/11/08.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public final class RowHermiteEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    internal var targetRow = 0
    internal var targetCol = 0
    internal var rank = 0

    override func prepare() {
        run(RowEchelonEliminator.self)
        rank = target.table.count
    }

    @_specialize(where R == IntegerNumber)
    internal override func iteration() -> Bool {
        if targetRow >= rank || targetCol >= cols {
            return true
        }

        let a0 = target[targetRow, targetCol]
        if a0 == .zero {
            targetCol += 1
            return false
        }

        for i in 0 ..< targetRow {
            let a = target[i, targetCol]
            if a == .zero {
                continue
            }

            let q = a / a0
            if q != .zero {
                apply(.AddRow(at: targetRow, to: i, mul: -q))
            }
        }

        targetRow += 1
        targetCol += 1
        return false
    }
}

public final class ColHermiteEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    internal override func iteration() -> Bool {
        runTranpose(RowHermiteEliminator.self)
        return true
    }
}
