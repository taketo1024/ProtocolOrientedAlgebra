//
//  MatrixEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/06/09.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public extension LogFlag {
    static var matrixElimination: LogFlag { return LogFlag(id: "Matrix.Elimination", label: "matrix") }
}

internal class MatrixEliminator<R: EuclideanRing>: CustomStringConvertible {
    var target: MatrixImpl<R>
    var rowOps: [ElementaryOperation]
    var colOps: [ElementaryOperation]
    
    required init(_ target: MatrixImpl<R>) {
        self.target = target
        self.rowOps = []
        self.colOps = []
    }
    
    var rows: Int {
        return target.rows
    }
    
    var cols: Int {
        return target.cols
    }
    
    var resultType: MatrixEliminationResultImpl<R>.Type {
        return MatrixEliminationResultImpl.self
    }

    var result: MatrixEliminationResultImpl<R> {
        return resultType.init(target, rowOps, colOps, .Default)
    }
    
    @discardableResult
    final func run() -> MatrixEliminationResultImpl<R> {
        log("-----Start:\(self)-----")
        
        prepare()
        while !isDone() {
            iteration()
        }
        finish()
        
        log("-----Done:\(self), \(rowOps.count + colOps.count) steps)-----")
        
        return result
    }
    
    func prepare() {
        // override in subclass
    }
    
    func isDone() -> Bool {
        fatalError("override in subclass")
    }
    
    func iteration() {
        fatalError("override in subclass")
    }
    
    func finish() {
        // override in subclass
    }
    
    func run(_ eliminator: MatrixEliminator.Type) {
        let e = eliminator.init(target)
        e.run()
        rowOps += e.rowOps
        colOps += e.colOps
    }
    
    func runTranpose(_ eliminator: MatrixEliminator.Type) {
        transpose()
        let e = eliminator.init(target)
        e.run()
        rowOps += e.colOps.map{ s in s.transpose }
        colOps += e.rowOps.map{ s in s.transpose }
        transpose()
    }
    
    func apply(_ s: ElementaryOperation) {
        s.apply(to: target)
        s.isRowOperation ? rowOps.append(s) : colOps.append(s)
        log("\(s)")
    }
    
    func transpose() {
        target.transpose()
        log("Transpose")
    }
    
    var description: String {
        return "\(type(of: self))"
    }
    
    func log(_ msg: @autoclosure () -> String) {
        Logger.write(.matrixElimination, msg())
    }
    
    enum ElementaryOperation {
        case AddRow(at: Int, to: Int, mul: R)
        case MulRow(at: Int, by: R)
        case SwapRows(Int, Int)
        case AddCol(at: Int, to: Int, mul: R)
        case MulCol(at: Int, by: R)
        case SwapCols(Int, Int)
        
        var isRowOperation: Bool {
            switch self {
            case .AddRow, .MulRow, .SwapRows: return true
            default: return false
            }
        }
        
        var isColOperation: Bool {
            switch self {
            case .AddCol, .MulCol, .SwapCols: return true
            default: return false
            }
        }
        
        var determinant: R {
            switch self {
            case .AddRow(_, _, _), .AddCol(_, _, _):
                return .identity
            case let .MulRow(at: _, by: r):
                return r
            case let .MulCol(at: _, by: r):
                return r
            case .SwapRows, .SwapCols:
                return -.identity
            }
        }
        
        var inverse: ElementaryOperation {
            switch self {
            case let .AddRow(i, j, r):
                return .AddRow(at: i, to: j, mul: -r)
            case let .AddCol(i, j, r):
                return .AddCol(at: i, to: j, mul: -r)
            case let .MulRow(at: i, by: r):
                return .MulRow(at: i, by: r.inverse!)
            case let .MulCol(at: i, by: r):
                return .MulCol(at: i, by: r.inverse!)
            case .SwapRows, .SwapCols:
                return self
            }
        }
        
        var transpose: ElementaryOperation {
            switch self {
            case let .AddRow(i, j, r):
                return .AddCol(at: i, to: j, mul: r)
            case let .AddCol(i, j, r):
                return .AddRow(at: i, to: j, mul: r)
            case let .MulRow(at: i, by: r):
                return .MulCol(at: i, by: r)
            case let .MulCol(at: i, by: r):
                return .MulRow(at: i, by: r)
            case let .SwapRows(i, j):
                return .SwapCols(i, j)
            case let .SwapCols(i, j):
                return .SwapRows(i, j)
            }
        }
        
        @_specialize(where R == ComputationSpecializedRing)
        func apply(to A: MatrixImpl<R>) {
            switch self {
            case let .AddRow(i, j, r):
                A.addRow(at: i, to: j, multipliedBy: r)
            case let .AddCol(i, j, r):
                A.addCol(at: i, to: j, multipliedBy: r)
            case let .MulRow(i, r):
                A.multiplyRow(at: i, by: r)
            case let .MulCol(i, r):
                A.multiplyCol(at: i, by: r)
            case let .SwapRows(i, j):
                A.swapRows(i, j)
            case let .SwapCols(i, j):
                A.swapCols(i, j)
            }
        }
    }
}
