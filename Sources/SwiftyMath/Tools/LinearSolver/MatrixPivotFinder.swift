//
//  MatrixPivotFinder.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/26.
//

//  Implementation based on:
//
//  "Parallel Sparse PLUQ Factorization modulo p", Charles Bouillaguet, Claire Delaplace, Marie-Emilie Voge.
//  https://hal.inria.fr/hal-01646133/document
//
//  see also:
//
//  SpaSM (Sparse direct Solver Modulo p)
//  https://github.com/cbouilla/spasm

import Dispatch

public final class MatrixPivotFinder<R: Ring> {
    typealias RowEntity = RowEliminationWorker<R>.RowElement
    
    public let size: (rows: Int, cols: Int)
    private let worker: RowEliminationWorker<R>
    
    private var pivots: [Int : Int] // column -> pivot row
    private var pivotRows: Set<Int>
    private var debug: Bool
    
    public static func findPivots<n, m>(of A: Matrix<n, m, R>, debug: Bool = false) -> Result<n, m, R> {
        let size = A.size
        let pf = MatrixPivotFinder(A, debug: debug)
        let pivots = pf.run()
        
        func asPermutation<n>(_ order: [Int], _ n: Int) -> Permutation<n> {
            let remain = Set(0 ..< n).subtracting(order)
            return Permutation(order + remain.sorted()).inverse!
        }
        
        let rowP: Permutation<n> = asPermutation(pivots.map{ $0.0 }, size.rows)
        let colP: Permutation<m> = asPermutation(pivots.map{ $0.1 }, size.cols)
        
        return Result(
            pivots: pivots,
            rowPermutation: rowP,
            colPermutation: colP
        )
    }
    
    private init<n, m>(_ A: Matrix<n, m, R>, debug: Bool = false) {
        self.size = A.size
        self.worker = RowEliminationWorker(
            size: A.size,
            components: A.nonZeroComponents
        )
        self.pivots = [:]
        self.pivotRows = []
        self.debug = debug
    }
    
    private func run() -> [(Int, Int)] {
        findFLPivots()
        findFLColumnPivots()
        findCycleFreePivots()
        return sortPivots()
    }
    
    // Faugère-Lachartre pivot search
    private func findFLPivots() {
        let n = size.rows
        var pivots: [Int : Int] = [:] // col -> row
        
        for i in 0 ..< n {
            let row = self.row(i)
            guard let head = row.headElement else {
                continue
            }
            let (j, a) = (head.col, head.value)
            
            if !a.isInvertible {
                continue
            }
            
            if pivots[j] == nil || isBetter(i, than: pivots[j]!) {
                pivots[j] = i
            }
        }
        
        pivots.forEach{ (j, i) in setPivot(i, j) }
        log("FL-pivots: \(pivots.count)")
    }
    
    private func findFLColumnPivots() {
        let n = size.rows
        var reservedCols = Set(pivotRows.flatMap{ i in
            row(i).map { $0.col }
        })
        
        for i in 0 ..< n {
            let row = worker.row(i)
            var isPivotRow = pivotRows.contains(i)
            
            for (j, a) in row where !reservedCols.contains(j) {
                reservedCols.insert(j)
                
                if !isPivotRow && a.isInvertible {
                    setPivot(i, j)
                    isPivotRow = true
                }
            }
        }
        
        log("FL-col-pivots: \(pivots.count)")
    }
    
    private func findCycleFreePivots() {
        let n = size.rows
        let rows = (0 ..< n).compactMap { i -> (Int, LinkedList<RowEntity>)? in
            if pivotRows.contains(i) {
                return nil
            }
            let row = self.row(i)
            return row.isEmpty ? nil : (i, row)
        }
        
        let atomic = DispatchQueue(label: "atomic", qos: .userInteractive)
        
        rows.parallelForEach { row in
            var found = false
            while !found {
                let pivotsLocal = atomic.sync { self.pivots }
                let nPivLocal = pivotsLocal.count
                
                guard let pivot = self.findCycleFreePivot(inRow: row, pivots: pivotsLocal) else {
                    break
                }
                
                atomic.sync {
                    let nPiv = self.pivots.count
                    if nPiv == nPivLocal {
                        self.setPivot(pivot)
                        found = true
                    }
                }
            }
        }
        
        log("cycle-free-pivots: \(pivots.count)")
    }
    
    private func findCycleFreePivot(inRow row: (Int, LinkedList<RowEntity>), pivots: [Int : Int]) -> (Int, Int)? {
        let (i, list) = row
        
        var queue: [Int] = []
        var candidates: Set<Int> = []
        var visited: Set<Int> = []
        
        // initialize
        for (j, a) in list {
            if pivots.contains(key: j) {
                queue.append(j)
            } else if a.isInvertible {
                candidates.insert(j)
            }
        }
        
        queueLoop: while !queue.isEmpty {
            let j = queue.removeFirst()
            let k = pivots[j]!
            
            for (l, _) in self.row(k) {
                if pivots.contains(key: l) && !visited.contains(l) {
                    queue.append(l)
                    visited.insert(l)
                } else if candidates.contains(l) {
                    candidates.remove(l)
                    if candidates.isEmpty {
                        break queueLoop
                    }
                }
            }
        }
        
        // TODO take the one with min weight
        if let j = candidates.anyElement {
            return (i, j)
        } else {
            return nil
        }
    }
    
    private func sortPivots() -> [(Int, Int)] {
        let tree = Dictionary(keys: pivots.keys) { j -> [Int] in
            let i = pivots[j]!
            return self.row(i).compactMap { (k, _) -> Int? in
                if k != j && pivots[k] != nil {
                    return k
                } else {
                    return nil
                }
            }
        }
        let sorted = try! topologicalSort(tree.keys.toArray(), successors: { j in tree[j] ?? [] })
        return sorted.map{ j in (pivots[j]!, j) }
    }
    
    // for debug
    private func currentPivots() -> [(Int, Int)] {
        pivots.map{ (j, i) in (i, j) }.sorted{ $0.0 }
    }
    
    private func setPivot(_ p: (Int, Int)) {
        setPivot(p.0, p.1)
    }
        
    private func setPivot(_ i: Int, _ j: Int) {
        pivots[j] = i
        pivotRows.insert(i)
    }
    
    private func isBetter(_ i1: Int, than i2: Int) -> Bool {
        guard
            let w1 = row(i1).headElement?.value.matrixEliminationWeight,
            let w2 = row(i2).headElement?.value.matrixEliminationWeight else {
                fatalError()
        }
        
        return w1 < w2 || w1 == w2 && rowWeight(i1) < rowWeight(i2)
    }
    
    private func row(_ i: Int) -> LinkedList<RowEntity> {
        worker.row(i)
    }
    
    private func rowWeight(_ i: Int) -> Int {
        worker.rowWeight(i)
    }
    
    private func log(_ msg: @autoclosure () -> String) {
        if debug {
            print(msg())
        }
    }
    
    public struct Result<n: SizeType, m: SizeType, R: Ring> {
        public let pivots: [(Int, Int)]
        public let rowPermutation: Permutation<n>
        public let colPermutation: Permutation<m>
    }
}
