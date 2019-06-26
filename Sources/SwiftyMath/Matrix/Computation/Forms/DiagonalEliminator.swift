//
//  DiagonalEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/11/08.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public final class DiagonalEliminator<R: EuclideanRing>: MatrixEliminator<R> {
    override var form: Form {
        return .Diagonal
    }
    
    override func shouldIterate() -> Bool {
        return !(target.pointee.isDiagonal && target.pointee.diagonal.allSatisfy{ $0.isNormalized })
    }
    
    override func iteration() {
        subrun(RowEchelonEliminator(mode: mode, debug: debug))
        if shouldIterate() {
            subrun(ColEchelonEliminator(mode: mode, debug: debug))
        }
    }
}
