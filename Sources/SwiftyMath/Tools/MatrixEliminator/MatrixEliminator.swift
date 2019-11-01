//
//  MatrixEliminator.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2017/06/09.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

public class MatrixEliminator<R: EuclideanRing> {
    public enum Form {
        case RowEchelon
        case ColEchelon
        case RowHermite
        case ColHermite
        case Diagonal
        case Smith
    }
    
    internal let worker: RowEliminationWorker<R>
    private var rowOps: [RowElementaryOperation<R>]
    private var colOps: [ColElementaryOperation<R>]
    
    var debug: Bool

    private var aborted: Bool = false
    
    public static func eliminate<n, m>(target: Matrix<n, m, R>, form: MatrixEliminator<R>.Form = .Diagonal, debug: Bool = false) -> MatrixEliminationResult<n, m, R> {
        let worker = RowEliminationWorker(target)
        let e: MatrixEliminator<R> = {
            switch form {
            case .RowEchelon:
                return RowEchelonEliminator(worker: worker, debug: debug)
            case .ColEchelon:
                return ColEchelonEliminator(worker: worker, debug: debug)
            case .RowHermite:
                return RowEchelonEliminator(worker: worker, reduced: true, debug: debug)
            case .ColHermite:
                return ColEchelonEliminator(worker: worker, reduced: true, debug: debug)
            case .Smith:
                return SmithEliminator(worker: worker, debug: debug)
            default:
                return DiagonalEliminator(worker: worker, debug: debug)
            }
        }()
        
        e.run()
        
        return .init(form: form, result: worker.resultAs(Matrix.self), rowOps: e.rowOps, colOps: e.colOps)
    }
    
    init(worker: RowEliminationWorker<R>, debug: Bool) {
        self.worker = worker
        self.rowOps = []
        self.colOps = []
        self.debug = debug
    }
    
    var size: (rows: Int, cols: Int) {
        worker.size
    }
    
    final func run() {
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
        
        log("Done:  \(self), \(rowOps.count + colOps.count) steps")
        
        if debug {
            printCurrentMatrix()
        }
    }
    
    final func subrun(_ e: MatrixEliminator<R>, transpose: Bool = false) {
        if transpose {
            e.worker.transpose()
        }
        
        e.run()
        
        if !transpose {
            rowOps += e.rowOps
            colOps += e.colOps
        } else {
            e.worker.transpose()
            rowOps += e.colOps.map{ s in s.transposed }
            colOps += e.rowOps.map{ s in s.transposed }
        }
    }
    
    final func abort() {
        aborted = true
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
    
    func finalize() {
        // override in subclass
    }

    func apply(_ s: RowElementaryOperation<R>) {
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
    
    final func log(_ msg: @autoclosure () -> String) {
        if debug {
            print(msg())
        }
    }
    
    final func printCurrentMatrix() {
        if size.rows > 100 || size.cols > 100 {
            return
        }
        
        print("\n", worker.resultAs(DMatrix.self).detailDescription, "\n")
    }
    
    public var description: String {
        "\(type(of: self))"
    }
}
