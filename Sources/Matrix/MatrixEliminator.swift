//
//  MatrixEliminator.swift
//  SwiftyAlgebra
//
//  Created by Taketo Sano on 2017/06/09.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Foundation

public enum MatrixForm {
    case Default
    case RowEchelon
    case ColEchelon
    case RowHermite
    case ColHermite
    case Diagonal
    case Smith
}

public class MatrixEliminator<R: EuclideanRing>: CustomStringConvertible {
    internal var target: ComputationalMatrix<R>
    internal var rowOps: [ElementaryOperation]
    internal var colOps: [ElementaryOperation]
    internal var debug: Bool
    
    public required init(_ target: ComputationalMatrix<R>, debug: Bool = false) {
        self.target = target
        self.rowOps = []
        self.colOps = []
        self.debug = debug
    }
    
    public var rows: Int {
        return target.rows
    }
    
    public var cols: Int {
        return target.cols
    }
    
    internal var resultType: MatrixEliminationResult<R>.Type {
        return MatrixEliminationResult.self
    }

    public var result: MatrixEliminationResult<R> {
        return resultType.init(target, rowOps, colOps, .Default)
    }
    
    @discardableResult
    public final func run() -> MatrixEliminationResult<R> {
        log("-----Start:\(self)-----")
        
        prepare()
        while !iteration() {}
        finish()
        
        log("-----Done:\(self), \(rowOps.count + colOps.count) steps)-----")
        
        return result
    }
    
    internal func prepare() {
        // override in subclass
    }
    
    internal func iteration() -> Bool {
        fatalError("override in subclass")
    }
    
    internal func finish() {
        // override in subclass
    }
    
    internal func run(_ eliminator: MatrixEliminator.Type) {
        let e = eliminator.init(target, debug: debug)
        e.run()
        rowOps += e.rowOps
        colOps += e.colOps
    }
    
    internal func runTranpose(_ eliminator: MatrixEliminator.Type) {
        transpose()
        let e = eliminator.init(target, debug: debug)
        e.run()
        rowOps += e.colOps.map{ s in s.transpose }
        colOps += e.rowOps.map{ s in s.transpose }
        transpose()
    }
    
    @_specialize(where R == IntegerNumber)
    internal func findMin(_ sequence: [(Int, R)]) -> (Int, R)? {
        var cand: (Int, R)? = nil
        for (i, a) in sequence {
            if a.isInvertible {
                return (i, a)
            }
            if cand == nil || a.degree < cand!.1.degree {
                cand = (i, a)
            }
        }
        return cand
    }
    
    internal func apply(_ s: ElementaryOperation) {
        s.apply(to: target)
        s.isRowOperation ? rowOps.append(s) : colOps.append(s)
        log("\(s)")
    }
    
    func transpose() {
        target.transpose()
        log("Transpose")
    }
    
    func log(_ msg: @autoclosure () -> String) {
        if debug {
            if rows < 20 && cols < 20 {
                print(msg(), "\n", target.asDynamicMatrix().detailDescription, "\n")
            } else {
                print(msg(), "\n\t", target, "\n")
            }
        }
    }
    
    public var description: String {
        return "\(type(of: self))"
    }
    
    public enum ElementaryOperation {
        case AddRow(at: Int, to: Int, mul: R)
        case MulRow(at: Int, by: R)
        case SwapRows(Int, Int)
        case AddCol(at: Int, to: Int, mul: R)
        case MulCol(at: Int, by: R)
        case SwapCols(Int, Int)
        
        public var isRowOperation: Bool {
            switch self {
            case .AddRow, .MulRow, .SwapRows: return true
            default: return false
            }
        }
        
        public var isColOperation: Bool {
            switch self {
            case .AddCol, .MulCol, .SwapCols: return true
            default: return false
            }
        }
        
        public var determinant: R {
            switch self {
            case .AddRow(_, _, _), .AddCol(_, _, _):
                return .identity
            case let .MulRow(at: _, by: r):
                return r
            case let .MulCol(at: _, by: r):
                return r
            case .SwapRows(_, _), .SwapCols(_, _):
                return -.identity
            }
        }
        
        public var inverse: ElementaryOperation {
            switch self {
            case let .AddRow(i, j, r):
                return .AddRow(at: i, to: j, mul: -r)
            case let .AddCol(i, j, r):
                return .AddCol(at: i, to: j, mul: -r)
            case let .MulRow(at: i, by: r):
                return .MulRow(at: i, by: r.inverse!)
            case let .MulCol(at: i, by: r):
                return .MulCol(at: i, by: r.inverse!)
            case .SwapRows(_, _), .SwapCols(_, _):
                return self
            }
        }
        
        public var transpose: ElementaryOperation {
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
        
        @_specialize(where R == IntegerNumber)
        public func apply(to A: ComputationalMatrix<R>) {
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
