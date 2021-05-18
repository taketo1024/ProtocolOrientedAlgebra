//
//  MatrixEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/06/09.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public enum MatrixEliminationForm {
    case none
    case RowEchelon
    case ColEchelon
    case RowHermite
    case ColHermite
    case Diagonal
    case Smith
}

extension MatrixIF where BaseRing: EuclideanRing {
    public func eliminate(form: MatrixEliminationForm = .Diagonal) -> MatrixEliminationResult<Impl, n, m> {
        let (type, transpose): (MatrixEliminator<BaseRing>.Type, Bool) = {
            switch form {
            case .RowEchelon:
                return (RowEchelonEliminator.self, false)
            case .ColEchelon:
                return (RowEchelonEliminator.self, true)
            case .RowHermite:
                return (ReducedRowEchelonEliminator.self, false)
            case .ColHermite:
                return (ReducedRowEchelonEliminator.self, true)
            case .Diagonal:
                return (DiagonalEliminator.self, false)
            case .Smith:
                return (SmithEliminator.self, false)
            default:
                return (MatrixEliminator.self, false)
            }
        }()
        
        let worker = MatrixEliminationWorker(self)
        let elim = type.init(worker: worker, transpose: transpose)
        elim.run()
        
        return MatrixEliminationResult(elim)
    }
}

public class MatrixEliminator<R: Ring> {
    let worker: MatrixEliminationWorker<R>
    var rowOps: [RowElementaryOperation<R>]
    var colOps: [ColElementaryOperation<R>]
    
    var transposed: Bool
    var debug: Bool = false
    var aborted: Bool = false
    
    required init(worker: MatrixEliminationWorker<R>, transpose: Bool = false) {
        self.worker = worker
        self.rowOps = []
        self.colOps = []
        self.transposed = transpose
    }
    
    public final var size: MatrixSize {
        worker.size
    }
    
    public final func run() {
        log("Start: \(self)")
        
        if transposed {
            transpose()
        }
        
        prepare()
        
        var itr = 0
        while !aborted && !isDone() {
            log("\(self) iteration: \(itr)")
            
            if debug {
                printCurrentMatrix()
            }
            
            iteration()
            
            log("")
            itr += 1
        }
        
        finalize()
        
        if transposed {
            transpose()
        }
        
        log("Done:  \(self), \(rowOps.count + colOps.count) steps")
        
        if debug {
            printCurrentMatrix()
        }
    }
    
    public var description: String {
        "\(type(of: self))"
    }
    
    // MARK: Internal methods

    final func subrun(_ e: MatrixEliminator<R>) {
        e.run()
        rowOps += e.rowOps
        colOps += e.colOps
    }
    
    final func abort() {
        aborted = true
    }
    
    final func apply(_ s: RowElementaryOperation<R>) {
        worker.apply(s)
        append(s)
    }

    final func append(_ s: RowElementaryOperation<R>) {
        rowOps.append(s)
        log("\(s)")
    }
    
    final func append(_ s: ColElementaryOperation<R>) {
        colOps.append(s)
        log("\(s)")
    }
    
    final func append(_ s: [RowElementaryOperation<R>]) {
        rowOps.append(contentsOf: s)
        log(s.map{ "\($0)"}.joined(separator: "\n"))
    }
    
    final func transpose() {
        log("Transpose: \(self)")
        worker.transpose()
        (rowOps, colOps) = (colOps.map{ $0.transposed }, rowOps.map{ $0.transposed })
    }
    
    final func log(_ msg: @autoclosure () -> String) {
        if debug {
            print(msg())
        }
    }
    
    final func printCurrentMatrix() {
        if size.rows > 100 || size.cols > 100 {
            return
        }
        
        print("\n", worker.resultAs(MatrixDxD.self).detailDescription, "\n")
    }

    // MARK: Methods to be overridden
    
    public var form: MatrixEliminationForm { .none }
    func prepare() {}
    func isDone() -> Bool { true }
    func iteration() {}
    func finalize() {}
}
