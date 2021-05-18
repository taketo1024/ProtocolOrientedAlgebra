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
        
        let worker = !transpose
            ? MatrixEliminationWorker(self)
            : MatrixEliminationWorker(self.transposed)
        let elim = type.init(worker: worker, transposed: transpose)
        elim.run()
        
        return MatrixEliminationResult(elim)
    }
}

public class MatrixEliminator<R: Ring> {
    let worker: MatrixEliminationWorker<R>
    var transposed: Bool
    var debug: Bool = true
    var aborted: Bool = false
    
    private var rowOps_: [RowElementaryOperation<R>]
    private var colOps_: [ColElementaryOperation<R>]
    
    required init(worker: MatrixEliminationWorker<R>, transposed: Bool = false) {
        self.worker = worker
        self.rowOps_ = []
        self.colOps_ = []
        self.transposed = transposed
    }
    
    public final var size: MatrixSize {
        !transposed
            ? worker.size
            : (worker.size.cols, worker.size.rows)
    }
    
    public var entries: AnySequence<MatrixEntry<R>> {
        !transposed
            ? worker.entries
            : AnySequence(worker.entries.lazy.map{ (i, j, a) in (j, i, a) })
    }
    
    public var headEntries: [MatrixEntry<R>] {
        !transposed
            ? worker.headEntries
            : worker.headEntries.map{ (i, j, a) in (j, i, a) }
    }
    
    public func resultAs<Impl, n, m>(_ type: MatrixIF<Impl, n, m>.Type) -> MatrixIF<Impl, n, m> where Impl.BaseRing == R {
        .init(size: size, entries: entries)
    }
    
    var rowOps: [RowElementaryOperation<R>] {
        !transposed
            ? rowOps_
            : colOps_.map{ $0.transposed }
    }
    
    var colOps: [ColElementaryOperation<R>] {
        !transposed
            ? colOps_
            : rowOps_.map{ $0.transposed }
    }
    
    public final func run() {
        log("Start: \(self)")
        
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
        
        log("Done:  \(self), \(rowOps_.count + colOps_.count) steps")
        
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
        rowOps_ += e.rowOps
        colOps_ += e.colOps
    }
    
    final func abort() {
        aborted = true
    }
    
    final func apply(_ s: RowElementaryOperation<R>) {
        worker.apply(s)
        append(s)
    }

    final func append(_ s: RowElementaryOperation<R>) {
        rowOps_.append(s)
        log("\(s)")
    }
    
    final func append(_ s: ColElementaryOperation<R>) {
        colOps_.append(s)
        log("\(s)")
    }
    
    final func append(_ s: [RowElementaryOperation<R>]) {
        rowOps_.append(contentsOf: s)
        log(s.map{ "\($0)"}.joined(separator: "\n"))
    }
    
    final func transpose() {
        log("Transpose: \(self)")
        worker.transpose()
        (rowOps_, colOps_) = (colOps_.map{ $0.transposed }, rowOps_.map{ $0.transposed })
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
        
        print("\n", resultAs(MatrixDxD.self).detailDescription, "\n")
    }

    // MARK: Methods to be overridden
    
    public var form: MatrixEliminationForm { .none }
    func prepare() {}
    func isDone() -> Bool { true }
    func iteration() {}
    func finalize() {}
}
