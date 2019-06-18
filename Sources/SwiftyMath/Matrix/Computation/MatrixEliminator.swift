//
//  MatrixEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/06/09.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

private var _debug = false

public class MatrixEliminator<R: EuclideanRing> {
    public enum Form {
        case RowEchelon
        case ColEchelon
        case RowHermite
        case ColHermite
        case Diagonal
        case Smith
    }
    
    public static func eliminate<n, m>(_ A: Matrix<n, m, R>, form: Form = .Diagonal) -> MatrixEliminationResult<n, m, R> {
        let type: MatrixEliminator<R>.Type
        
        switch form {
        case .RowEchelon: type = RowEchelonEliminator.self
        case .ColEchelon: type = ColEchelonEliminator.self
        case .RowHermite: type = RowHermiteEliminator.self
        case .ColHermite: type = ColHermiteEliminator.self
        case .Smith:      type = SmithEliminator     .self
        default:          type = DiagonalEliminator  .self
        }
        
        let elim = type.init(A.impl.copy())
        let result = elim.run()
        return MatrixEliminationResult(result)
    }

    var target: MatrixImpl<R>
    var rowOps: [ElementaryOperation]
    var colOps: [ElementaryOperation]
    
    required init(_ target: MatrixImpl<R>) {
        self.target = target
        self.rowOps = []
        self.colOps = []
    }
    
    final var rows: Int { return target.rows }
    final var cols: Int { return target.cols }
    
    @discardableResult
    final func run() -> MatrixEliminationResultImpl<R> {
        log("-----Start:\(self)-----")
        
        prepare()
        while !isDone() {
            iteration()
        }
        finish()
        
        log("-----Done:\(self), \(rowOps.count + colOps.count) steps)-----")
        
        return resultType.init(target, rowOps, colOps)
    }
    
    final func run(_ eliminator: MatrixEliminator.Type) {
        let e = eliminator.init(target)
        e.run()
        rowOps += e.rowOps
        colOps += e.colOps
    }
    
    final func runTranpose(_ eliminator: MatrixEliminator.Type) {
        transpose()
        let e = eliminator.init(target)
        e.run()
        rowOps += e.colOps.map{ s in s.transpose }
        colOps += e.rowOps.map{ s in s.transpose }
        transpose()
    }
    
    final func apply(_ s: ElementaryOperation) {
        target.apply(s)
        s.isRowOperation ? rowOps.append(s) : colOps.append(s)
        
        log("\(s)")
    }
    
    final func transpose() {
        target.transpose()
        log("Transpose")
    }
    
    final func log(_ msg: @autoclosure () -> String) {
        if MatrixEliminator.debug {
            print(msg() + "\n" + DMatrix(target).detailDescription)
        }
    }
    
    // override points
    
    var resultType: MatrixEliminationResultImpl<R>.Type {
        return MatrixEliminationResultImpl.self
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
    }
    
    static var debug: Bool  {
        get { return _debug }
        set { _debug = newValue }
    }
}

extension MatrixImpl where R: EuclideanRing {
    func apply(_ s: MatrixEliminator<R>.ElementaryOperation) {
        switch s {
        case let .AddRow(i, j, r):
            addRow(at: i, to: j, multipliedBy: r)
        case let .AddCol(i, j, r):
            addCol(at: i, to: j, multipliedBy: r)
        case let .MulRow(i, r):
            multiplyRow(at: i, by: r)
        case let .MulCol(i, r):
            multiplyCol(at: i, by: r)
        case let .SwapRows(i, j):
            swapRows(i, j)
        case let .SwapCols(i, j):
            swapCols(i, j)
        }
    }
}
