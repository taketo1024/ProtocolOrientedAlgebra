//
//  MatrixEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/06/09.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public class MatrixEliminator<R: EuclideanRing> : CustomStringConvertible {
    public enum Form {
        case RowEchelon
        case ColEchelon
        case RowHermite
        case ColHermite
        case Diagonal
        case Smith
    }
    
    var size: (rows: Int, cols: Int)
    var components: [MatrixComponent<R>]
    var rowOps: [RowElementaryOperation<R>]
    var colOps: [ColElementaryOperation<R>]
    
    var debug: Bool

    private var _exit: Bool = false
    
    public static func eliminate<n, m>(target: Matrix<n, m, R>, form: MatrixEliminator<R>.Form = .Diagonal, debug: Bool = false) -> MatrixEliminationResult<n, m, R> {
        let eClass: MatrixEliminator<R>.Type = {
            switch form {
            case .RowEchelon: return RowEchelonEliminator.self
            case .ColEchelon: return ColEchelonEliminator.self
            case .RowHermite: return RowHermiteEliminator.self
            case .ColHermite: return ColHermiteEliminator.self
            case .Smith:      return SmithEliminator.self
            default:          return DiagonalEliminator.self
            }
        }()
        
        let e = eClass.init(size: target.size, components: Array(target.nonZeroComponents), debug: debug)
        e.run()
        
        return MatrixEliminationResult<n, m, R>(form: form, result: Matrix<n, m, R>(size: target.size, components: e.components), rowOps: e.rowOps, colOps: e.colOps)
    }
    
    required init(size: (Int, Int), components: [MatrixComponent<R>], debug: Bool) {
        self.size = size
        self.components = components
        self.rowOps = []
        self.colOps = []
        self.debug = debug
    }
    
    final func run() {
        log("Start: \(self)")
        
        prepare()
        
        while !_exit && !isDone() {
            iteration()
        }
        
        finalize()
        
        log("Done:  \(self), \(rowOps.count + colOps.count) steps")
    }
    
    final func subrun(_ eClass: MatrixEliminator.Type, transpose: Bool = false) {
        let e = !transpose
            ? eClass.init(size: size, components: components, debug: debug)
            : eClass.init(size: (size.1, size.0), components: components.map{ (i, j, a) in (j, i, a) }, debug: debug)
        
        e.run()
        
        if !transpose {
            components = e.components
            rowOps += e.rowOps
            colOps += e.colOps
        } else {
            components = e.components.map{ (j, i, a) in (i, j, a) }
            rowOps += e.colOps.map{ s in s.transposed }
            colOps += e.rowOps.map{ s in s.transposed }
        }
    }
    
    final func log(_ msg: @autoclosure () -> String) {
        if debug {
            let A = DMatrix(size: size, components: components)
            print(msg(), "\n", A.detailDescription, "\n")
        }
    }
    
    final func exit() {
        _exit = true
    }
    
    func prepare() {
        // override in subclass
    }
    
    func isDone() -> Bool {
        // override in subclass
        true
    }
    
    func iteration() {
        // override in subclass
    }
    
    final func append(_ s: RowElementaryOperation<R>) {
        rowOps.append(s)
        log("\(s)")
    }
    
    final func append(_ s: ColElementaryOperation<R>) {
        colOps.append(s)
        log("\(s)")
    }
    
    func finalize() {
        // override in subclass
    }
    
    public var description: String {
        "\(type(of: self))"
    }
}

enum RowElementaryOperation<R: Ring> {
    case AddRow(at: Int, to: Int, mul: R)
    case MulRow(at: Int, by: R)
    case SwapRows(Int, Int)
    
    var determinant: R {
        switch self {
        case .AddRow(_, _, _):
            return .identity
        case let .MulRow(at: _, by: r):
            return r
        case .SwapRows:
            return -.identity
        }
    }
    
    var inverse: Self {
        switch self {
        case let .AddRow(i, j, r):
            return .AddRow(at: i, to: j, mul: -r)
        case let .MulRow(at: i, by: r):
            return .MulRow(at: i, by: r.inverse!)
        case .SwapRows:
            return self
        }
    }
    
    var transposed: ColElementaryOperation<R> {
        switch self {
        case let .AddRow(i, j, r):
            return .AddCol(at: i, to: j, mul: r)
        case let .MulRow(at: i, by: r):
            return .MulCol(at: i, by: r)
        case let .SwapRows(i, j):
            return .SwapCols(i, j)
        }
    }
}

enum ColElementaryOperation<R: Ring> {
    case AddCol(at: Int, to: Int, mul: R)
    case MulCol(at: Int, by: R)
    case SwapCols(Int, Int)
    
    var determinant: R {
        switch self {
        case .AddCol(_, _, _):
            return .identity
        case let .MulCol(at: _, by: r):
            return r
        case .SwapCols:
            return -.identity
        }
    }
    
    var inverse: Self {
        switch self {
        case let .AddCol(i, j, r):
            return .AddCol(at: i, to: j, mul: -r)
        case let .MulCol(at: i, by: r):
            return .MulCol(at: i, by: r.inverse!)
        case .SwapCols:
            return self
        }
    }
    
    var transposed: RowElementaryOperation<R> {
        switch self {
        case let .AddCol(i, j, r):
            return .AddRow(at: i, to: j, mul: r)
        case let .MulCol(at: i, by: r):
            return .MulRow(at: i, by: r)
        case let .SwapCols(i, j):
            return .SwapRows(i, j)
        }
    }
}
