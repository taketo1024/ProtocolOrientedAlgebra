//
//  DiagonalEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/11/08.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

internal final class DiagonalEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    override func isDone() -> Bool {
        let n = target.table.keys.count
        return target.table.allSatisfy{ (i, list) in
            i < n && (list.count == 1)
                  && list.first!.0 == i
                  && list.first!.1.isNormalized
        }
    }
    
    override func iteration() {
        run(RowHermiteEliminator.self)
        
        if isDone() {
            return
        }
        
        run(ColHermiteEliminator.self)
    }
}
