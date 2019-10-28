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
    
    let size: (rows: Int, cols: Int)
    private(set) var components: AnySequence<MatrixComponent<R>>
    private var rowOps: [RowElementaryOperation<R>]
    private var colOps: [ColElementaryOperation<R>]
    
    var debug: Bool

    private var aborted: Bool = false
    
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
        
        let e = eClass.init(size: target.size, components: target.nonZeroComponents, debug: debug)
        
        e.run()
        
        return MatrixEliminationResult<n, m, R>(form: form, result: Matrix<n, m, R>(size: target.size, components: e.components), rowOps: e.rowOps, colOps: e.colOps)
    }
    
    required init<S: Sequence>(size: (Int, Int), components: S, debug: Bool) where S.Element == MatrixComponent<R> {
        self.size = size
        self.components = (components as? AnySequence<MatrixComponent<R>>) ?? AnySequence(components)
        self.rowOps = []
        self.colOps = []
        self.debug = debug
    }
    
    final func run() {
        log("Start: \(self)")
        
        prepare()
        
        var itr = 0
        while !aborted && !isDone() {
            log("\(self) iteration: \(itr)")
            
            if debug {
                updateComponents()
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
    
    final func subrun(_ eClass: MatrixEliminator.Type, transpose: Bool = false) {
        let e = !transpose
            ? eClass.init(size: size, components: components, debug: debug)
            : eClass.init(size: (size.1, size.0), components: components.map{ (i, j, a) in (j, i, a) }, debug: debug)
        
        e.run()
        
        if !transpose {
            setComponents(e.components)
            rowOps += e.rowOps
            colOps += e.colOps
        } else {
            setComponents(e.components.lazy.map{ (j, i, a) in (i, j, a) })
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
        updateComponents()
    }
    
    func updateComponents() {
        // override in subclass
    }
    
    final func setComponents<S: Sequence>(_ components: S) where S.Element == MatrixComponent<R> {
        if let anySeq = components as? AnySequence<MatrixComponent<R>> {
            self.components = anySeq
        } else {
            self.components = AnySequence(components)
        }
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
        
        let A = DMatrix(size: size, components: components)
        print("\n", A.detailDescription, "\n")
    }
    
    public var description: String {
        "\(type(of: self))"
    }
}
