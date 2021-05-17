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
    
    let data: RowEliminationData<R>
    var rowOps: [RowElementaryOperation<R>]
    var colOps: [ColElementaryOperation<R>]
    var debug: Bool

    private var aborted: Bool = false
    
    public static func eliminate<n, m>(target: Matrix<n, m, R>, form: MatrixEliminator<R>.Form = .Diagonal, debug: Bool = false) -> MatrixEliminationResult<n, m, R> {
        let data = RowEliminationData(target)
        let e: MatrixEliminator<R> = {
            switch form {
            case .RowEchelon:
                return RowEchelonEliminator(data: data, debug: debug)
            case .ColEchelon:
                return ColEchelonEliminator(data: data, debug: debug)
            case .RowHermite:
                return RowEchelonEliminator(data: data, reduced: true, debug: debug)
            case .ColHermite:
                return ColEchelonEliminator(data: data, reduced: true, debug: debug)
            case .Smith:
                return SmithEliminator(data: data, debug: debug)
            default:
                return DiagonalEliminator(data: data, debug: debug)
            }
        }()
        
        e.run()
        
        return .init(form: form, result: data.resultAs(Matrix.self), rowOps: e.rowOps, colOps: e.colOps)
    }
    
    init(data: RowEliminationData<R>, debug: Bool) {
        self.data = data
        self.rowOps = []
        self.colOps = []
        self.debug = debug
    }
    
    var size: (rows: Int, cols: Int) {
        data.size
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
            e.data.transpose()
        }
        
        e.run()
        
        if !transpose {
            rowOps += e.rowOps
            colOps += e.colOps
        } else {
            e.data.transpose()
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
        data.apply(s)
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
        
        print("\n", data.resultAs(DMatrix.self).detailDescription, "\n")
    }
    
    public var description: String {
        "\(type(of: self))"
    }
}
