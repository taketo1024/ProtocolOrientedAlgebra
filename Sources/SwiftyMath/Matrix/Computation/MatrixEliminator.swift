//
//  MatrixEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/06/09.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public enum MatrixEliminationForm {
    case RowEchelon
    case ColEchelon
    case RowHermite
    case ColHermite
    case Diagonal
    case Smith
}

public class MatrixEliminator<R: EuclideanRing> : CustomStringConvertible {
    var target: UnsafeMutablePointer<DMatrix<R>>!
    var rowOps: [ElementaryOperation] = []
    var colOps: [ElementaryOperation] = []
    var debug: Bool
    
    private var _exit: Bool = false
    
    public required init(debug: Bool = false) {
        self.debug = debug
    }
    
    public final func run<n, m>(target: Matrix<n, m, R>) -> MatrixEliminationResult<n, m, R> {
        var copy = target.as(DMatrix.self)
        self.target = UnsafeMutablePointer(mutating: &copy)
        
        log("Start")
        _run()
        log("Done: \(rowOps.count + colOps.count) steps")
        
        return MatrixEliminationResult(form: form, result: copy.as(Matrix<n, m, R>.self), rowOps: rowOps, colOps: colOps)
    }
    
    private final func _run() {
        prepare()
        
        while !_exit && shouldIterate() {
            iteration()
        }
        
        finalize()
    }
    
    final func subrun(_ e: MatrixEliminator<R>, transpose: Bool = false) {
        e.target = target
        
        if transpose {
            e.transpose()
        }
        
        e._run()
            
        if transpose {
            e.transpose()
        }
        
        rowOps += e.rowOps
        colOps += e.colOps
    }
    
    final func transpose() {
        target.pointee.transpose()
        (rowOps, colOps) = (colOps.map{ s in s.transposed }, rowOps.map{ s in s.transposed })
        log("Transpose")
    }
    
    final func log(_ msg: @autoclosure () -> String) {
        if debug {
            print("[\(form)]", msg(), "\n", target.pointee.detailDescription, "\n")
        }
    }
    
    final func exit() {
        _exit = true
    }
    
    // override points
    
    var form: MatrixEliminationForm {
        fatalError("override in subclass")
    }
    
    func prepare() {
        // override in subclass
    }
    
    func shouldIterate() -> Bool {
        fatalError("override in subclass")
    }
    
    func iteration() {
        fatalError("override in subclass")
    }
    
    func apply(_ s: ElementaryOperation) {
        // override in subclass
        append(s)
        log("\(s)")
    }
    
    func append(_ s: ElementaryOperation) {
        s.isRowOperation ? rowOps.append(s) : colOps.append(s)
    }
    
    func finalize() {
        // override in subclass
    }
    
    public var description: String {
        return "\(type(of: self))"
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
        
        var transposed: ElementaryOperation {
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
}
